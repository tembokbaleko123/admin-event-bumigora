<?php

namespace App\Http\Controllers;

use App\Http\Resources\NotifikasiResource;
use App\Models\Notifikasi;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class NotifikasiController extends Controller
{
    use ApiResponse;

    /**
     * Get all notifications for authenticated user (mahasiswa)
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'per_page' => 'nullable|integer|min:1|max:50',
                'status' => 'nullable|in:all,unread,read',
            ]);

            $perPage = min((int) ($validated['per_page'] ?? 10), 50);
            $query = Notifikasi::with('event:id,judul')
                ->where('user_id', $request->user()->id);

            // Filter by status
            if (($validated['status'] ?? 'all') === 'unread') {
                $query->unread();
            } elseif (($validated['status'] ?? 'all') === 'read') {
                $query->read();
            }

            $notifikasis = $query->orderBy('created_at', 'desc')->paginate($perPage);

            // Add unread count on top
            $unreadCount = Notifikasi::where('user_id', $request->user()->id)->unread()->count();

            return $this->success(NotifikasiResource::collection($notifikasis), 'Data notifikasi berhasil diambil', extra: [
                'unread_count' => $unreadCount,
            ]);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Notification list error', [
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal mengambil data notifikasi');
        }
    }

    /**
     * Get unread notifications only
     */
    public function unread(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'per_page' => 'nullable|integer|min:1|max:50',
            ]);

            $perPage = min((int) ($validated['per_page'] ?? 10), 50);
            $notifikasis = Notifikasi::with('event:id,judul')
                ->where('user_id', $request->user()->id)
                ->unread()
                ->orderBy('created_at', 'desc')
                ->paginate($perPage);

            return $this->success(NotifikasiResource::collection($notifikasis), 'Data notifikasi belum dibaca');

        } catch (\Throwable $e) {
            Log::error('Unread notifications error', [
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal mengambil notifikasi belum dibaca');
        }
    }

    /**
     * Get count of unread notifications
     */
    public function unreadCount(Request $request): JsonResponse
    {
        try {
            $count = Notifikasi::where('user_id', $request->user()->id)
                ->unread()
                ->count();

            return $this->success(['count' => $count], 'Jumlah notifikasi belum dibaca');

        } catch (\Throwable $e) {
            return $this->serverError('Gagal menghitung notifikasi');
        }
    }

    /**
     * Mark a single notification as read
     */
    public function markAsRead(int $id, Request $request): JsonResponse
    {
        try {
            $notifikasi = Notifikasi::where('id', $id)
                ->where('user_id', $request->user()->id)
                ->first();

            if (!$notifikasi) {
                return $this->notFound('Notifikasi');
            }

            $notifikasi->markAsRead();

            return $this->success(new NotifikasiResource($notifikasi), 'Notifikasi ditandai sudah dibaca');

        } catch (\Throwable $e) {
            Log::error('Mark as read error', [
                'notification_id' => $id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal menandai notifikasi');
        }
    }

    /**
     * Mark all notifications as read
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        try {
            $updated = Notifikasi::where('user_id', $request->user()->id)
                ->unread()
                ->update(['status' => 'read', 'updated_at' => now()]);

            Log::info('All notifications marked as read', [
                'user_id' => $request->user()->id,
                'count' => $updated,
            ]);

            return $this->success(
                ['marked_read' => $updated],
                'Semua notifikasi ditandai sudah dibaca'
            );

        } catch (\Throwable $e) {
            Log::error('Mark all as read error', [
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal menandai semua notifikasi');
        }
    }

    /**
     * Delete a notification
     */
    public function destroy(int $id, Request $request): JsonResponse
    {
        try {
            $notifikasi = Notifikasi::where('id', $id)
                ->where('user_id', $request->user()->id)
                ->first();

            if (!$notifikasi) {
                return $this->notFound('Notifikasi');
            }

            $notifikasi->delete();

            return $this->success(null, 'Notifikasi berhasil dihapus');

        } catch (\Throwable $e) {
            Log::error('Notification delete error', [
                'notification_id' => $id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal menghapus notifikasi');
        }
    }
}
