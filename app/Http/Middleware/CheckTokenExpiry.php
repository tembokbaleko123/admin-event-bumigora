<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckTokenExpiry
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user() && $request->user()->currentAccessToken()) {
            $token = $request->user()->currentAccessToken();
            if ($token->expires_at && $token->expires_at->isPast()) {
                $token->delete();
                return response()->json([
                    'status' => false,
                    'message' => 'Sesi telah berakhir, silakan login ulang',
                ], 401);
            }
        }

        return $next($request);
    }
}
