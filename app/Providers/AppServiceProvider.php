<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        $this->configureRateLimiting();
    }

    /**
     * Configure rate limiting for the application.
     */
    protected function configureRateLimiting(): void
    {
        // Rate Limiter for Login - 5 attempts per minute per IP+email combination
        RateLimiter::for('login', function (Request $request) {
            $key = $request->ip() . '|' . ($request->input('email') ?? 'unknown');
            return Limit::perMinute(5)->by($key);
        });

        // Rate Limiter for Register - 3 attempts per minute per IP
        RateLimiter::for('register', function (Request $request) {
            return Limit::perMinute(3)->by($request->ip() . '-register');
        });

        // Rate Limiter for API General - 60 requests per minute per user/IP
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(60)
                ->by($request->user()?->id ?: $request->ip())
                ->response(function (Request $request, array $headers) {
                    return response()->json([
                        'status' => false,
                        'message' => 'Terlalu banyak permintaan. Silakan coba lagi nanti.',
                        'retry_after' => $headers['Retry-After'] ?? 60,
                    ], 429, $headers);
                });
        });

        // Rate Limiter for Admin Endpoints - 120 requests per minute per user
        RateLimiter::for('admin', function (Request $request) {
            $user = $request->user();
            $limit = ($user && $user->isAdmin()) ? 120 : 60;
            return Limit::perMinute($limit)
                ->by($request->user()?->id ?: $request->ip())
                ->response(function (Request $request, array $headers) {
                    return response()->json([
                        'status' => false,
                        'message' => 'Batas permintaan tercapai. Silakan coba lagi nanti.',
                        'retry_after' => $headers['Retry-After'] ?? 60,
                    ], 429, $headers);
                });
        });
    }
}
