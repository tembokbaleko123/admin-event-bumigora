<?php

namespace App\Http\Controllers;

use App\Enums\AttendanceStatus;
use App\Enums\RegistrationStatus;
use App\Models\Event;
use App\Models\Attendance;
use App\Models\EventQrToken;
use App\Models\EventRegistration;
use App\Models\Notifikasi;
use App\Models\AuditLog;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AttendanceController extends Controller
{
    use ApiResponse;

    public function generateQr(Request $request, int $eventId): JsonResponse
    {
        try {
            $user = $request->user();
            $event = Event::find($eventId);

            if (!$event) {
                return $this->notFound('Event');
            }

            if (!$user->isAdmin() && $event->created_by !== $user->id) {
                return $this->forbidden('Anda tidak memiliki akses ke event ini');
            }

            $validated = $request->validate([
                'duration' => 'nullable|integer|min:5|max:1440',
            ]);

            $duration = $validated['duration'] ?? 120;

            $token = EventQrToken::generateToken($event, $duration, $user);

            return $this->success([
                'token' => $token->token,
                'expired_at' => $token->expired_at->toIso8601String(),
                'duration_minutes' => $duration,
            ], 'QR Code berhasil dibuat');

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Generate QR error', [
                'event_id' => $eventId,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal membuat QR Code');
        }
    }

    public function getActiveQr(Request $request, int $eventId): JsonResponse
    {
        try {
            $user = $request->user();
            $event = Event::find($eventId);

            if (!$event) {
                return $this->notFound('Event');
            }

            if (!$user->isAdmin() && $event->created_by !== $user->id) {
                return $this->forbidden('Anda tidak memiliki akses ke event ini');
            }

            $activeToken = EventQrToken::active($eventId)->latest()->first();

            if (!$activeToken) {
                return $this->success([
                    'has_active_qr' => false,
                    'token' => null,
                ], 'Tidak ada QR Code aktif');
            }

            return $this->success([
                'has_active_qr' => true,
                'id' => $activeToken->id,
                'token' => $activeToken->token,
                'expired_at' => $activeToken->expired_at->toIso8601String(),
                'is_expired' => $activeToken->isExpired(),
            ], 'QR Code aktif berhasil diambil');

        } catch (\Throwable $e) {
            Log::error('Get active QR error', [
                'event_id' => $eventId,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal mengambil QR Code aktif');
        }
    }

    public function scanAttendance(Request $request, int $eventId): JsonResponse
    {
        try {
            $user = $request->user();

            if (!$user->isMahasiswa()) {
                return $this->forbidden('Hanya mahasiswa yang dapat melakukan scan');
            }

            $event = Event::find($eventId);

            if (!$event) {
                return $this->notFound('Event');
            }

            $validated = $request->validate([
                'qr_token' => 'required|string',
            ]);

            $token = EventQrToken::where('token', $validated['qr_token'])
                ->where('event_id', $eventId)
                ->first();

            if (!$token) {
                return $this->error('QR Code tidak valid', 400);
            }

            if (!$token->isValid()) {
                return $this->error('QR Code sudah tidak berlaku', 400);
            }

            if ($event->tanggal->isFuture()) {
                return $this->error('Event belum dimulai', 400);
            }

            $registration = EventRegistration::where('event_id', $eventId)
                ->where('user_id', $user->id)
                ->where('status', RegistrationStatus::Registered->value)
                ->first();

            if (!$registration) {
                return $this->error('Anda belum terdaftar di event ini', 400);
            }

            $existing = Attendance::where('event_id', $eventId)
                ->where('user_id', $user->id)
                ->first();

            if ($existing) {
                return $this->error('Anda sudah melakukan absensi', 400);
            }

            // Determine if late: compare scanned_at against event date
            // If scanned on the same calendar day as the event, it's on time
            // If scanned after the event date, it's late
            $scannedAt = now();
            $eventStart = $event->tanggal;
            $isLate = $scannedAt->startOfDay()->gt($eventStart->copy()->startOfDay());

            $attendance = DB::transaction(function () use ($event, $user, $registration, $token, $isLate, $scannedAt, $request) {
                $att = Attendance::create([
                    'event_id' => $event->id,
                    'user_id' => $user->id,
                    'registration_id' => $registration->id,
                    'qr_token_id' => $token->id,
                    'scanned_at' => $scannedAt,
                    'status' => $isLate ? AttendanceStatus::Late->value : AttendanceStatus::Valid->value,
                ]);

                $registration->update(['status' => 'attended']);

                Notifikasi::kirimNotifikasi(
                    $user,
                    $isLate
                        ? "Absensi berhasil (terlambat) untuk event {$event->judul}"
                        : "Absensi berhasil untuk event {$event->judul}",
                    $event
                );

                // Audit log for attendance
                AuditLog::log(AuditLog::ACTION_SCAN_ATTENDANCE, Attendance::class, $att->id, null, [
                    'event_id' => $event->id,
                    'event_title' => $event->judul,
                    'status' => $att->status,
                ]);

                return $att;
            });

            return $this->success([
                'id' => $attendance->id,
                'status' => $attendance->status,
                'scanned_at' => $attendance->scanned_at->toIso8601String(),
                'message' => $isLate
                    ? 'Absensi berhasil (terlambat)'
                    : 'Absensi berhasil',
            ], $isLate ? 'Absensi berhasil (terlambat)' : 'Absensi berhasil');

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Scan attendance error', [
                'event_id' => $eventId,
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal melakukan absensi');
        }
    }

    public function report(Request $request, int $eventId): JsonResponse
    {
        try {
            $user = $request->user();
            $event = Event::find($eventId);

            if (!$event) {
                return $this->notFound('Event');
            }

            if (!$user->isAdmin() && $event->created_by !== $user->id) {
                return $this->forbidden('Anda tidak memiliki akses ke laporan ini');
            }

            $statusFilter = $request->query('status');
            $tanggalMulai = $request->query('tanggal_mulai');
            $tanggalSelesai = $request->query('tanggal_selesai');

            $query = Attendance::where('event_id', $eventId)
                ->with('user:id,nama,email');

            if ($statusFilter && in_array($statusFilter, [AttendanceStatus::Valid->value, AttendanceStatus::Invalid->value, AttendanceStatus::Late->value])) {
                $query->where('status', $statusFilter);
            }

            if ($tanggalMulai) {
                $query->whereDate('scanned_at', '>=', $tanggalMulai);
            }
            if ($tanggalSelesai) {
                $query->whereDate('scanned_at', '<=', $tanggalSelesai);
            }

            $attendances = $query->orderBy('scanned_at', 'desc')
                ->paginate(min((int) ($request->query('per_page', 10)), 50));

            $summary = [
                'total_registered' => EventRegistration::where('event_id', $eventId)
                    ->where('status', RegistrationStatus::Registered->value)->count(),
                'total_attended' => Attendance::where('event_id', $eventId)
                    ->whereIn('status', [AttendanceStatus::Valid->value, AttendanceStatus::Late->value])->count(),
                'total_valid' => Attendance::where('event_id', $eventId)
                    ->where('status', AttendanceStatus::Valid->value)->count(),
                'total_late' => Attendance::where('event_id', $eventId)
                    ->where('status', AttendanceStatus::Late->value)->count(),
                'attendance_percentage' => 0,
            ];

            $registered = $summary['total_registered'] + $summary['total_attended'];
            if ($registered > 0) {
                $summary['attendance_percentage'] = round(
                    ($summary['total_attended'] / max($registered, 1)) * 100, 1
                );
            }

            return $this->success($attendances, 'Laporan absensi berhasil diambil', extra: [
                'summary' => $summary,
            ]);

        } catch (\Throwable $e) {
            Log::error('Attendance report error', [
                'event_id' => $eventId,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal mengambil laporan absensi');
        }
    }

    public function reportCsv(Request $request, int $eventId): \Illuminate\Http\Response
    {
        try {
            $user = $request->user();
            $event = Event::find($eventId);

            if (!$event) {
                return response()->json(['status' => false, 'message' => 'Event tidak ditemukan'], 404);
            }

            if (!$user->isAdmin() && $event->created_by !== $user->id) {
                return response()->json(['status' => false, 'message' => 'Akses ditolak'], 403);
            }

            $tanggalMulai = $request->query('tanggal_mulai');
            $tanggalSelesai = $request->query('tanggal_selesai');

            $attendances = Attendance::where('event_id', $eventId)
                ->with('user:id,nama,email')
                ->when($tanggalMulai, fn($q) => $q->whereDate('scanned_at', '>=', $tanggalMulai))
                ->when($tanggalSelesai, fn($q) => $q->whereDate('scanned_at', '<=', $tanggalSelesai))
                ->orderBy('scanned_at', 'desc')
                ->get();

            $filename = 'absensi_' . preg_replace('/[^A-Za-z0-9]/', '_', $event->judul) . '_' . date('Ymd') . '.csv';

            $headers = [
                'Content-Type' => 'text/csv; charset=UTF-8',
                'Content-Disposition' => 'attachment; filename="' . $filename . '"',
            ];

            $callback = function () use ($attendances, $event) {
                $handle = fopen('php://output', 'w');
                fputs($handle, "\xEF\xBB\xBF"); // BOM for Excel UTF-8

                fputcsv($handle, ['Laporan Absensi: ' . $event->judul]);
                fputcsv($handle, ['Tanggal: ' . $event->tanggal->format('d/m/Y H:i')]);
                fputcsv($handle, ['Lokasi: ' . $event->lokasi]);
                fputcsv($handle, []);

                fputcsv($handle, ['No', 'Nama', 'Email', 'Status', 'Waktu Scan']);

                foreach ($attendances as $i => $a) {
                    $statusLabel = match ($a->status) {
                        AttendanceStatus::Valid->value => 'Hadir',
                        AttendanceStatus::Late->value => 'Terlambat',
                        AttendanceStatus::Invalid->value => 'Tidak Valid',
                        default => $a->status,
                    };
                    fputcsv($handle, [
                        $i + 1,
                        $a->user->nama,
                        $a->user->email,
                        $statusLabel,
                        $a->scanned_at ? $a->scanned_at->format('d/m/Y H:i:s') : '-',
                    ]);
                }

                fclose($handle);
            };

            return response()->stream($callback, 200, $headers);
        } catch (\Throwable $e) {
            return response()->json(['status' => false, 'message' => 'Gagal mengekspor laporan'], 500);
        }
    }

    public function manualAttendance(Request $request, int $eventId): JsonResponse
    {
        try {
            $user = $request->user();
            $event = Event::find($eventId);

            if (!$event) {
                return $this->notFound('Event');
            }

            if (!$user->isAdmin() && $event->created_by !== $user->id) {
                return $this->forbidden('Anda tidak memiliki akses ke event ini');
            }

            $validated = $request->validate([
                'user_id' => 'required|exists:users,id',
                'status' => 'required|in:valid,late,absent',
            ]);

            $registration = EventRegistration::where('event_id', $eventId)
                ->where('user_id', $validated['user_id'])
                ->first();

            if (!$registration) {
                return $this->error('Peserta belum terdaftar di event ini', 400);
            }

            $result = DB::transaction(function () use ($event, $registration, $validated) {
                if ($validated['status'] === RegistrationStatus::Absent->value) {
                    Attendance::where('event_id', $event->id)
                        ->where('user_id', $validated['user_id'])
                        ->delete();

                    $registration->update(['status' => RegistrationStatus::Absent->value]);

                    return [
                        'attendance' => null,
                        'registration' => $registration->fresh(),
                    ];
                }

                $attendance = Attendance::updateOrCreate(
                    [
                        'event_id' => $event->id,
                        'user_id' => $validated['user_id'],
                    ],
                    [
                        'registration_id' => $registration->id,
                        'qr_token_id' => null,
                        'scanned_at' => now(),
                        'status' => $validated['status'],
                    ]
                );

                $registration->update(['status' => 'attended']);

                return [
                    'attendance' => $attendance->fresh(),
                    'registration' => $registration->fresh(),
                ];
            });

            Notifikasi::kirimNotifikasi(
                $registration->user,
                $validated['status'] === 'absent'
                    ? "Status kehadiran event {$event->judul}: tidak hadir"
                    : "Status kehadiran event {$event->judul} diperbarui oleh dosen",
                $event
            );

            AuditLog::log(AuditLog::ACTION_UPDATE, EventRegistration::class, $registration->id, null, [
                'event_id' => $event->id,
                'event_title' => $event->judul,
                'manual_status' => $validated['status'],
            ], $user->id);

            return $this->success($result, 'Status kehadiran berhasil diperbarui');

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Manual attendance error', [
                'event_id' => $eventId,
                'user_id' => $request->user()?->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal memperbarui kehadiran');
        }
    }

    public function checkAttendance(Request $request, int $eventId): JsonResponse
    {
        try {
            $user = $request->user();

            $attendance = Attendance::where('event_id', $eventId)
                ->where('user_id', $user->id)
                ->first();

            return $this->success([
                'has_attended' => $attendance !== null,
                'attendance' => $attendance,
            ], 'Status absensi berhasil diambil');

        } catch (\Throwable $e) {
            Log::error('Check attendance error', [
                'event_id' => $eventId,
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal mengambil status absensi');
        }
    }
}
