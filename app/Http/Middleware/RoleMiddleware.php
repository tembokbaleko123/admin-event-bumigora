<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    /**
     * Handle incoming request dan cek role user.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @param  string  ...$roles  Role yang diizinkan (mahasiswa, dosen, admin)
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'Unauthorized - Silakan login terlebih dahulu',
            ], 401);
        }

        if (!in_array($user->role, $roles)) {
            return response()->json([
                'status' => false,
                'message' => 'Forbidden - Anda tidak memiliki akses untuk fitur ini',
            ], 403);
        }

        return $next($request);
    }
}
