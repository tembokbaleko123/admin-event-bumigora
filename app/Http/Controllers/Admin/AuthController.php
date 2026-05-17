<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;

class AuthController extends Controller
{
    /**
     * Tampilkan halaman login admin
     */
    public function showLoginForm()
    {
        if (Auth::check()) {
            if (in_array(Auth::user()->role, ['admin', 'dosen'])) {
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
            'password' => 'required|min:6',
        ]);

        if (Auth::attempt($credentials)) {
            $user = Auth::user();
            if (!in_array($user->role, ['admin', 'dosen'])) {
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
            'email' => 'required|email|exists:users,email',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!in_array($user->role, ['admin', 'dosen'])) {
            return back()->with('error', 'Email tidak terdaftar sebagai admin atau dosen.');
        }

        // Generate token sederhana dan simpan di session
        $token = bin2hex(random_bytes(32));
        session(['reset_token_' . $user->id => $token]);
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
            'email' => 'required|email|exists:users,email',
            'token' => 'required|string',
            'password' => 'required|string|min:6|confirmed',
        ]);

        $user = User::where('email', $request->email)->first();

        // Verifikasi token
        $savedToken = session('reset_token_' . $user->id);
        if (!$savedToken || $savedToken !== $request->token) {
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
