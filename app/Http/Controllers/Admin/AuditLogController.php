<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class AuditLogController extends Controller
{
    use ApiResponse;

    /**
     * Ambil semua log audit dengan filter
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'user_id' => 'nullable|integer|exists:users,id',
                'action' => 'nullable|string|in:login,logout,create,update,delete,register,cancel_registration,scan_attendance,update_role',
                'entity_type' => 'nullable|string',
                'from_date' => 'nullable|date',
                'to_date' => 'nullable|date|after_or_equal:from_date',
                'per_page' => 'nullable|integer|min:1|max:100',
            ]);

            $query = AuditLog::with('user:id,nama,email')
                ->orderBy('created_at', 'desc');

            // Filter berdasarkan user
            if (isset($validated['user_id'])) {
                $query->where('user_id', $validated['user_id']);
            }

            // Filter berdasarkan action
            if (isset($validated['action'])) {
                $query->where('action', $validated['action']);
            }

            // Filter berdasarkan entity type
            if (isset($validated['entity_type'])) {
                $query->where('entity_type', $validated['entity_type']);
            }

            // Filter berdasarkan rentang tanggal
            if (isset($validated['from_date']) && isset($validated['to_date'])) {
                $query->whereBetween('created_at', [
                    $validated['from_date'],
                    $validated['to_date']
                ]);
            } elseif (isset($validated['from_date'])) {
                $query->where('created_at', '>=', $validated['from_date']);
            } elseif (isset($validated['to_date'])) {
                $query->where('created_at', '<=', $validated['to_date']);
            }

            $perPage = min((int) ($validated['per_page'] ?? 50), 100);
            $logs = $query->paginate($perPage);

            return $this->success($logs, 'Data audit log berhasil diambil');
        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Audit log index error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil data audit log');
        }
    }

    /**
     * Ambil detail log tertentu
     */
    public function show(int $id): JsonResponse
    {
        try {
            $log = AuditLog::with('user:id,nama,email')->find($id);

            if (!$log) {
                return $this->notFound('Audit Log');
            }

            return $this->success($log, 'Detail audit log berhasil diambil');
        } catch (\Throwable $e) {
            Log::error('Audit log show error', ['id' => $id, 'error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil detail audit log');
        }
    }

    /**
     * Ambil statistik audit log
     */
    public function stats(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'from_date' => 'nullable|date',
                'to_date' => 'nullable|date',
            ]);

            $query = AuditLog::query();

            if (isset($validated['from_date'])) {
                $query->where('created_at', '>=', $validated['from_date']);
            }
            if (isset($validated['to_date'])) {
                $query->where('created_at', '<=', $validated['to_date']);
            }

            $stats = [
                'total' => (clone $query)->count(),
                'by_action' => (clone $query)
                    ->selectRaw('action, COUNT(*) as count')
                    ->groupBy('action')
                    ->pluck('count', 'action')
                    ->toArray(),
                'by_entity' => (clone $query)
                    ->selectRaw('entity_type, COUNT(*) as count')
                    ->whereNotNull('entity_type')
                    ->groupBy('entity_type')
                    ->pluck('count', 'entity_type')
                    ->toArray(),
                'today' => (clone $query)
                    ->whereDate('created_at', today())
                    ->count(),
                'this_week' => (clone $query)
                    ->whereBetween('created_at', [now()->startOfWeek(), now()->endOfWeek()])
                    ->count(),
                'this_month' => (clone $query)
                    ->whereMonth('created_at', now()->month)
                    ->count(),
            ];

            return $this->success($stats, 'Statistik audit log berhasil diambil');
        } catch (\Throwable $e) {
            Log::error('Audit log stats error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil statistik audit log');
        }
    }
}
