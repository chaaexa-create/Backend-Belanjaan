<?php

use App\Http\Controllers\Api\BarangController;
use Illuminate\Support\Facades\Route;

Route::prefix('barang')->group(function () {
    Route::get('/', [BarangController::class, 'index']);
    Route::post('/', [BarangController::class, 'store']);
    Route::patch('/{barang}', [BarangController::class, 'update']);
    Route::patch('/{barang}/toggle-status', [BarangController::class, 'toggleStatus']);
    Route::delete('/{barang}', [BarangController::class, 'destroy']);
});
