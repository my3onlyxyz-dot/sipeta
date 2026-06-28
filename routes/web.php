<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProdukController;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/halo', function () {
    return view('halo');
});

Route::resource('produk', ProdukController::class);
Route::get('/start', fn () => view('start'));

// ===== SIMPATI — Pelaporan Sengketa Tanah =====
Route::middleware('guest')->group(function () {
    Route::get('/login', [\App\Http\Controllers\AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [\App\Http\Controllers\AuthController::class, 'login']);
    Route::get('/register', [\App\Http\Controllers\AuthController::class, 'showRegister'])->name('register');
    Route::post('/register', [\App\Http\Controllers\AuthController::class, 'register']);
});

Route::middleware('auth')->group(function () {
    Route::post('/logout', [\App\Http\Controllers\AuthController::class, 'logout'])->name('logout');
    Route::get('/dashboard', [\App\Http\Controllers\DashboardController::class, 'index'])->name('dashboard');

    Route::get('/laporan', [\App\Http\Controllers\ReportController::class, 'index'])->name('reports.index');
    Route::get('/laporan/buat', [\App\Http\Controllers\ReportController::class, 'create'])->name('reports.create');
    Route::post('/laporan', [\App\Http\Controllers\ReportController::class, 'store'])->name('reports.store');
    Route::get('/laporan/{report}', [\App\Http\Controllers\ReportController::class, 'show'])->name('reports.show');
    Route::get('/laporan/{report}/cetak', [\App\Http\Controllers\ReportController::class, 'print'])->name('reports.print');
    Route::patch('/laporan/{report}/status', [\App\Http\Controllers\ReportController::class, 'updateStatus'])->name('reports.status');
    Route::delete('/laporan/{report}', [\App\Http\Controllers\ReportController::class, 'destroy'])->name('reports.destroy');
});

// ===== SIMPATI v2 — modul tambahan =====
Route::middleware('auth')->group(function () {
    Route::get('/profil', [\App\Http\Controllers\ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profil', [\App\Http\Controllers\ProfileController::class, 'update'])->name('profile.update');
    Route::patch('/profil/sandi', [\App\Http\Controllers\ProfileController::class, 'password'])->name('profile.password');

    Route::get('/notifikasi', [\App\Http\Controllers\NotificationController::class, 'index'])->name('notif.index');
    Route::post('/notifikasi/baca-semua', [\App\Http\Controllers\NotificationController::class, 'readAll'])->name('notif.readAll');
    Route::get('/notifikasi/{pemberitahuan}', [\App\Http\Controllers\NotificationController::class, 'open'])->name('notif.open');

    Route::post('/laporan/{report}/disposisi', [\App\Http\Controllers\ReportController::class, 'assign'])->name('reports.assign');

    Route::get('/mediasi', [\App\Http\Controllers\MediationController::class, 'index'])->name('mediations.index');
    Route::post('/laporan/{report}/mediasi', [\App\Http\Controllers\MediationController::class, 'store'])->name('mediations.store');
    Route::patch('/mediasi/{mediation}', [\App\Http\Controllers\MediationController::class, 'update'])->name('mediations.update');
    Route::delete('/mediasi/{mediation}', [\App\Http\Controllers\MediationController::class, 'destroy'])->name('mediations.destroy');

    Route::get('/rekap', [\App\Http\Controllers\RekapController::class, 'index'])->name('rekap.index');

    Route::get('/pengguna', [\App\Http\Controllers\UserController::class, 'index'])->name('users.index');
    Route::get('/pengguna/buat', [\App\Http\Controllers\UserController::class, 'create'])->name('users.create');
    Route::post('/pengguna', [\App\Http\Controllers\UserController::class, 'store'])->name('users.store');
    Route::patch('/pengguna/{user}', [\App\Http\Controllers\UserController::class, 'update'])->name('users.update');
    Route::post('/pengguna/{user}/reset', [\App\Http\Controllers\UserController::class, 'resetPassword'])->name('users.reset');
    Route::delete('/pengguna/{user}', [\App\Http\Controllers\UserController::class, 'destroy'])->name('users.destroy');
});

// ===== SIMPATI v3 — kontak & export =====
Route::middleware('auth')->group(function () {
    Route::get('/kontak', fn () => view('kontak'))->name('kontak');
    Route::get('/rekap/unduh', [\App\Http\Controllers\RekapController::class, 'export'])->name('rekap.export');
});
