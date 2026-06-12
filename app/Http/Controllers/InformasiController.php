<?php

namespace App\Http\Controllers;

use App\Http\Resources\InformasiResource;
use App\Models\Informasi;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;
use OpenApi\Attributes as OA;

#[OA\Info(version: '1.0', description: 'SIPENDEKA API', title: 'SIPENDEKA API')]
class InformasiController extends Controller
{
    use ApiResponse;

    #[OA\Get(
        path: '/api/informasis',
        summary: 'List all informasi',
        tags: ['Informasi']
    )]
    public function index(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'search' => 'nullable|string|max:255',
                'per_page' => 'nullable|integer|min:1|max:50',
                'sort_by' => 'nullable|in:tanggal,judul,created_at',
                'sort_order' => 'nullable|in:asc,desc',
            ]);

            $query = Informasi::select(['id', 'judul', 'isi', 'tanggal', 'gambar', 'dibuat_oleh', 'created_at'])
                ->with('creator:id,nama')
                ->search($validated['search'] ?? null);

            $sortBy = $validated['sort_by'] ?? 'tanggal';
            $sortOrder = $validated['sort_order'] ?? 'desc';
            $perPage = min((int) ($validated['per_page'] ?? 10), 50);

            $informasis = $query->orderBy($sortBy, $sortOrder)->paginate($perPage);

            return $this->success(InformasiResource::collection($informasis), 'Data informasi berhasil diambil');

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Informasi list error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil data informasi');
        }
    }

    #[OA\Get(
        path: '/api/informasis/{id}',
        summary: 'Get informasi detail',
        tags: ['Informasi']
    )]
    public function show(int $id): JsonResponse
    {
        try {
            $informasi = Informasi::with('creator:id,nama')->find($id);

            if (!$informasi) {
                return $this->notFound('Informasi');
            }

            return $this->success(new InformasiResource($informasi), 'Detail informasi berhasil diambil');

        } catch (\Throwable $e) {
            Log::error('Informasi detail error', ['id' => $id, 'error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil detail informasi');
        }
    }

    #[OA\Post(
        path: '/api/informasis',
        summary: 'Create new informasi',
        tags: ['Informasi']
    )]
    public function store(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'judul' => 'required|string|max:255',
                'isi' => 'required|string',
                'tanggal' => 'required|date',
                'gambar' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            ]);

            $informasi = Informasi::tambahInformasi($validated, $request->user());

            Log::info('Informasi created', [
                'id' => $informasi->id,
                'judul' => $informasi->judul,
                'created_by' => $request->user()->id,
            ]);

            return $this->created(
                new InformasiResource($informasi->load('creator:id,nama')),
                'Informasi "' . $informasi->judul . '" berhasil ditambahkan'
            );

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Informasi create error', [
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal menambahkan informasi');
        }
    }

    #[OA\Put(
        path: '/api/informasis/{id}',
        summary: 'Update informasi',
        tags: ['Informasi']
    )]
    public function update(Request $request, int $id): JsonResponse
    {
        try {
            $informasi = Informasi::find($id);

            if (!$informasi) {
                return $this->notFound('Informasi');
            }

            $validated = $request->validate([
                'judul' => 'sometimes|required|string|max:255',
                'isi' => 'sometimes|required|string',
                'tanggal' => 'sometimes|required|date',
                'gambar' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
                'hapus_gambar' => 'nullable|boolean',
            ]);

            $informasi->updateInformasi($validated);

            Log::info('Informasi updated', [
                'id' => $informasi->id,
                'updated_by' => $request->user()->id,
            ]);

            return $this->success(
                new InformasiResource($informasi->fresh()->load('creator:id,nama')),
                'Informasi "' . $informasi->judul . '" berhasil diperbarui'
            );

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Informasi update error', [
                'id' => $id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal memperbarui informasi');
        }
    }

    #[OA\Delete(
        path: '/api/informasis/{id}',
        summary: 'Delete informasi',
        tags: ['Informasi']
    )]
    public function destroy(int $id): JsonResponse
    {
        try {
            $informasi = Informasi::find($id);

            if (!$informasi) {
                return $this->notFound('Informasi');
            }

            $judul = $informasi->judul;
            $informasi->hapusInformasi();

            Log::info('Informasi deleted', [
                'id' => $id,
                'judul' => $judul,
            ]);

            return $this->success(null, 'Informasi "' . $judul . '" berhasil dihapus');

        } catch (\Throwable $e) {
            Log::error('Informasi delete error', [
                'id' => $id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal menghapus informasi');
        }
    }
}
