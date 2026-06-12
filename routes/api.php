<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| API versioning support - routes are organized by version in routes/api/
| Current version: v1
|
| For future versions, add new files like routes/api/v2.php
|
*/

// Health check endpoint
Route::get('/health', function () {
    return response()->json([
        'status' => true,
        'message' => 'API is running',
        'version' => config('api.version', 'v1'),
        'timestamp' => now()->toIso8601String(),
    ]);
});

// V1 API Routes
Route::prefix('v1')->group(base_path('routes/api/v1.php'));

// Browser CORS preflight plus standard JSON fallback for unknown API routes.
Route::match(['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'], '/{any}', function () {
    if (request()->isMethod('OPTIONS')) {
        return response('', 204);
    }

    return response()->json([
        'status' => false,
        'message' => 'Resource tidak ditemukan',
    ], 404);
})->where('any', '.*');
