<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
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
        $expectsJson = $request->expectsJson() || $request->is('api/*');

        if (!$user) {
            if (!$expectsJson) {
                return redirect()->route('admin.login')
                    ->with('error', 'Silakan login terlebih dahulu.');
            }

            return response()->json([
                'status' => false,
                'message' => 'Unauthorized - Silakan login terlebih dahulu',
            ], 401);
        }

        if (!in_array($user->role, $roles)) {
            if (!$expectsJson) {
                if ($request->routeIs('admin.dashboard')) {
                    Auth::logout();
                    $request->session()->invalidate();
                    $request->session()->regenerateToken();

                    return redirect()->route('admin.login')
                        ->with('error', 'Akun Anda tidak memiliki akses ke panel admin.');
                }

                return redirect()->route('admin.dashboard')
                    ->with('error', 'Anda tidak memiliki akses ke halaman tersebut.');
            }

            return response()->json([
                'status' => false,
                'message' => 'Forbidden - Anda tidak memiliki akses untuk fitur ini',
            ], 403);
        }

        return $next($request);
    }
}
