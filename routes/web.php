<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\Admin\EventController;
use App\Http\Controllers\Admin\InformasiController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\ProfileController;

/*
|--------------------------------------------------------------------------
| Web Routes - Admin Panel
|--------------------------------------------------------------------------
| Sistem Informasi Pendidikan & Event Akademik
|--------------------------------------------------------------------------
*/

Route::get('/', [AuthController::class, 'showLoginForm'])->name('home');

// ==================== GUEST ROUTES ====================
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [AuthController::class, 'login'])->name('login.post');

    // Forgot Password
    Route::get('/forgot-password', [AuthController::class, 'showForgotPasswordForm'])->name('password.request');
    Route::post('/forgot-password', [AuthController::class, 'sendResetLink'])->name('password.email');

    // Reset Password
    Route::get('/reset-password/{token}', [AuthController::class, 'showResetPasswordForm'])->name('password.reset');
    Route::post('/reset-password', [AuthController::class, 'resetPassword'])->name('password.update');
});

// ==================== AUTHENTICATED ROUTES ====================
Route::prefix('admin')->name('admin.')->middleware(['auth', 'role:admin,dosen'])->group(function () {
    // Logout
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

    // Dashboard
    Route::get('/dashboard', [AdminController::class, 'index'])->name('dashboard');
    Route::redirect('/', '/admin/dashboard');

    // Profile
    Route::get('/profile', [ProfileController::class, 'index'])->name('profile');
    Route::put('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::put('/profile/password', [ProfileController::class, 'updatePassword'])->name('profile.password');

    // Events CRUD
    Route::resource('events', EventController::class)->names([
        'index' => 'events.index',
        'create' => 'events.create',
        'store' => 'events.store',
        'show' => 'events.show',
        'edit' => 'events.edit',
        'update' => 'events.update',
        'destroy' => 'events.destroy',
    ]);

    // Events Calendar
    Route::get('/calendar', [EventController::class, 'calendar'])->name('events.calendar');

    Route::middleware('role:admin')->group(function () {
        // Informasi CRUD
        Route::resource('informasis', InformasiController::class)->names([
            'index' => 'informasis.index',
            'create' => 'informasis.create',
            'store' => 'informasis.store',
            'show' => 'informasis.show',
            'edit' => 'informasis.edit',
            'update' => 'informasis.update',
            'destroy' => 'informasis.destroy',
        ]);

        // Users
        Route::resource('users', UserController::class)->only([
            'index', 'show', 'edit', 'update', 'destroy'
        ])->names([
            'index' => 'users.index',
            'show' => 'users.show',
            'edit' => 'users.edit',
            'update' => 'users.update',
            'destroy' => 'users.destroy',
        ]);
    });
});
