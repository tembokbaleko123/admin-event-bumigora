<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use App\Http\Controllers\AnalyticsController;
use App\Http\Controllers\AttendanceController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\Admin\AuditLogController;
use App\Http\Controllers\BookmarkController;
use App\Http\Controllers\EventController;
use App\Http\Controllers\InformasiController;
use App\Http\Controllers\NotifikasiController;
use App\Http\Controllers\RecommendationController;
use App\Http\Controllers\RegistrationController;
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
| Rate Limiting:
|   - Login: 5 attempts per minute
|   - Register: 3 attempts per minute
|   - API General: 60 requests per minute
|   - Admin Endpoints: 120 requests per minute
|
*/

// ==================== PUBLIC ROUTES (with rate limiting) ====================
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:login');
Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:register');

// ==================== PROTECTED ROUTES (with general API throttle) ====================
Route::middleware(['auth:sanctum', 'token.expiry', 'throttle:api'])->group(function () {

    // Auth Routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);
    Route::get('/dashboard/overview', [AnalyticsController::class, 'dashboardOverview']);

    // ==================== VIEW ALL (MAHASISWA, DOSEN, ADMIN) ====================
    // Use Case: Lihat Event, Lihat Informasi
    Route::middleware('role:mahasiswa,dosen,admin')->group(function () {
        // Event Routes - Lihat Event & Detail
        Route::get('/events', [EventController::class, 'index'])->middleware('cache.headers:5');
        Route::get('/events/{id}', [EventController::class, 'show']);

        // Informasi Routes - Lihat Informasi & Detail
        Route::get('/informasis', [InformasiController::class, 'index'])->middleware('cache.headers:5');
        Route::get('/informasis/{id}', [InformasiController::class, 'show']);
    });

    // ==================== NOTIFIKASI ROUTES (all authenticated roles) ====================
    // Use Case: Terima & Kelola Notifikasi Event
    Route::middleware('role:mahasiswa,dosen,admin')->group(function () {
        Route::get('/notifikasis', [NotifikasiController::class, 'index']);
        Route::get('/notifikasis/unread', [NotifikasiController::class, 'unread']);
        Route::get('/notifikasis/unread/count', [NotifikasiController::class, 'unreadCount']);
        Route::put('/notifikasis/{id}/read', [NotifikasiController::class, 'markAsRead']);
        Route::put('/notifikasis/read-all', [NotifikasiController::class, 'markAllAsRead']);
        Route::delete('/notifikasis/{id}', [NotifikasiController::class, 'destroy']);
    });

    // ==================== EVENT REGISTRATION ROUTES ====================
    // Use Case: Mahasiswa daftar/batal event, lihat peserta, cek status
    Route::middleware('role:mahasiswa,dosen,admin')->group(function () {
        Route::get('/events/{id}/check-registration', [RegistrationController::class, 'checkRegistration']);
        Route::get('/users/me/events', [RegistrationController::class, 'myEvents']);

        // Bookmark Routes
        Route::post('/bookmarks', [BookmarkController::class, 'store']);
        Route::get('/bookmarks', [BookmarkController::class, 'index']);
        Route::get('/bookmarks/check/{type}/{id}', [BookmarkController::class, 'checkStatus']);
        Route::delete('/bookmarks/{id}', [BookmarkController::class, 'destroy']);
    });

    Route::middleware('role:mahasiswa')->group(function () {
        Route::post('/events/{id}/register', [RegistrationController::class, 'register']);
        Route::delete('/events/{id}/register', [RegistrationController::class, 'cancel']);
    });

    Route::middleware('role:dosen,admin')->group(function () {
        Route::get('/events/{id}/participants', [RegistrationController::class, 'participants']);
    });

    // ==================== QR CODE ATTENDANCE ROUTES ====================
    Route::middleware('role:mahasiswa')->group(function () {
        Route::post('/events/{id}/attendance/scan', [AttendanceController::class, 'scanAttendance']);
        Route::get('/events/{id}/attendance/check', [AttendanceController::class, 'checkAttendance']);
    });

    Route::middleware('role:dosen,admin')->group(function () {
        Route::post('/events/{id}/qr', [AttendanceController::class, 'generateQr']);
        Route::get('/events/{id}/qr', [AttendanceController::class, 'getActiveQr']);
        Route::get('/events/{id}/attendance', [AttendanceController::class, 'report']);
        Route::get('/events/{id}/attendance/csv', [AttendanceController::class, 'reportCsv']);
        Route::post('/events/{id}/attendance/manual', [AttendanceController::class, 'manualAttendance']);
    });

    // ==================== RECOMMENDATION ROUTES ====================
    Route::middleware('role:mahasiswa,dosen,admin')->group(function () {
        Route::get('/recommendations/events', [RecommendationController::class, 'recommendedEvents']);
        Route::post('/events/{id}/track-view', [RecommendationController::class, 'trackEventView']);
        Route::get('/users/me/interests', [RecommendationController::class, 'getInterests']);
        Route::post('/users/me/interests', [RecommendationController::class, 'saveInterests']);
    });

    // ==================== ANALYTICS ROUTES ====================
    Route::middleware('role:admin')->group(function () {
        Route::get('/admin/analytics/summary', [AnalyticsController::class, 'adminSummary']);
        Route::get('/admin/analytics/events', [AnalyticsController::class, 'adminEvents']);
    });

    Route::middleware('role:dosen')->group(function () {
        Route::get('/lecturer/analytics/events', [AnalyticsController::class, 'lecturerEvents']);
    });

    Route::middleware('role:dosen,admin')->group(function () {
        Route::get('/events/{id}/analytics', [AnalyticsController::class, 'eventDetail']);
    });

    // ==================== DOSEN & ADMIN ROUTES (rate limited: 120/min for admin) ====================
    // Use Case: Input Event, Kelola Event (CRUD)
    Route::middleware('role:dosen,admin')->group(function () {
        // Event Routes - Input & Kelola Event
        Route::post('/events', [EventController::class, 'store']);
        Route::put('/events/{id}', [EventController::class, 'update']);
        Route::delete('/events/{id}', [EventController::class, 'destroy']);
    });

    // ==================== ADMIN ONLY ROUTES ====================
    // Use Case: Kelola Data User, Kelola Informasi
    Route::middleware(['role:admin', 'throttle:admin'])->group(function () {
        // User Management Routes
        Route::get('/users', [UserController::class, 'index'])->middleware('cache.headers:5');
        Route::post('/users', [UserController::class, 'store']);
        Route::get('/users/{id}', [UserController::class, 'show']);
        Route::put('/users/{id}', [UserController::class, 'update']);
        Route::delete('/users/{id}', [UserController::class, 'destroy']);

        // Informasi Management Routes
        Route::post('/informasis', [InformasiController::class, 'store']);
        Route::put('/informasis/{id}', [InformasiController::class, 'update']);
        Route::delete('/informasis/{id}', [InformasiController::class, 'destroy']);

        // Event Approval Routes
        Route::put('/events/{id}/approve', [EventController::class, 'approve']);
        Route::put('/events/{id}/reject', [EventController::class, 'reject']);
    });

    // ==================== AUDIT LOG ROUTES ====================
    Route::middleware(['role:admin', 'throttle:admin'])->group(function () {
        Route::get('/admin/audit-logs', [AuditLogController::class, 'index']);
        Route::get('/admin/audit-logs/stats', [AuditLogController::class, 'stats']);
        Route::get('/admin/audit-logs/{id}', [AuditLogController::class, 'show']);
    });
});
