<?php

namespace App\Http\Controllers;

use App\Enums\EventStatus;
use App\Enums\RegistrationStatus;
use App\Http\Resources\EventResource;
use App\Models\Event;
use App\Models\EventRegistration;
use App\Models\UserInterest;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class RecommendationController extends Controller
{
    use ApiResponse;

    public function recommendedEvents(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            $limit = min((int) ($request->query('limit', 10)), 20);

            $topCategories = UserInterest::getTopCategories($user->id, 3);

            // Get events user already registered for (subquery)
            $registeredSub = function ($q) use ($user) {
                $q->select('event_id')->from('event_registrations')
                    ->where('user_id', $user->id)->where('status', RegistrationStatus::Registered->value);
            };

            if (!empty($topCategories)) {
                // Recommend by interest categories
                $recommended = Event::where('status', EventStatus::Published->value)
                    ->where('tanggal', '>=', now())
                    ->whereNotIn('id', $registeredSub)
                    ->whereIn('kategori', $topCategories)
                    ->with('creator:id,nama')
                    ->withCount(['activeRegistrations as total_pendaftar'])
                    ->orderBy('tanggal')
                    ->limit($limit)
                    ->get();

                // Jika masih kurang, tambahkan event populer
                $remaining = $limit - $recommended->count();
                if ($remaining > 0) {
                    $excludeIds = $recommended->pluck('id')->toArray();

                    $popular = Event::where('status', EventStatus::Published->value)
                        ->where('tanggal', '>=', now())
                        ->whereNotIn('id', $registeredSub)
                        ->whereNotIn('id', $excludeIds)
                        ->with('creator:id,nama')
                        ->withCount(['activeRegistrations as total_pendaftar'])
                        ->orderByDesc('total_pendaftar')
                        ->limit($remaining)
                        ->get();

                    $recommended = $recommended->concat($popular);
                }
            } else {
                // No interest data yet — show popular upcoming events
                $recommended = Event::where('status', EventStatus::Published->value)
                    ->where('tanggal', '>=', now())
                    ->whereNotIn('id', $registeredSub)
                    ->with('creator:id,nama')
                    ->withCount(['activeRegistrations as total_pendaftar'])
                    ->orderByDesc('total_pendaftar')
                    ->orderBy('tanggal')
                    ->limit($limit)
                    ->get();
            }

            return $this->success([
                'events' => EventResource::collection($recommended),
                'based_on' => !empty($topCategories) ? 'interest' : 'popular',
                'categories' => $topCategories,
            ]);

        } catch (\Throwable $e) {
            Log::error('Recommendation error', [
                'user_id' => $request->user()->id,
                'error' => $e->getMessage(),
            ]);
            return $this->serverError('Gagal mengambil rekomendasi event');
        }
    }

    public function trackEventView(Request $request, int $eventId): JsonResponse
    {
        try {
            $user = $request->user();
            $event = Event::find($eventId);

            if (!$event || !$event->kategori) {
                return $this->success(null, 'OK');
            }

            UserInterest::trackInterest($user->id, $event->kategori);

            return $this->success(null, 'OK');

        } catch (\Throwable $e) {
            return $this->success(null, 'OK');
        }
    }

    public function getInterests(Request $request): JsonResponse
    {
        try {
            $user = $request->user();

            $interests = UserInterest::byUser($user->id)
                ->orderByDesc('score')
                ->get();

            return $this->success($interests, 'Data minat berhasil diambil');

        } catch (\Throwable $e) {
            Log::error('Get interests error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal mengambil data minat');
        }
    }

    public function saveInterests(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'categories' => 'required|array',
                'categories.*' => 'string|max:50',
            ]);

            $user = $request->user();

            // Clear existing interests and save new ones
            UserInterest::byUser($user->id)->delete();

            foreach ($validated['categories'] as $category) {
                UserInterest::create([
                    'user_id' => $user->id,
                    'category' => strtoupper(trim($category)),
                    'score' => 1,
                ]);
            }

            return $this->success(null, 'Minat berhasil disimpan');

        } catch (\Illuminate\Validation\ValidationException $e) {
            return $this->validationError($e->errors());
        } catch (\Throwable $e) {
            Log::error('Save interests error', ['error' => $e->getMessage()]);
            return $this->serverError('Gagal menyimpan minat');
        }
    }
}
