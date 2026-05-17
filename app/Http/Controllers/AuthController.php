<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class AuthController extends Controller
{
    /**
     * Register user baru
     * ALUR: User buka aplikasi -> input email & password -> jika valid -> registrasi berhasil
     */
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'email' => 'required|string|email|unique:users,email',
            'password' => 'required|string|min:6|confirmed',
            'role' => 'in:mahasiswa',
        ]);

        // Hanya role mahasiswa yang boleh daftar via endpoint publik
        $validated['role'] = 'mahasiswa';

        // Menggunakan method model User::register()
        $user = User::register($validated);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'Registrasi berhasil',
            'data' => [
                'user' => $user,
                'token' => $token,
            ],
        ], 201);
    }

    /**
     * Login user
     * ALUR: User buka aplikasi -> tampil halaman login -> input email & password
     *       -> jika valid -> masuk dashboard, jika tidak -> tampilkan error
     */
    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // Menggunakan method model User::login()
        $user = User::login($validated['email'], $validated['password']);

        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'Email atau password salah',
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'Login berhasil',
            'data' => [
                'user' => $user,
                'token' => $token,
            ],
        ]);
    }

    /**
     * Logout user (hapus token)
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => true,
            'message' => 'Logout berhasil',
        ]);
    }

    /**
     * Ambil data user yang sedang login
     */
    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'status' => true,
            'message' => 'Data user berhasil diambil',
            'data' => $request->user(),
        ]);
    }
}
