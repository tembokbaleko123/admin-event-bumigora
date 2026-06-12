<?php

namespace App\Http\Controllers;

use App\Http\Resources\UserResource;
use App\Models\AuditLog;
use App\Models\Notifikasi;
use App\Models\User;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class UserController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'search' => 'nullable|string|max:255',
                'role' => 'nullable|in:mahasiswa,dosen,admin',
                'per_page' => 'nullable|integer|min:1|max:50',
                'sort_by' => 'nullable|in:nama,email,role,created_at',
                'sort_order' => 'nullable|in:asc,desc',
            ]);

            $query = User::query()
                ->select('id', 'nama', 'email', 'role', 'created_at')
                ->search($validated['search'] ?? null)
                ->role($validated['role'] ?? null);

            $sortBy = $validated['sort_by'] ?? 'created_at';
            $sortOrder = $validated['sort_order'] ?? 'desc';
            $perPage = min((int) ($validated['per_page'] ?? 10), 50);

            $users = $query->orderBy($sortBy, $sortOrder)->paginate($perPage);

            return $this->success(UserResource::collection($users), 'Data user berhasil diambil');

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('User list error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil data user');
        }
    }

    public function show(int $id): JsonResponse
    {
        try {
            $user = User::select('id', 'nama', 'email', 'role', 'created_at', 'updated_at')
                ->withCount(['events', 'informasis'])
                ->find($id);

            if (!$user) {
                return $this->notFound('User');
            }

            return $this->success(new UserResource($user), 'Detail user berhasil diambil');

        } catch (\Throwable $e) {
            Log::error('User detail error', ['id' => $id, 'error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil detail user');
        }
    }

    public function store(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'nama' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'password' => 'required|string|min:8',
                'role' => 'sometimes|in:admin,mahasiswa,dosen',
            ]);

            $user = User::register($validated);

            $tokenData = $user->createTokenWithExpiry('api-token');

            AuditLog::log(AuditLog::ACTION_CREATE, User::class, $user->id, null, [
                'nama' => $user->nama,
                'email' => $user->email,
                'role' => $user->role,
            ]);

            return $this->created(
                UserResource::make($user)->additional([
                    'token' => $tokenData['token'],
                    'token_expires_at' => $tokenData['expires_at'],
                ]),
                'Pengguna berhasil ditambahkan'
            );

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Create user error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal menambahkan pengguna');
        }
    }

    public function update(Request $request, int $id): JsonResponse
    {
        try {
            $user = User::withCount(['events', 'informasis'])->find($id);

            if (!$user) {
                return $this->notFound('User');
            }

            $validated = $request->validate([
                'nama' => 'sometimes|required|string|max:255',
                'email' => 'sometimes|required|email|unique:users,email,' . $id,
                'password' => 'sometimes|required|string|min:8',
                'role' => 'sometimes|required|in:mahasiswa,dosen,admin',
            ]);

            // Cannot change own role
            if ($user->id === $request->user()->id && isset($validated['role']) && $validated['role'] !== $user->role) {
                return $this->forbidden('Role akun yang sedang digunakan tidak dapat diubah');
            }

            // Password will be auto-hashed by User model's `hashed` cast
            $user->update($validated);

            Log::info('User updated by admin', [
                'target_user' => $id,
                'admin_id' => $request->user()->id,
            ]);

            return $this->success(
                new UserResource($user),
                'User "' . $user->nama . '" berhasil diperbarui'
            );

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('User update error', [
                'id' => $id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal memperbarui user');
        }
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        try {
            $user = User::withCount(['events', 'informasis'])->find($id);

            if (!$user) {
                return $this->notFound('User');
            }

            // Cannot delete self
            if ($user->id === $request->user()->id) {
                return $this->forbidden('Tidak dapat menghapus akun sendiri');
            }

            if ($user->events_count > 0 || $user->informasis_count > 0) {
                return $this->forbidden('User masih memiliki event atau informasi. Pindahkan atau hapus konten terlebih dahulu.');
            }

            $nama = $user->nama;

            Notifikasi::kirimNotifikasi(
                $user,
                "Akun Anda telah dihapus oleh admin."
            );

            $user->tokens()->delete();
            $user->delete();

            Log::info('User deleted', [
                'deleted_user' => $id,
                'by_admin' => $request->user()->id,
            ]);

            return $this->success(null, 'User "' . $nama . '" berhasil dihapus');

        } catch (\Throwable $e) {
            Log::error('User delete error', [
                'id' => $id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal menghapus user');
        }
    }
}
