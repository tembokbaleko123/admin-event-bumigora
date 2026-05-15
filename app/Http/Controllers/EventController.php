<?php

namespace App\Http\Controllers;

use App\Models\Event;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class EventController extends Controller
{
    /**
     * Ambil semua event (untuk mahasiswa, dosen, admin)
     * ALUR: User login -> pilih menu event -> sistem ambil data -> tampilkan daftar
     * Mendukung search, filter tanggal, dan pagination
     */
    public function index(Request $request): JsonResponse
    {
        $query = Event::with('creator:id,nama');

        // Search by judul
        if ($request->has('search')) {
            $query->where('judul', 'like', '%' . $request->search . '%');
        }

        // Filter by date range
        if ($request->has('tanggal_mulai')) {
            $query->where('tanggal', '>=', $request->tanggal_mulai);
        }
        if ($request->has('tanggal_selesai')) {
            $query->where('tanggal', '<=', $request->tanggal_selesai);
        }

        // Filter by lokasi
        if ($request->has('lokasi')) {
            $query->where('lokasi', 'like', '%' . $request->lokasi . '%');
        }

        $perPage = $request->input('per_page', 10);
        $events = $query->orderBy('tanggal', 'desc')->paginate($perPage);

        return response()->json([
            'status' => true,
            'message' => 'Data event berhasil diambil',
            'data' => $events,
        ]);
    }

    /**
     * Ambil detail event
     * ALUR: User pilih event -> tampilkan detail
     */
    public function show(int $id): JsonResponse
    {
        $event = Event::with('creator:id,nama')->find($id);

        if (!$event) {
            return response()->json([
                'status' => false,
                'message' => 'Event tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'status' => true,
            'message' => 'Detail event berhasil diambil',
            'data' => $event,
        ]);
    }

    /**
     * Tambah event baru (dosen & admin)
     * ALUR: Login -> pilih menu tambah event -> input data -> validasi -> simpan
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'judul' => 'required|string|max:255',
            'tanggal' => 'required|date',
            'lokasi' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
        ]);

        // Menggunakan method model Event::tambahEvent()
        $event = Event::tambahEvent($validated, $request->user());

        return response()->json([
            'status' => true,
            'message' => 'Event berhasil ditambahkan',
            'data' => $event->load('creator:id,nama'),
        ], 201);
    }

    /**
     * Update event (dosen & admin)
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $event = Event::find($id);

        if (!$event) {
            return response()->json([
                'status' => false,
                'message' => 'Event tidak ditemukan',
            ], 404);
        }

        // Dosen hanya bisa mengupdate event miliknya sendiri
        if ($request->user()->isDosen() && $event->created_by !== $request->user()->id) {
            return response()->json([
                'status' => false,
                'message' => 'Forbidden - Anda tidak memiliki akses untuk mengubah event ini',
            ], 403);
        }

        $validated = $request->validate([
            'judul' => 'sometimes|required|string|max:255',
            'tanggal' => 'sometimes|required|date',
            'lokasi' => 'sometimes|required|string|max:255',
            'deskripsi' => 'nullable|string',
        ]);

        // Menggunakan method model
        $event->updateEvent($validated);

        return response()->json([
            'status' => true,
            'message' => 'Event berhasil diperbarui',
            'data' => $event->fresh()->load('creator:id,nama'),
        ]);
    }

    /**
     * Hapus event (dosen & admin)
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $event = Event::find($id);

        if (!$event) {
            return response()->json([
                'status' => false,
                'message' => 'Event tidak ditemukan',
            ], 404);
        }

        // Dosen hanya bisa menghapus event miliknya sendiri
        if ($request->user()->isDosen() && $event->created_by !== $request->user()->id) {
            return response()->json([
                'status' => false,
                'message' => 'Forbidden - Anda tidak memiliki akses untuk menghapus event ini',
            ], 403);
        }

        // Menggunakan method model
        $event->hapusEvent();

        return response()->json([
            'status' => true,
            'message' => 'Event berhasil dihapus',
        ]);
    }
}
