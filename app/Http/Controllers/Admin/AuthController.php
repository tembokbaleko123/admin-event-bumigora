<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    /**
     * Tampilkan halaman login admin
     */
    public function showLoginForm()
    {
        if (Auth::check()) {
            if (in_array(Auth::user()->role, [UserRole::Admin->value, UserRole::Dosen->value])) {
                return redirect()->route('admin.dashboard');
            }

            Auth::logout();
        }

        return view('auth.login');
    }

    /**
     * Proses login admin
     */
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (Auth::attempt($credentials)) {
            $user = Auth::user();
            if (!in_array($user->role, [UserRole::Admin->value, UserRole::Dosen->value])) {
                Auth::logout();
                return back()->withErrors([
                    'email' => 'Anda tidak memiliki akses ke panel admin.',
                ])->onlyInput('email');
            }
            $request->session()->regenerate();
            return redirect()->intended(route('admin.dashboard'));
        }

        return back()->withErrors([
            'email' => 'Email atau password salah.',
        ])->onlyInput('email');
    }

    /**
     * Proses logout admin
     */
    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('admin.login');
    }

    /**
     * Tampilkan form forgot password
     */
    public function showForgotPasswordForm()
    {
        return view('auth.forgot-password');
    }

    /**
     * Kirim link reset password (simulasi - menampilkan token di session)
     */
    public function sendResetLink(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $user = User::where('email', $request->email)
            ->whereIn('role', [UserRole::Admin->value, UserRole::Dosen->value])
            ->first();

        if (!$user) {
            return back()->with('success', 'Jika email terdaftar, Anda akan menerima tautan reset password.');
        }

        // Generate token dengan expiry 30 menit
        $token = bin2hex(random_bytes(32));
        session(['reset_token_' . $user->id => [
            'token' => $token,
            'expires_at' => now()->addMinutes(30)->timestamp,
        ]]);
        session(['reset_email' => $user->email]);

        return redirect()->route('admin.password.reset', ['token' => $token, 'email' => $user->email])
            ->with('success', 'Silakan masukkan password baru Anda.');
    }

    /**
     * Tampilkan form reset password
     */
    public function showResetPasswordForm(Request $request, $token)
    {
        $email = $request->email;

        return view('auth.reset-password', compact('token', 'email'));
    }

    /**
     * Proses reset password
     */
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'token' => 'required|string',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return back()->with('error', 'Token reset password tidak valid. Silakan ulangi proses.');
        }

        // Only admin/dosen can reset password via this flow
        if (!in_array($user->role, [UserRole::Admin->value, UserRole::Dosen->value])) {
            return back()->with('error', 'Token reset password tidak valid. Silakan ulangi proses.');
        }

        // Verifikasi token dengan data session
        $savedData = session('reset_token_' . $user->id);

        if (!$savedData || !isset($savedData['token'], $savedData['expires_at'])) {
            return back()->with('error', 'Token reset password tidak valid. Silakan ulangi proses.');
        }

        // Check expiry
        if (now()->timestamp > $savedData['expires_at']) {
            session()->forget(['reset_token_' . $user->id, 'reset_email']);
            return back()->with('error', 'Token reset password sudah kadaluarsa. Silakan ulangi proses.');
        }

        // Timing-safe comparison
        if (!hash_equals($savedData['token'], $request->token)) {
            session()->forget(['reset_token_' . $user->id, 'reset_email']);
            return back()->with('error', 'Token reset password tidak valid. Silakan ulangi proses.');
        }

        // Update password
        $user->updatePassword($request->password);

        // Hapus token dari session
        session()->forget(['reset_token_' . $user->id, 'reset_email']);

        return redirect()->route('admin.login')
            ->with('success', 'Password berhasil direset. Silakan login dengan password baru.');
    }
}
