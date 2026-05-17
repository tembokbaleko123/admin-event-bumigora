<?php

namespace App\Http\Controllers;

use App\Models\Notifikasi;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class NotifikasiController extends Controller
{
    /**
     * Ambil semua notifikasi user yang login (mahasiswa)
     * ALUR: User login -> terima notifikasi event
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'per_page' => 'nullable|integer|min:1|max:50',
        ]);

        $perPage = $request->integer('per_page', 10);
        $notifikasis = Notifikasi::with('event:id,judul')
            ->where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);

        return response()->json([
            'status' => true,
            'message' => 'Data notifikasi berhasil diambil',
            'data' => $notifikasis,
        ]);
    }

    /**
     * Ambil notifikasi yang belum dibaca (unread)
     */
    public function unread(Request $request): JsonResponse
    {
        $request->validate([
            'per_page' => 'nullable|integer|min:1|max:50',
        ]);

        $perPage = $request->integer('per_page', 10);
        $notifikasis = Notifikasi::with('event:id,judul')
            ->where('user_id', $request->user()->id)
            ->unread()
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);

        return response()->json([
            'status' => true,
            'message' => 'Data notifikasi belum dibaca',
            'data' => $notifikasis,
        ]);
    }

    /**
     * Tandai notifikasi sebagai sudah dibaca
     */
    public function markAsRead(int $id, Request $request): JsonResponse
    {
        $notifikasi = Notifikasi::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$notifikasi) {
            return response()->json([
                'status' => false,
                'message' => 'Notifikasi tidak ditemukan',
            ], 404);
        }

        $notifikasi->markAsRead();

        return response()->json([
            'status' => true,
            'message' => 'Notifikasi ditandai sudah dibaca',
            'data' => $notifikasi,
        ]);
    }

    /**
     * Tandai semua notifikasi sebagai sudah dibaca
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        Notifikasi::where('user_id', $request->user()->id)
            ->unread()
            ->update(['status' => 'read']);

        return response()->json([
            'status' => true,
            'message' => 'Semua notifikasi ditandai sudah dibaca',
        ]);
    }

    /**
     * Hitung jumlah notifikasi yang belum dibaca
     */
    public function unreadCount(Request $request): JsonResponse
    {
        $count = Notifikasi::where('user_id', $request->user()->id)
            ->unread()
            ->count();

        return response()->json([
            'status' => true,
            'message' => 'Jumlah notifikasi belum dibaca',
            'data' => [
                'count' => $count,
            ],
        ]);
    }

    /**
     * Hapus notifikasi
     */
    public function destroy(int $id, Request $request): JsonResponse
    {
        $notifikasi = Notifikasi::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$notifikasi) {
            return response()->json([
                'status' => false,
                'message' => 'Notifikasi tidak ditemukan',
            ], 404);
        }

        $notifikasi->delete();

        return response()->json([
            'status' => true,
            'message' => 'Notifikasi berhasil dihapus',
        ]);
    }
}
