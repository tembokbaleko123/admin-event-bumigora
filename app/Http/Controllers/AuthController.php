<?php

namespace App\Http\Controllers;

use App\Enums\UserRole;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Models\AuditLog;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;
use OpenApi\Attributes as OA;

/**
 * Authentication Controller
 *
 * Handles user registration, login, logout, and profile retrieval.
 *
 * @group Authentication
 */
class AuthController extends Controller
{
    use ApiResponse;

    #[OA\Post(
        path: '/api/register',
        summary: 'Register new user',
        tags: ['Authentication'],
        security: []
    )]
    #[OA\Response(response: 201, description: 'Registration successful')]
    #[OA\Response(response: 422, description: 'Validation error')]
    #[OA\Response(response: 429, description: 'Too many requests')]
    public function register(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'nama' => 'required|string|max:255',
                'email' => 'required|string|email|unique:users,email',
                'password' => [
                    'required',
                    'string',
                    'min:8',
                    'confirmed',
                    Password::min(8)
                        ->letters()
                        ->mixedCase()
                        ->numbers()
                        ->symbols(),
                ],
                'role' => 'prohibited',
            ]);

            $validated['role'] = UserRole::Mahasiswa->value;
            $user = User::register($validated);
            $tokenData = $user->createTokenWithExpiry('auth_token');

            Log::info('User registered successfully', [
                'user_id' => $user->id,
                'email' => $user->email,
            ]);

            // Audit log for registration
            AuditLog::log(AuditLog::ACTION_CREATE, User::class, $user->id, null, [
                'role' => $user->role,
            ], $user->id);

            return $this->created([
                'user' => new UserResource($user),
                'token' => $tokenData['token'],
                'token_type' => 'Bearer',
                'expires_at' => $tokenData['expires_at'],
            ], 'Registrasi berhasil');

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Registration failed', [
                'email' => $request->email,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Registrasi gagal. Silakan coba lagi.');
        }
    }

    #[OA\Post(
        path: '/api/login',
        summary: 'User login',
        tags: ['Authentication'],
        security: []
    )]
    #[OA\Response(response: 200, description: 'Login successful')]
    #[OA\Response(response: 401, description: 'Invalid credentials')]
    #[OA\Response(response: 429, description: 'Too many requests')]
    public function login(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'email' => 'required|email',
                'password' => 'required|string',
            ]);

            $user = User::login($validated['email'], $validated['password']);

            if (!$user) {
                Log::warning('Login failed - invalid credentials', [
                    'email' => $validated['email'],
                    'ip' => $request->ip(),
                ]);

                return $this->unauthorized('Email atau password salah');
            }

            // Revoke old tokens if exists (max 3 active sessions per user)
            $user->tokens()
                ->where('name', 'auth_token')
                ->where('created_at', '<', now()->subDays(7))
                ->delete();

            // Keep only last 3 tokens
            $activeTokens = $user->tokens()
                ->where('name', 'auth_token')
                ->count();

            if ($activeTokens >= 3) {
                $user->tokens()
                    ->where('name', 'auth_token')
                    ->oldest()
                    ->first()
                    ?->delete();
            }

            $tokenData = $user->createTokenWithExpiry('auth_token');

            Log::info('User logged in successfully', [
                'user_id' => $user->id,
                'role' => $user->role,
                'ip' => $request->ip(),
            ]);

            // Audit log for successful login
            AuditLog::log(AuditLog::ACTION_LOGIN, User::class, $user->id, null, [
                'role' => $user->role,
            ], $user->id);

            return $this->success([
                'user' => new UserResource($user),
                'token' => $tokenData['token'],
                'token_type' => 'Bearer',
                'expires_at' => $tokenData['expires_at'],
            ], 'Login berhasil');

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Login error', [
                'email' => $request->email,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Login gagal. Silakan coba lagi.');
        }
    }

    #[OA\Post(
        path: '/api/logout',
        summary: 'User logout',
        tags: ['Authentication']
    )]
    #[OA\Response(response: 200, description: 'Logout successful')]
    public function logout(Request $request): JsonResponse
    {
        try {
            $user = $request->user();

            Log::info('User logged out', [
                'user_id' => $user->id,
            ]);

            // Audit log for logout
            AuditLog::log(AuditLog::ACTION_LOGOUT, User::class, $user->id, null, null, $user->id);

            $request->user()->currentAccessToken()->delete();

            return $this->success(null, 'Logout berhasil');

        } catch (\Throwable $e) {
            Log::error('Logout error', [
                'user_id' => $request->user()?->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Logout gagal');
        }
    }

    #[OA\Get(
        path: '/api/me',
        summary: 'Get current user profile',
        tags: ['Authentication']
    )]
    #[OA\Response(response: 200, description: 'User profile retrieved')]
    public function me(Request $request): JsonResponse
    {
        try {
            $user = $request->user()->loadCount([
                'events',
                'notifikasis' => fn($q) => $q->unread(),
            ]);

            return $this->success(new UserResource($user), 'Data user berhasil diambil');

        } catch (\Throwable $e) {
            Log::error('Get profile error', [
                'user_id' => $request->user()?->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal mengambil data user');
        }
    }

    public function updateProfile(Request $request): JsonResponse
    {
        try {
            $user = $request->user();

            $validated = $request->validate([
                'nama' => 'sometimes|required|string|max:255',
                'email' => 'sometimes|required|email|unique:users,email,' . $user->id,
                'current_password' => 'required_with:password|string',
                'password' => [
                    'sometimes',
                    'required',
                    'confirmed',
                    Password::min(8),
                ],
            ]);

            if (isset($validated['password'])) {
                if (!Hash::check($validated['current_password'] ?? '', $user->password)) {
                    return $this->error('Password saat ini tidak sesuai', 400);
                }
            }

            $updateData = [];
            if (array_key_exists('nama', $validated)) {
                $updateData['nama'] = $validated['nama'];
            }
            if (array_key_exists('email', $validated)) {
                $updateData['email'] = $validated['email'];
            }
            if (array_key_exists('password', $validated)) {
                $updateData['password'] = $validated['password'];
            }

            if (!empty($updateData)) {
                $user->update($updateData);
            }

            Log::info('User updated profile', [
                'user_id' => $user->id,
            ]);

            return $this->success(
                new UserResource($user),
                'Profil berhasil diperbarui'
            );

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Update profile error', [
                'user_id' => $request->user()?->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal memperbarui profil');
        }
    }
}
