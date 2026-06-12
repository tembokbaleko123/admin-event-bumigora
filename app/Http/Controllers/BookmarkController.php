<?php

namespace App\Http\Controllers;

use App\Models\Bookmark;
use App\Models\Event;
use App\Models\Informasi;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class BookmarkController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            $type = $request->query('type');

            $query = Bookmark::byUser($user->id)
                ->with('bookmarkable');

            if ($type && in_array($type, ['App\\Models\\Event', 'App\\Models\\Informasi'])) {
                $query->ofType($type);
            }

            $bookmarks = $query->orderBy('created_at', 'desc')
                ->paginate(min((int) ($request->query('per_page', 20)), 50));

            return $this->success($bookmarks, 'Daftar bookmark berhasil diambil');

        } catch (\Throwable $e) {
            Log::error('Bookmark list error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil daftar bookmark');
        }
    }

    public function store(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'bookmarkable_id' => [
                    'required', 'integer',
                    function ($attr, $value, $fail) use ($request) {
                        $class = $request->bookmarkable_type === 'event' ? Event::class : Informasi::class;
                        if (!$class::find($value)) {
                            $fail('Resource not found');
                        }
                    },
                ],
                'bookmarkable_type' => 'required|in:event,informasi',
            ]);

            $user = $request->user();

            $modelClass = $validated['bookmarkable_type'] === 'event'
                ? 'App\\Models\\Event'
                : 'App\\Models\\Informasi';

            $existing = Bookmark::where('user_id', $user->id)
                ->where('bookmarkable_id', $validated['bookmarkable_id'])
                ->where('bookmarkable_type', $modelClass)
                ->first();

            if ($existing) {
                return $this->error('Anda sudah menambahkan bookmark ini', 400);
            }

            $bookmark = Bookmark::create([
                'user_id' => $user->id,
                'bookmarkable_id' => $validated['bookmarkable_id'],
                'bookmarkable_type' => $modelClass,
            ]);

            return $this->created(
                $bookmark->load('bookmarkable'),
                'Bookmark berhasil ditambahkan'
            );

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Bookmark create error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal menambahkan bookmark');
        }
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        try {
            $bookmark = Bookmark::where('id', $id)
                ->where('user_id', $request->user()->id)
                ->first();

            if (!$bookmark) {
                return $this->notFound('Bookmark');
            }

            $bookmark->delete();

            return $this->success(null, 'Bookmark berhasil dihapus');

        } catch (\Throwable $e) {
            Log::error('Bookmark delete error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal menghapus bookmark');
        }
    }

    public function checkStatus(Request $request, string $type, int $id): JsonResponse
    {
        try {
            $user = $request->user();

            $modelClass = $type === 'event'
                ? 'App\\Models\\Event'
                : 'App\\Models\\Informasi';

            $bookmark = Bookmark::where('user_id', $user->id)
                ->where('bookmarkable_id', $id)
                ->where('bookmarkable_type', $modelClass)
                ->first();

            return $this->success([
                'is_bookmarked' => $bookmark !== null,
                'bookmark_id' => $bookmark?->id,
            ], 'Status bookmark berhasil diambil');

        } catch (\Throwable $e) {
            Log::error('Bookmark check error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal mengecek status bookmark');
        }
    }
}
