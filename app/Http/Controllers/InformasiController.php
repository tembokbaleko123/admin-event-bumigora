<?php

namespace App\Http\Controllers;

use App\Models\Informasi;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class InformasiController extends Controller
{
    /**
     * Ambil semua informasi (untuk mahasiswa, dosen, admin)
     * ALUR: User login -> pilih menu informasi -> sistem ambil data -> tampilkan
     * Mendukung search dan pagination
     */
    public function index(Request $request): JsonResponse
    {
        $query = Informasi::with('creator:id,nama');

        // Search by judul
        if ($request->has('search')) {
            $query->where('judul', 'like', '%' . $request->search . '%');
        }

        $perPage = $request->input('per_page', 10);
        $informasis = $query->orderBy('tanggal', 'desc')->paginate($perPage);

        return response()->json([
            'status' => true,
            'message' => 'Data informasi berhasil diambil',
            'data' => $informasis,
        ]);
    }

    /**
     * Ambil detail informasi
     */
    public function show(int $id): JsonResponse
    {
        $informasi = Informasi::with('creator:id,nama')->find($id);

        if (!$informasi) {
            return response()->json([
                'status' => false,
                'message' => 'Informasi tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'status' => true,
            'message' => 'Detail informasi berhasil diambil',
            'data' => $informasi,
        ]);
    }

    /**
     * Tambah informasi baru (admin only)
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'judul' => 'required|string|max:255',
            'isi' => 'required|string',
            'tanggal' => 'required|date',
        ]);

        // Menggunakan method model Informasi::tambahInformasi()
        $informasi = Informasi::tambahInformasi($validated, $request->user());

        return response()->json([
            'status' => true,
            'message' => 'Informasi berhasil ditambahkan',
            'data' => $informasi->load('creator:id,nama'),
        ], 201);
    }

    /**
     * Update informasi (admin only)
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $informasi = Informasi::find($id);

        if (!$informasi) {
            return response()->json([
                'status' => false,
                'message' => 'Informasi tidak ditemukan',
            ], 404);
        }

        $validated = $request->validate([
            'judul' => 'sometimes|required|string|max:255',
            'isi' => 'sometimes|required|string',
            'tanggal' => 'sometimes|required|date',
        ]);

        // Menggunakan method model
        $informasi->updateInformasi($validated);

        return response()->json([
            'status' => true,
            'message' => 'Informasi berhasil diperbarui',
            'data' => $informasi->fresh()->load('creator:id,nama'),
        ]);
    }

    /**
     * Hapus informasi (admin only)
     */
    public function destroy(int $id): JsonResponse
    {
        $informasi = Informasi::find($id);

        if (!$informasi) {
            return response()->json([
                'status' => false,
                'message' => 'Informasi tidak ditemukan',
            ], 404);
        }

        // Menggunakan method model
        $informasi->hapusInformasi();

        return response()->json([
            'status' => true,
            'message' => 'Informasi berhasil dihapus',
        ]);
    }
}
