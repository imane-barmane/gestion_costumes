<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CostumeController;
use App\Http\Controllers\ReservationController;
use App\Http\Controllers\ImageController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/
Route::get('/test', function () {
    return 'welcome';
});
// Authentication routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Public routes
Route::get('/costumes', [CostumeController::class, 'index']);
Route::get('/costumes/search', [CostumeController::class, 'search']);

// Protected routes (require authentication)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/upload-image', [ImageController::class, 'upload']);
    
    // Costume CRUD
    Route::post('/costumes', [CostumeController::class, 'store']);
    Route::put('/costumes/{id}', [CostumeController::class, 'update']);
    Route::delete('/costumes/{id}', [CostumeController::class, 'destroy']);
    Route::get('/costumes/seller/{sellerId}', [CostumeController::class, 'getBySeller']);

    Route::post('/reservations', [ReservationController::class, 'store']);
    Route::put('/costumes/{id}/reserve', [CostumeController::class, 'reserve']);

});

