<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CacheHeadersMiddleware
{
    public function handle(Request $request, Closure $next, int $minutes = 5): Response
    {
        $response = $next($request);

        if ($response->isSuccessful() && $request->isMethod('GET')) {
            $response->headers->set('Cache-Control', 'private, max-age=' . ($minutes * 60) . ', must-revalidate');
            $response->headers->set('Expires', gmdate('D, d M Y H:i:s', time() + ($minutes * 60)) . ' GMT');
            $response->headers->set('X-Content-Type-Options', 'nosniff');
            $response->headers->set('X-Frame-Options', 'DENY');
            $response->headers->set('X-XSS-Protection', '1; mode=block');
        }

        return $response;
    }
}
