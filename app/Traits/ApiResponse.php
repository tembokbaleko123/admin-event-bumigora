<?php

namespace App\Traits;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\ResourceCollection;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Pagination\CursorPaginator;

trait ApiResponse
{
    /**
     * Success response with consistent format
     */
    protected function success(mixed $data = null, string $message = 'Success', int $code = 200, array $extra = []): JsonResponse
    {
        $response = [
            'status' => true,
            'message' => $message,
            'data' => $data,
        ];

        // Extract paginator from ResourceCollection if needed
        $paginator = $data;
        if ($data instanceof ResourceCollection) {
            $paginator = $data->resource;
        }

        // Add pagination metadata if present
        if ($paginator instanceof LengthAwarePaginator) {
            $response['meta'] = [
                'current_page' => $paginator->currentPage(),
                'last_page' => $paginator->lastPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
                'has_more' => $paginator->hasMorePages(),
            ];
            if ($data instanceof ResourceCollection) {
                $response['data'] = $data->collection->values();
            } else {
                $response['data'] = $paginator->items();
            }
        } elseif ($paginator instanceof CursorPaginator) {
            $response['meta'] = [
                'per_page' => $paginator->perPage(),
                'has_more' => $paginator->hasMorePages(),
                'next_cursor' => $paginator->nextCursor()?->encoded,
                'prev_cursor' => $paginator->previousCursor()?->encoded,
            ];
            if ($data instanceof ResourceCollection) {
                $response['data'] = $data->collection->values();
            } else {
                $response['data'] = $paginator->items();
            }
        }

        if (!empty($extra)) {
            $response = array_merge($response, $extra);
        }

        return response()->json($response, $code);
    }

    /**
     * Created response (201)
     */
    protected function created(mixed $data = null, string $message = 'Data berhasil dibuat'): JsonResponse
    {
        return $this->success($data, $message, 201);
    }

    /**
     * Error response
     */
    protected function error(string $message = 'Terjadi kesalahan', int $code = 400, array $errors = []): JsonResponse
    {
        $response = [
            'status' => false,
            'message' => $message,
        ];

        if (!empty($errors)) {
            $response['errors'] = $errors;
        }

        return response()->json($response, $code);
    }

    /**
     * Validation error response (422)
     */
    protected function validationError(array $errors, string $message = 'Validation Error'): JsonResponse
    {
        return $this->error($message, 422, $errors);
    }

    /**
     * Not found response (404)
     */
    protected function notFound(string $resource = 'Data'): JsonResponse
    {
        return $this->error("{$resource} tidak ditemukan", 404);
    }

    /**
     * Unauthorized response (401)
     */
    protected function unauthorized(string $message = 'Unauthorized'): JsonResponse
    {
        return $this->error($message, 401);
    }

    /**
     * Forbidden response (403)
     */
    protected function forbidden(string $message = 'Forbidden'): JsonResponse
    {
        return $this->error($message, 403);
    }

    /**
     * Server error response (500)
     */
    protected function serverError(string $message = 'Terjadi kesalahan server', array $errors = []): JsonResponse
    {
        if (config('app.debug')) {
            return $this->error($message, 500, $errors);
        }
        return $this->error('Terjadi kesalahan server', 500);
    }
}
