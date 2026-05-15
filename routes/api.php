<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\EventController;
use App\Http\Controllers\InformasiController;
use App\Http\Controllers\NotifikasiController;
use App\Http\Controllers\UserController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
| Sistem Informasi Pendidikan & Event Akademik
|--------------------------------------------------------------------------
|
| Database: MySQL
| Authentication: Laravel Sanctum (token-based)
| Response Format: { "status": true/false, "message": "...", "data": {...} }
|
*/

// ==================== PUBLIC ROUTES ====================
// Routes yang tidak memerlukan autentikasi
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// ==================== PROTECTED ROUTES ====================
// Routes yang memerlukan autentikasi Sanctum
Route::middleware('auth:sanctum')->group(function () {

    // Auth Routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // ==================== VIEW ALL (MAHASISWA, DOSEN, ADMIN) ====================
    // Use Case: Lihat Event, Lihat Informasi
    Route::middleware('role:mahasiswa,dosen,admin')->group(function () {
        // Event Routes - Lihat Event & Detail
        Route::get('/events', [EventController::class, 'index']);
        Route::get('/events/{id}', [EventController::class, 'show']);

        // Informasi Routes - Lihat Informasi & Detail
        Route::get('/informasis', [InformasiController::class, 'index']);
        Route::get('/informasis/{id}', [InformasiController::class, 'show']);
    });

    // ==================== MAHASISWA ROUTES ====================
    // Use Case: Notifikasi Event
    Route::middleware('role:mahasiswa')->group(function () {
        // Notifikasi Routes - Terima Notifikasi Event
        Route::get('/notifikasis', [NotifikasiController::class, 'index']);
        Route::get('/notifikasis/unread', [NotifikasiController::class, 'unread']);
        Route::get('/notifikasis/unread/count', [NotifikasiController::class, 'unreadCount']);
        Route::put('/notifikasis/{id}/read', [NotifikasiController::class, 'markAsRead']);
        Route::put('/notifikasis/read-all', [NotifikasiController::class, 'markAllAsRead']);
        Route::delete('/notifikasis/{id}', [NotifikasiController::class, 'destroy']);
    });

    // ==================== DOSEN & ADMIN ROUTES ====================
    // Use Case: Input Event, Kelola Event (CRUD)
    Route::middleware('role:dosen,admin')->group(function () {
        // Event Routes - Input & Kelola Event
        Route::post('/events', [EventController::class, 'store']);
        Route::put('/events/{id}', [EventController::class, 'update']);
        Route::delete('/events/{id}', [EventController::class, 'destroy']);
    });

    // ==================== ADMIN ONLY ROUTES ====================
    // Use Case: Kelola Data User, Kelola Informasi
    Route::middleware('role:admin')->group(function () {
        // User Management Routes
        Route::get('/users', [UserController::class, 'index']);
        Route::get('/users/{id}', [UserController::class, 'show']);
        Route::put('/users/{id}', [UserController::class, 'update']);
        Route::delete('/users/{id}', [UserController::class, 'destroy']);

        // Informasi Management Routes
        Route::post('/informasis', [InformasiController::class, 'store']);
        Route::put('/informasis/{id}', [InformasiController::class, 'update']);
        Route::delete('/informasis/{id}', [InformasiController::class, 'destroy']);
    });
});
