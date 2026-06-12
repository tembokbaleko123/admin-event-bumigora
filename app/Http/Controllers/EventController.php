<?php

namespace App\Http\Controllers;

use App\Enums\EventStatus;
use App\Http\Resources\EventResource;
use App\Models\Event;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use OpenApi\Attributes as OA;

/**
 * Event Controller
 *
 * Handles event CRUD operations and viewing.
 * Supports search, date filtering, location and category filtering, and pagination.
 *
 * @group Events
 */
class EventController extends Controller
{
    use ApiResponse;

    #[OA\Get(
        path: '/api/events',
        summary: 'List all events',
        tags: ['Events']
    )]
    public function index(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'search' => 'nullable|string|max:255',
                'tanggal_mulai' => 'nullable|date',
                'tanggal_selesai' => 'nullable|date|after_or_equal:tanggal_mulai',
                'lokasi' => 'nullable|string|max:255',
                'kategori' => 'nullable|in:KULIAH,WORKSHOP,SEMINAR,MEETING,UKM',
                'status' => 'nullable|in:pending,draft,published,rejected,cancelled,completed',
                'per_page' => 'nullable|integer|min:1|max:50',
                'sort_by' => 'nullable|in:tanggal,judul,lokasi,created_at',
                'sort_order' => 'nullable|in:asc,desc',
            ]);

            $user = $request->user();
            $query = Event::select(['id', 'judul', 'tanggal', 'tanggal_selesai', 'batas_daftar', 'lokasi', 'kategori', 'status', 'kapasitas', 'gambar', 'created_by', 'created_at', 'updated_at'])
                ->with('creator:id,nama')
                ->search($validated['search'] ?? null)
                ->withCount('confirmedRegistrations');

            if ($user->isMahasiswa()) {
                $query->where('status', EventStatus::Published->value);
            } elseif ($user->isDosen()) {
                $query->where(function ($q) use ($user) {
                    $q->where('status', EventStatus::Published->value)
                      ->orWhere('created_by', $user->id);
                });
            }

            if (isset($validated['tanggal_mulai'])) {
                $query->whereDate('tanggal', '>=', $validated['tanggal_mulai']);
            }

            if (isset($validated['tanggal_selesai'])) {
                $query->whereDate('tanggal', '<=', $validated['tanggal_selesai']);
            }

            if (isset($validated['lokasi'])) {
                $query->where('lokasi', 'like', $validated['lokasi'] . '%');
            }

            if (isset($validated['kategori'])) {
                $query->kategori($validated['kategori']);
            }

            if (isset($validated['status'])) {
                $query->where('status', $validated['status']);
            }

            $sortBy = $validated['sort_by'] ?? 'tanggal';
            $sortOrder = $validated['sort_order'] ?? 'desc';
            $perPage = min((int) ($validated['per_page'] ?? 10), 50);

            $cacheKey = 'events_list_' . $user->id . '_' . md5(json_encode($validated)) . '_page_' . request('page', 1);
            $events = Cache::remember($cacheKey, 300, function () use ($query, $sortBy, $sortOrder, $perPage) {
                return $query->orderBy($sortBy, $sortOrder)->paginate($perPage);
            });

            return $this->success(EventResource::collection($events), 'Data event berhasil diambil');

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Event list error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil data event');
        }
    }

    #[OA\Get(
        path: '/api/events/{id}',
        summary: 'Get event details',
        tags: ['Events']
    )]
    public function show(Request $request, int $id): JsonResponse
    {
        try {
            $event = Event::with([
                'creator:id,nama,email',
                'notifikasis' => fn($q) => $q->select('id', 'event_id', 'status', 'created_at')->limit(10),
            ])->withCount(['registrations as total_pendaftar', 'activeRegistrations as pendaftar_aktif', 'confirmedRegistrations as confirmed_registrations_count'])
              ->find($id);

            if (!$event) {
                return $this->notFound('Event');
            }

            $user = $request->user();
            if ($user->isMahasiswa() && $event->status !== EventStatus::Published->value) {
                return $this->forbidden('Event belum tersedia untuk mahasiswa');
            }
            if ($user->isDosen() && $event->status !== EventStatus::Published->value && $event->created_by !== $user->id) {
                return $this->forbidden('Anda tidak memiliki akses ke event ini');
            }

            // Increment view counter (if we add it later)
            // $event->increment('views');

            return $this->success(new EventResource($event), 'Detail event berhasil diambil');

        } catch (\Throwable $e) {
            Log::error('Event detail error', ['event_id' => $id, 'error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil detail event');
        }
    }

    #[OA\Post(
        path: '/api/events',
        summary: 'Create new event',
        tags: ['Events']
    )]
    public function store(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'judul' => 'required|string|max:255',
                'tanggal' => 'required|date|after_or_equal:now',
                'tanggal_selesai' => 'nullable|date|after:tanggal',
                'batas_daftar' => 'nullable|date|before_or_equal:tanggal|after_or_equal:now',
                'lokasi' => 'required|string|max:255',
                'deskripsi' => 'nullable|string',
                'kategori' => 'nullable|in:KULIAH,WORKSHOP,SEMINAR,MEETING,UKM',
                'kapasitas' => 'nullable|integer|min:1',
                'gambar' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            ]);

            $event = Event::tambahEvent($validated, $request->user());

            Log::info('Event created', [
                'event_id' => $event->id,
                'judul' => $event->judul,
                'created_by' => $request->user()->id,
            ]);

            return $this->created(
                new EventResource($event->load('creator:id,nama')->loadCount('confirmedRegistrations')),
                'Event "' . $event->judul . '" berhasil ditambahkan'
            );

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Event create error', [
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal menambahkan event');
        }
    }

    #[OA\Put(
        path: '/api/events/{id}',
        summary: 'Update event',
        tags: ['Events']
    )]
    public function update(Request $request, int $id): JsonResponse
    {
        try {
            $event = Event::find($id);

            if (!$event) {
                return $this->notFound('Event');
            }

            // Authorization: Only admin can update events created by others
            if (!$request->user()->isAdmin() && $event->created_by !== $request->user()->id) {
                return $this->forbidden('Anda tidak memiliki akses untuk mengubah event ini');
            }

            $validated = $request->validate([
                'judul' => 'sometimes|required|string|max:255',
                'tanggal' => 'sometimes|required|date|after_or_equal:now',
                'tanggal_selesai' => 'nullable|date|after:tanggal',
                'batas_daftar' => 'nullable|date|before_or_equal:tanggal|after_or_equal:now',
                'lokasi' => 'sometimes|required|string|max:255',
                'deskripsi' => 'nullable|string',
                'kategori' => 'nullable|in:KULIAH,WORKSHOP,SEMINAR,MEETING,UKM',
                'kapasitas' => 'nullable|integer|min:1',
                'status' => 'nullable|in:pending,draft,published,rejected,cancelled,completed',
                'gambar' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
                'hapus_gambar' => 'nullable|boolean',
            ]);

            if (array_key_exists('status', $validated) && !$request->user()->isAdmin()) {
                return $this->forbidden('Hanya admin yang dapat mengubah status event');
            }

            // If no specific fields provided for update, skip
            if (empty($validated) && !$request->hasAny(['gambar', 'hapus_gambar'])) {
                return $this->validationError(['fields' => 'Tidak ada data yang dikirim untuk diperbarui']);
            }

            $event->updateEvent($validated);

            Log::info('Event updated', [
                'event_id' => $event->id,
                'updated_by' => $request->user()->id,
            ]);

            return $this->success(
                new EventResource($event->fresh()->load('creator:id,nama')->loadCount('confirmedRegistrations')),
                'Event "' . $event->judul . '" berhasil diperbarui'
            );

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Event update error', [
                'event_id' => $id,
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal memperbarui event');
        }
    }

    #[OA\Delete(
        path: '/api/events/{id}',
        summary: 'Delete event',
        tags: ['Events']
    )]
    public function destroy(Request $request, int $id): JsonResponse
    {
        try {
            $event = Event::find($id);

            if (!$event) {
                return $this->notFound('Event');
            }

            // Authorization: Only admin can delete events created by others
            if (!$request->user()->isAdmin() && $event->created_by !== $request->user()->id) {
                return $this->forbidden('Anda tidak memiliki akses untuk menghapus event ini');
            }

            $judul = $event->judul;
            $event->hapusEvent();

            Log::info('Event deleted', [
                'event_id' => $id,
                'judul' => $judul,
                'deleted_by' => $request->user()->id,
            ]);

            return $this->success(null, 'Event "' . $judul . '" berhasil dihapus');

        } catch (\Throwable $e) {
            Log::error('Event delete error', [
                'event_id' => $id,
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal menghapus event');
        }
    }

    public function approve(Request $request, int $id): JsonResponse
    {
        try {
            $event = Event::with('creator:id,nama,email')->find($id);

            if (!$event) {
                return $this->notFound('Event');
            }

            DB::transaction(function () use ($event) {
                $wasPublished = $event->status === EventStatus::Published->value;
                $event->update(['status' => EventStatus::Published->value]);

                if (!$wasPublished && $event->creator) {
                    \App\Models\Notifikasi::kirimNotifikasi(
                        $event->creator,
                        "Event disetujui admin: {$event->judul}",
                        $event
                    );
                }

                if (!$wasPublished) {
                    \App\Models\Notifikasi::kirimNotifikasiKeRole(
                        \App\Enums\UserRole::Mahasiswa->value,
                        "Event baru: {$event->judul} pada {$event->tanggal->format('d M Y')} di {$event->lokasi}",
                        $event
                    );
                }
            });

            Log::info('Event approved', [
                'event_id' => $event->id,
                'approved_by' => $request->user()->id,
            ]);

            return $this->success(new EventResource($event->fresh()->load('creator:id,nama')->loadCount('confirmedRegistrations')), 'Event berhasil disetujui');

        } catch (\Throwable $e) {
            Log::error('Event approve error', [
                'event_id' => $id,
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal menyetujui event');
        }
    }

    public function reject(Request $request, int $id): JsonResponse
    {
        try {
            $event = Event::with('creator:id,nama,email')->find($id);

            if (!$event) {
                return $this->notFound('Event');
            }

            DB::transaction(function () use ($event) {
                $wasRejected = $event->status === EventStatus::Rejected->value;
                $event->update(['status' => EventStatus::Rejected->value]);

                if (!$wasRejected && $event->creator) {
                    \App\Models\Notifikasi::kirimNotifikasi(
                        $event->creator,
                        "Event ditolak admin: {$event->judul}",
                        $event
                    );
                }
            });

            Log::info('Event rejected', [
                'event_id' => $event->id,
                'rejected_by' => $request->user()->id,
            ]);

            return $this->success(new EventResource($event->fresh()->load('creator:id,nama')->loadCount('confirmedRegistrations')), 'Event berhasil ditolak');

        } catch (\Throwable $e) {
            Log::error('Event reject error', [
                'event_id' => $id,
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal menolak event');
        }
    }
}
