<?php

namespace App\Http\Controllers;

use App\Enums\AttendanceStatus;
use App\Enums\EventStatus;
use App\Enums\UserRole;
use App\Http\Resources\EventResource;
use App\Models\Event;
use App\Models\Attendance;
use App\Models\AuditLog;
use App\Models\Bookmark;
use App\Models\EventRegistration;
use App\Models\Notifikasi;
use App\Models\User;
use App\Models\Informasi;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AnalyticsController extends Controller
{
    use ApiResponse;

    public function dashboardOverview(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            $now = now();
            $eventScope = Event::query();

            if ($user->isDosen()) {
                $eventScope->where('created_by', $user->id);
            } elseif ($user->isMahasiswa()) {
                $eventScope->where('status', EventStatus::Published->value);
            }

            $eventsTotal = (clone $eventScope)->count();
            $eventsToday = (clone $eventScope)->whereDate('tanggal', $now->toDateString())->count();
            $eventsUpcoming = (clone $eventScope)->where('tanggal', '>=', $now)->count();

            $overview = [
                'role' => $user->role,
                'server_time' => $now->toIso8601String(),
                'events' => [
                    'total' => $eventsTotal,
                    'today' => $eventsToday,
                    'upcoming' => $eventsUpcoming,
                ],
                'notifications' => [
                    'unread' => Notifikasi::where('user_id', $user->id)->unread()->count(),
                ],
            ];

            if ($user->isMahasiswa()) {
                $registeredEvents = EventRegistration::where('user_id', $user->id)->registered()->count();
                $attendedEvents = Attendance::where('user_id', $user->id)
                    ->whereIn('status', ['valid', 'late'])
                    ->count();

                $nextEvent = Event::select('id', 'judul', 'tanggal', 'lokasi', 'kategori')
                    ->whereHas('activeRegistrations', fn($query) => $query->where('user_id', $user->id))
                    ->where('tanggal', '>=', $now)
                    ->orderBy('tanggal')
                    ->first();

                $overview['student'] = [
                    'registered_events' => $registeredEvents,
                    'attended_events' => $attendedEvents,
                    'bookmarks' => Bookmark::where('user_id', $user->id)->count(),
                    'next_registered_event' => $nextEvent,
                ];
            }

            if ($user->isDosen()) {
                $lecturerEventIds = Event::where('created_by', $user->id)->pluck('id');
                $totalParticipants = EventRegistration::whereIn('event_id', $lecturerEventIds)->registered()->count();
                $totalPresent = Attendance::whereIn('event_id', $lecturerEventIds)
                    ->whereIn('status', ['valid', 'late'])
                    ->count();

                $overview['lecturer'] = [
                    'my_events' => $eventsTotal,
                    'pending_events' => Event::where('created_by', $user->id)->where('status', EventStatus::Pending->value)->count(),
                    'total_participants' => $totalParticipants,
                    'total_present' => $totalPresent,
                    'next_event' => Event::select('id', 'judul', 'tanggal', 'lokasi', 'kategori')
                        ->where('created_by', $user->id)
                        ->where('tanggal', '>=', $now)
                        ->orderBy('tanggal')
                        ->first(),
                ];
            }

            if ($user->isAdmin()) {
                $overview['admin'] = [
                    'users_total' => User::count(),
                    'mahasiswa_total' => User::where('role', UserRole::Mahasiswa->value)->count(),
                    'dosen_total' => User::where('role', UserRole::Dosen->value)->count(),
                    'informasi_total' => Informasi::count(),
                    'pending_events' => Event::where('status', EventStatus::Pending->value)->count(),
                    'audit_logs_today' => AuditLog::whereDate('created_at', $now->toDateString())->count(),
                ];
            }

            return $this->success($overview, 'Dashboard overview berhasil diambil');

        } catch (\Throwable $e) {
            Log::error('Dashboard overview error', [
                'user_id' => $request->user()?->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal mengambil dashboard overview');
        }
    }

    public function adminSummary(): JsonResponse
    {
        try {
            $totalUsers = User::count();
            $totalMahasiswa = User::where('role', UserRole::Mahasiswa->value)->count();
            $totalDosen = User::where('role', UserRole::Dosen->value)->count();
            $totalAdmin = User::where('role', UserRole::Admin->value)->count();
            $totalEvents = Event::count();
            $totalInformasi = Informasi::count();

            // Event paling populer (top 5 by registration)
            $popularEvents = Event::withCount(['activeRegistrations as pendaftar'])
                ->orderByDesc('pendaftar')
                ->limit(5)
                ->get(['id', 'judul', 'tanggal', 'lokasi']);

            // Grafik partisipasi per kategori
            $categoryStats = Event::select('kategori', DB::raw('count(*) as total'))
                ->whereNotNull('kategori')
                ->groupBy('kategori')
                ->orderByDesc('total')
                ->get();

            // Grafik pertumbuhan event per bulan (6 bulan terakhir)
            $eventMonthly = Event::select(
                DB::raw("DATE_FORMAT(created_at, '%Y-%m') as bulan"),
                DB::raw('count(*) as total')
            )
                ->where('created_at', '>=', now()->subMonths(6))
                ->groupBy('bulan')
                ->orderBy('bulan')
                ->get();

            // Rata-rata kehadiran
            $totalRegistrations = EventRegistration::count();
            $totalAttended = Attendance::whereIn('status', [AttendanceStatus::Valid->value, AttendanceStatus::Late->value])->count();
            $avgAttendance = $totalRegistrations > 0
                ? round(($totalAttended / $totalRegistrations) * 100, 1)
                : 0;

            return $this->success([
                'users' => [
                    'total' => $totalUsers,
                    'mahasiswa' => $totalMahasiswa,
                    'dosen' => $totalDosen,
                    'admin' => $totalAdmin,
                ],
                'events' => [
                    'total' => $totalEvents,
                    'pending' => Event::where('status', EventStatus::Pending->value)->count(),
                ],
                'informasi' => [
                    'total' => $totalInformasi,
                ],
                'attendance' => [
                    'total_registrations' => $totalRegistrations,
                    'total_attended' => $totalAttended,
                    'avg_percentage' => $avgAttendance,
                ],
                'popular_events' => $popularEvents,
                'category_stats' => $categoryStats,
                'event_monthly' => $eventMonthly,
            ]);

        } catch (\Throwable $e) {
            Log::error('Admin analytics summary error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil data analytics');
        }
    }

    public function adminEvents(Request $request): JsonResponse
    {
        try {
            $events = Event::withCount([
                'registrations as total_pendaftar',
                'activeRegistrations as pendaftar_aktif',
            ])
                ->withExists([
                    'attendances as sudah_hadir' => function ($q) {
                        $q->whereIn('status', [AttendanceStatus::Valid->value, AttendanceStatus::Late->value]);
                    }
                ])
                ->orderByDesc('tanggal')
                ->paginate(min((int) ($request->query('per_page', 10)), 50));

            return $this->success($events, 'Data analytics event berhasil diambil');

        } catch (\Throwable $e) {
            Log::error('Admin analytics events error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil data analytics event');
        }
    }

    public function lecturerEvents(Request $request): JsonResponse
    {
        try {
            $user = $request->user();

            $events = Event::where('created_by', $user->id)
                ->withCount([
                    'registrations as total_pendaftar',
                    'activeRegistrations as pendaftar_aktif',
                ])
                ->orderByDesc('tanggal')
                ->paginate(min((int) ($request->query('per_page', 10)), 50));

            $summary = [
                'total_events' => Event::where('created_by', $user->id)->count(),
                'total_pendaftar' => EventRegistration::whereIn('event_id', function ($q) use ($user) {
                    $q->select('id')->from('events')->where('created_by', $user->id);
                })->count(),
                'total_hadir' => Attendance::whereIn('event_id', function ($q) use ($user) {
                    $q->select('id')->from('events')->where('created_by', $user->id);
                })->whereIn('status', [AttendanceStatus::Valid->value, AttendanceStatus::Late->value])->count(),
            ];

            return $this->success($events, 'Data analytics dosen berhasil diambil', extra: [
                'summary' => $summary,
            ]);

        } catch (\Throwable $e) {
            Log::error('Lecturer analytics error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil data analytics dosen');
        }
    }

    public function eventDetail(int $eventId): JsonResponse
    {
        try {
            $event = Event::withCount([
                'registrations as total_pendaftar',
                'activeRegistrations as pendaftar_aktif',
                'attendances as total_hadir' => fn($q) => $q->whereIn('status', [AttendanceStatus::Valid->value, AttendanceStatus::Late->value]),
                'attendances as total_tepat' => fn($q) => $q->where('status', AttendanceStatus::Valid->value),
                'attendances as total_terlambat' => fn($q) => $q->where('status', AttendanceStatus::Late->value),
            ])->find($eventId);

            if (!$event) {
                return $this->notFound('Event');
            }

            $attendanceRate = $event->total_pendaftar > 0
                ? round(($event->total_hadir / $event->total_pendaftar) * 100, 1)
                : 0;

            return $this->success([
                'event' => new EventResource($event->load('creator:id,nama')),
                'attendance_rate' => $attendanceRate,
                'kapasitas' => $event->kapasitas,
                'sisa_kuota' => $event->kapasitas
                    ? max(0, $event->kapasitas - $event->pendaftar_aktif)
                    : null,
            ]);

        } catch (\Throwable $e) {
            Log::error('Event detail analytics error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil detail analytics event');
        }
    }
}
