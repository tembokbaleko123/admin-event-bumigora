<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    /**
     * Ambil semua user (admin only)
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'per_page' => 'nullable|integer|min:1|max:50',
        ]);

        $perPage = $request->integer('per_page', 10);
        $users = User::select('id', 'nama', 'email', 'role', 'created_at')
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);

        return response()->json([
            'status' => true,
            'message' => 'Data user berhasil diambil',
            'data' => $users,
        ]);
    }

    /**
     * Ambil detail user (admin only)
     */
    public function show(int $id): JsonResponse
    {
        $user = User::select('id', 'nama', 'email', 'role', 'created_at')->find($id);

        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'User tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'status' => true,
            'message' => 'Detail user berhasil diambil',
            'data' => $user,
        ]);
    }

    /**
     * Update user (admin only)
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'User tidak ditemukan',
            ], 404);
        }

        $validated = $request->validate([
            'nama' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|email|unique:users,email,' . $id,
            'password' => 'sometimes|required|string|min:6',
            'role' => 'sometimes|required|in:mahasiswa,dosen,admin',
        ]);

        if ($user->id === $request->user()->id && isset($validated['role']) && $validated['role'] !== $user->role) {
            return response()->json([
                'status' => false,
                'message' => 'Role akun yang sedang digunakan tidak dapat diubah',
            ], 403);
        }

        // Password akan di-hash otomatis oleh 'hashed' cast di model User
        // Tidak perlu Hash::make() manual untuk menghindari double hashing

        $user->update($validated);

        return response()->json([
            'status' => true,
            'message' => 'User berhasil diperbarui',
            'data' => $user->only(['id', 'nama', 'email', 'role', 'created_at']),
        ]);
    }

    /**
     * Hapus user (admin only)
     */
    public function destroy(int $id): JsonResponse
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'User tidak ditemukan',
            ], 404);
        }

        // Prevent admin from deleting themselves
        if ($user->id === auth()->id()) {
            return response()->json([
                'status' => false,
                'message' => 'Tidak dapat menghapus akun sendiri',
            ], 403);
        }

        $user->delete();

        return response()->json([
            'status' => true,
            'message' => 'User berhasil dihapus',
        ]);
    }
}
