<?php

namespace App\Http\Controllers;

use App\Enums\EventStatus;
use App\Enums\RegistrationStatus;
use App\Models\Event;
use App\Models\EventRegistration;
use App\Models\Notifikasi;
use App\Models\AuditLog;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class RegistrationController extends Controller
{
    use ApiResponse;

    public function register(Request $request, int $eventId): JsonResponse
    {
        try {
            $user = $request->user();

            if (!$user->isMahasiswa()) {
                return $this->forbidden('Hanya mahasiswa yang dapat mendaftar event');
            }

            $event = Event::find($eventId);

            if (!$event) {
                return $this->notFound('Event');
            }

            if ($event->status !== EventStatus::Published->value) {
                return $this->error('Event tidak tersedia untuk pendaftaran', 400);
            }

            if ($event->tanggal->isPast()) {
                return $this->error('Event sudah lewat dan tidak dapat didaftari', 400);
            }

            if ($event->batas_daftar && $event->batas_daftar->isPast()) {
                return $this->error('Pendaftaran sudah ditutup', 400);
            }

            $existing = EventRegistration::where('event_id', $eventId)
                ->where('user_id', $user->id)
                ->first();

            if ($existing) {
                if ($existing->isRegistered()) {
                    return $this->error('Anda sudah terdaftar di event ini', 400);
                }
                if ($existing->isCancelled()) {
                    return DB::transaction(function () use ($existing, $user, $event) {
                        $existing->update([
                            'status' => RegistrationStatus::Registered->value,
                            'registered_at' => now(),
                            'cancelled_at' => null,
                        ]);

                        Notifikasi::kirimNotifikasi(
                            $user,
                            "Pendaftaran ulang berhasil: Anda kembali terdaftar di event {$event->judul}",
                            $event
                        );

                        return $this->success(
                            $existing->fresh()->load('user:id,nama,email'),
                            'Pendaftaran event berhasil'
                        );
                    });
                }
                return $this->error('Anda sudah terdaftar di event ini dengan status ' . $existing->status, 400);
            }

            if ($event->kapasitas) {
                $confirmedCount = EventRegistration::where('event_id', $eventId)
                    ->whereIn('status', [RegistrationStatus::Registered->value, RegistrationStatus::Attended->value])
                    ->lockForUpdate()
                    ->count();

                if ($confirmedCount >= $event->kapasitas) {
                    return $this->error('Maaf, kuota event sudah penuh', 400);
                }
            }

            $registration = DB::transaction(function () use ($eventId, $user, $event) {
                $registration = EventRegistration::create([
                    'event_id' => $eventId,
                    'user_id' => $user->id,
                    'status' => RegistrationStatus::Registered->value,
                    'registered_at' => now(),
                ]);

                Notifikasi::kirimNotifikasi(
                    $user,
                    "Pendaftaran berhasil: Anda terdaftar di event {$event->judul} pada {$event->tanggal->format('d M Y H:i')} WIB",
                    $event
                );

                // Audit log for registration
                AuditLog::log(AuditLog::ACTION_REGISTER, EventRegistration::class, $registration->id, null, [
                    'event_id' => $eventId,
                    'event_title' => $event->judul,
                ]);

                return $registration;
            });

            return $this->created(
                $registration->load('user:id,nama,email'),
                'Pendaftaran event berhasil'
            );

        } catch (\Throwable $e) {
            Log::error('Event registration error', [
                'event_id' => $eventId,
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal mendaftar event');
        }
    }

    public function cancel(Request $request, int $eventId): JsonResponse
    {
        try {
            $user = $request->user();

            $registration = EventRegistration::where('event_id', $eventId)
                ->where('user_id', $user->id)
                ->where('status', RegistrationStatus::Registered->value)
                ->first();

            if (!$registration) {
                return $this->error('Anda tidak terdaftar di event ini', 400);
            }

            $registration->load('event');
            $registration->update([
                'status' => RegistrationStatus::Cancelled->value,
                'cancelled_at' => now(),
            ]);

            Notifikasi::kirimNotifikasi(
                $user,
                "Pendaftaran dibatalkan: Pendaftaran Anda untuk event {$registration->event->judul} telah dibatalkan",
                $registration->event
            );

            return $this->success(null, 'Pendaftaran event berhasil dibatalkan');

        } catch (\Throwable $e) {
            Log::error('Event cancel registration error', [
                'event_id' => $eventId,
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal membatalkan pendaftaran');
        }
    }

    public function participants(Request $request, int $eventId): JsonResponse
    {
        try {
            $user = $request->user();
            $event = Event::find($eventId);

            if (!$event) {
                return $this->notFound('Event');
            }

            if (!$user->isAdmin() && $event->created_by !== $user->id) {
                return $this->forbidden('Anda tidak memiliki akses ke peserta event ini');
            }

            $statusFilter = $request->query('status');

            $query = EventRegistration::where('event_id', $eventId)
                ->with('user:id,nama,email');

            if ($statusFilter && in_array($statusFilter, [RegistrationStatus::Registered->value, RegistrationStatus::Cancelled->value, RegistrationStatus::Attended->value, RegistrationStatus::Absent->value])) {
                $query->where('status', $statusFilter);
            }

            $participants = $query->orderBy('created_at', 'desc')->paginate(
                min((int) ($request->query('per_page', 10)), 50)
            );

            return $this->success($participants, 'Data peserta berhasil diambil');

        } catch (\Throwable $e) {
            Log::error('Event participants error', [
                'event_id' => $eventId,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal mengambil data peserta');
        }
    }

    public function myEvents(Request $request): JsonResponse
    {
        try {
            $user = $request->user();

            $registrations = EventRegistration::where('user_id', $user->id)
                ->with(['event' => fn($q) => $q->with('creator:id,nama')->withCount('confirmedRegistrations')])
                ->orderBy('created_at', 'desc')
                ->paginate(min((int) ($request->query('per_page', 10)), 50));

            return $this->success($registrations, 'Data event saya berhasil diambil');

        } catch (\Throwable $e) {
            Log::error('My events error', [
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal mengambil data event saya');
        }
    }

    public function checkRegistration(Request $request, int $eventId): JsonResponse
    {
        try {
            $user = $request->user();

            $registration = EventRegistration::where('event_id', $eventId)
                ->where('user_id', $user->id)
                ->first();

            return $this->success(
                [
                    'is_registered' => $registration ? $registration->isRegistered() : false,
                    'status' => $registration?->status,
                    'registration' => $registration,
                ],
                'Status pendaftaran berhasil diambil'
            );

        } catch (\Throwable $e) {
            Log::error('Check registration error', [
                'event_id' => $eventId,
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal mengambil status pendaftaran');
        }
    }
}
