#!/usr/bin/env bash
# ============================================================
#  SIPETA — Sistem Pelaporan Sengketa Tanah
#  Setup otomatis untuk Laravel (jalankan di dalam folder ~/myapp)
#  Pakai: bash sipeta-setup.sh
# ============================================================
set -e
APP_DIR="$(pwd)"
echo "==> Folder project: $APP_DIR"

if [ ! -f artisan ]; then
  echo "!! File 'artisan' tidak ditemukan. Jalankan script ini DI DALAM folder Laravel (~/myapp)."
  exit 1
fi

# ---------- 1. Database SQLite ----------
echo "==> Set database ke SQLite"
mkdir -p database
touch database/database.sqlite
sed -i 's#^DB_CONNECTION=.*#DB_CONNECTION=sqlite#' .env
if grep -q '^DB_DATABASE=' .env; then
  sed -i "s#^DB_DATABASE=.*#DB_DATABASE=${APP_DIR}/database/database.sqlite#" .env
else
  echo "DB_DATABASE=${APP_DIR}/database/database.sqlite" >> .env
fi
grep -q '^APP_KEY=base64' .env || php artisan key:generate

mkdir -p app/Http/Controllers app/Models database/migrations \
         resources/views/layouts resources/views/auth resources/views/reports

# ---------- 2. Migrations ----------
echo "==> Tulis migrations"

cat > database/migrations/2026_06_28_100001_add_role_to_users_table.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::table('users', function (Blueprint $table) {
            $table->string('role')->default('warga')->after('email'); // warga | petugas
            $table->string('no_hp')->nullable()->after('role');
        });
    }
    public function down(): void {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['role', 'no_hp']);
        });
    }
};
EOF

cat > database/migrations/2026_06_28_100002_create_reports_table.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('nomor')->nullable()->unique();
            $table->string('judul');
            $table->string('nama_pelapor');
            $table->string('no_hp');
            $table->string('jenis')->nullable();          // batas, kepemilikan, waris, dll
            $table->text('lokasi');                        // alamat tanah
            $table->string('kecamatan')->nullable();
            $table->decimal('luas', 12, 2)->nullable();    // m2
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->string('pihak_terlapor')->nullable();
            $table->text('kronologi');
            $table->string('status')->default('baru');     // baru | diproses | selesai | ditolak
            $table->text('catatan_petugas')->nullable();
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('reports'); }
};
EOF

cat > database/migrations/2026_06_28_100003_create_report_documents_table.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('report_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('report_id')->constrained()->cascadeOnDelete();
            $table->string('path');
            $table->string('nama_asli');
            $table->string('mime')->nullable();
            $table->unsignedBigInteger('ukuran')->nullable();
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('report_documents'); }
};
EOF

# ---------- 3. Models ----------
echo "==> Tulis models"

cat > app/Models/User.php << 'EOF'
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasFactory, Notifiable;

    protected $fillable = ['name', 'email', 'password', 'role', 'no_hp'];
    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return ['email_verified_at' => 'datetime', 'password' => 'hashed'];
    }

    public function reports(): HasMany
    {
        return $this->hasMany(Report::class);
    }

    public function isPetugas(): bool
    {
        return $this->role === 'petugas';
    }
}
EOF

cat > app/Models/Report.php << 'EOF'
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Report extends Model
{
    protected $fillable = [
        'user_id', 'nomor', 'judul', 'nama_pelapor', 'no_hp', 'jenis',
        'lokasi', 'kecamatan', 'luas', 'latitude', 'longitude',
        'pihak_terlapor', 'kronologi', 'status', 'catatan_petugas',
    ];

    public function user(): BelongsTo { return $this->belongsTo(User::class); }
    public function documents(): HasMany { return $this->hasMany(ReportDocument::class); }

    public function statusLabel(): string
    {
        return [
            'baru' => 'Baru', 'diproses' => 'Diproses',
            'selesai' => 'Selesai', 'ditolak' => 'Ditolak',
        ][$this->status] ?? ucfirst($this->status);
    }

    public function statusClasses(): string
    {
        return [
            'baru'     => 'bg-sky-50 text-sky-700 ring-sky-200',
            'diproses' => 'bg-amber-50 text-amber-700 ring-amber-200',
            'selesai'  => 'bg-emerald-50 text-emerald-700 ring-emerald-200',
            'ditolak'  => 'bg-rose-50 text-rose-700 ring-rose-200',
        ][$this->status] ?? 'bg-slate-100 text-slate-600 ring-slate-200';
    }
}
EOF

cat > app/Models/ReportDocument.php << 'EOF'
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReportDocument extends Model
{
    protected $fillable = ['report_id', 'path', 'nama_asli', 'mime', 'ukuran'];

    public function report(): BelongsTo { return $this->belongsTo(Report::class); }

    public function isImage(): bool
    {
        return str_starts_with((string) $this->mime, 'image/');
    }
}
EOF

# ---------- 4. Controllers ----------
echo "==> Tulis controllers"

cat > app/Http/Controllers/AuthController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function showLogin() { return view('auth.login'); }

    public function login(Request $request)
    {
        $cred = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (! Auth::attempt($cred, $request->boolean('remember'))) {
            throw ValidationException::withMessages([
                'email' => 'Email atau kata sandi salah.',
            ]);
        }

        $request->session()->regenerate();
        return redirect()->intended(route('dashboard'));
    }

    public function showRegister() { return view('auth.register'); }

    public function register(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'no_hp' => ['required', 'string', 'max:20'],
            'password' => ['required', 'confirmed', 'min:6'],
        ]);

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'no_hp' => $data['no_hp'],
            'password' => $data['password'],
            'role' => 'warga',
        ]);

        Auth::login($user);
        $request->session()->regenerate();
        return redirect()->route('dashboard');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('login');
    }
}
EOF

cat > app/Http/Controllers/DashboardController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\Report;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $base = $user->isPetugas() ? Report::query() : $user->reports();

        $stats = [
            'total'    => (clone $base)->count(),
            'baru'     => (clone $base)->where('status', 'baru')->count(),
            'diproses' => (clone $base)->where('status', 'diproses')->count(),
            'selesai'  => (clone $base)->where('status', 'selesai')->count(),
        ];

        $terbaru = (clone $base)->with('user')->latest()->limit(5)->get();

        return view('dashboard', compact('stats', 'terbaru'));
    }
}
EOF

cat > app/Http/Controllers/ReportController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\Report;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = $user->isPetugas() ? Report::query()->with('user') : $user->reports();

        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }
        if ($q = $request->query('q')) {
            $query->where(fn ($w) => $w->where('judul', 'like', "%$q%")
                ->orWhere('nomor', 'like', "%$q%")
                ->orWhere('lokasi', 'like', "%$q%"));
        }

        $reports = $query->latest()->paginate(10)->withQueryString();
        return view('reports.index', compact('reports'));
    }

    public function create() { return view('reports.create'); }

    public function store(Request $request)
    {
        $data = $request->validate([
            'judul' => ['required', 'string', 'max:150'],
            'nama_pelapor' => ['required', 'string', 'max:255'],
            'no_hp' => ['required', 'string', 'max:20'],
            'jenis' => ['nullable', 'string', 'max:50'],
            'lokasi' => ['required', 'string'],
            'kecamatan' => ['nullable', 'string', 'max:100'],
            'luas' => ['nullable', 'numeric', 'min:0'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'pihak_terlapor' => ['nullable', 'string', 'max:255'],
            'kronologi' => ['required', 'string'],
            'dokumen' => ['nullable', 'array', 'max:6'],
            'dokumen.*' => ['file', 'mimes:jpg,jpeg,png,pdf', 'max:5120'],
        ]);

        $report = $request->user()->reports()->create($data + ['status' => 'baru']);
        $report->update(['nomor' => 'TS-' . str_pad($report->id, 5, '0', STR_PAD_LEFT)]);

        foreach ((array) $request->file('dokumen') as $file) {
            $path = $file->store('dokumen', 'public');
            $report->documents()->create([
                'path' => $path,
                'nama_asli' => $file->getClientOriginalName(),
                'mime' => $file->getMimeType(),
                'ukuran' => $file->getSize(),
            ]);
        }

        return redirect()->route('reports.show', $report)
            ->with('success', 'Laporan berhasil dikirim. Nomor: ' . $report->nomor);
    }

    public function show(Request $request, Report $report)
    {
        $this->authorizeView($request, $report);
        $report->load('documents', 'user');
        return view('reports.show', compact('report'));
    }

    public function updateStatus(Request $request, Report $report)
    {
        abort_unless($request->user()->isPetugas(), 403);

        $data = $request->validate([
            'status' => ['required', 'in:baru,diproses,selesai,ditolak'],
            'catatan_petugas' => ['nullable', 'string'],
        ]);

        $report->update($data);
        return back()->with('success', 'Status laporan diperbarui.');
    }

    public function print(Request $request, Report $report)
    {
        $this->authorizeView($request, $report);
        $report->load('documents', 'user');
        return view('reports.print', compact('report'));
    }

    public function destroy(Request $request, Report $report)
    {
        $user = $request->user();
        abort_unless($user->isPetugas() || $report->user_id === $user->id, 403);
        $report->delete();
        return redirect()->route('reports.index')->with('success', 'Laporan dihapus.');
    }

    private function authorizeView(Request $request, Report $report): void
    {
        $user = $request->user();
        abort_unless($user->isPetugas() || $report->user_id === $user->id, 403);
    }
}
EOF

# ---------- 5. Views: layouts ----------
echo "==> Tulis views"

cat > resources/views/layouts/app.blade.php << 'EOF'
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="csrf-token" content="{{ csrf_token() }}">
  <title>@yield('title', 'SIPETA') · Sistem Pelaporan Sengketa Tanah</title>
  @vite(['resources/css/app.css', 'resources/js/app.js'])
  <style>
    body{background:#f8fafc;color:#0f172a}
    *:focus-visible{outline-color:#047857}
  </style>
</head>
<body class="min-h-screen" x-data="{ menu:false }">

  <header class="bg-white border-b border-slate-200 sticky top-0 z-20">
    <div class="max-w-5xl mx-auto px-4 h-14 flex items-center justify-between">
      <a href="{{ route('dashboard') }}" class="flex items-center gap-2 font-semibold text-slate-900">
        <span class="grid place-items-center w-8 h-8 rounded-lg bg-emerald-700 text-white">
          <svg viewBox="0 0 24 24" fill="none" class="w-5 h-5"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" stroke="currentColor" stroke-width="2"/></svg>
        </span>
        <span>SIPETA<span class="hidden sm:inline text-slate-400 font-normal text-sm"> · Sengketa Tanah</span></span>
      </a>

      <nav class="hidden md:flex items-center gap-1 text-sm">
        <a href="{{ route('dashboard') }}" class="px-3 py-2 rounded-lg text-slate-600 hover:bg-slate-100">Dashboard</a>
        <a href="{{ route('reports.index') }}" class="px-3 py-2 rounded-lg text-slate-600 hover:bg-slate-100">{{ auth()->user()->isPetugas() ? 'Semua Laporan' : 'Laporan Saya' }}</a>
        @unless(auth()->user()->isPetugas())
          <a href="{{ route('reports.create') }}" class="px-3 py-2 rounded-lg bg-emerald-700 text-white hover:bg-emerald-800">+ Buat Laporan</a>
        @endunless
        <span class="mx-2 h-5 w-px bg-slate-200"></span>
        <span class="text-slate-500 px-2">{{ auth()->user()->name }}@if(auth()->user()->isPetugas()) <span class="text-emerald-700">(Petugas)</span>@endif</span>
        <form method="POST" action="{{ route('logout') }}">@csrf
          <button class="px-3 py-2 rounded-lg text-slate-600 hover:bg-slate-100">Keluar</button>
        </form>
      </nav>

      <button @click="menu=!menu" class="md:hidden w-9 h-9 grid place-items-center rounded-lg hover:bg-slate-100">
        <svg viewBox="0 0 24 24" class="w-6 h-6" fill="none"><path d="M4 7h16M4 12h16M4 17h16" stroke="currentColor" stroke-width="2"/></svg>
      </button>
    </div>

    <div x-show="menu" x-cloak class="md:hidden border-t border-slate-200 bg-white px-4 py-2 space-y-1 text-sm">
      <a href="{{ route('dashboard') }}" class="block px-3 py-2 rounded-lg hover:bg-slate-100">Dashboard</a>
      <a href="{{ route('reports.index') }}" class="block px-3 py-2 rounded-lg hover:bg-slate-100">{{ auth()->user()->isPetugas() ? 'Semua Laporan' : 'Laporan Saya' }}</a>
      @unless(auth()->user()->isPetugas())
        <a href="{{ route('reports.create') }}" class="block px-3 py-2 rounded-lg bg-emerald-700 text-white">+ Buat Laporan</a>
      @endunless
      <div class="px-3 py-2 text-slate-500">{{ auth()->user()->name }}@if(auth()->user()->isPetugas()) (Petugas)@endif</div>
      <form method="POST" action="{{ route('logout') }}">@csrf
        <button class="block w-full text-left px-3 py-2 rounded-lg hover:bg-slate-100">Keluar</button>
      </form>
    </div>
  </header>

  <main class="max-w-5xl mx-auto px-4 py-6">
    @if(session('success'))
      <div x-data="{show:true}" x-show="show" class="mb-4 flex items-start gap-3 rounded-xl bg-emerald-50 ring-1 ring-emerald-200 text-emerald-800 px-4 py-3">
        <span class="mt-0.5">✓</span><p class="flex-1 text-sm">{{ session('success') }}</p>
        <button @click="show=false" class="text-emerald-600">✕</button>
      </div>
    @endif
    @yield('content')
  </main>

  <footer class="max-w-5xl mx-auto px-4 py-8 text-center text-xs text-slate-400">
    SIPETA — Sistem Pelaporan Sengketa Tanah · {{ date('Y') }}
  </footer>

  <style>[x-cloak]{display:none!important}</style>
</body>
</html>
EOF

cat > resources/views/layouts/guest.blade.php << 'EOF'
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>@yield('title', 'Masuk') · SIPETA</title>
  @vite(['resources/css/app.css', 'resources/js/app.js'])
  <style>body{background:#f1f5f9;color:#0f172a}*:focus-visible{outline-color:#047857}</style>
</head>
<body class="min-h-screen grid place-items-center px-4 py-10">
  <div class="w-full max-w-md">
    <div class="flex items-center justify-center gap-2 mb-6">
      <span class="grid place-items-center w-10 h-10 rounded-xl bg-emerald-700 text-white">
        <svg viewBox="0 0 24 24" fill="none" class="w-6 h-6"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" stroke="currentColor" stroke-width="2"/></svg>
      </span>
      <div>
        <p class="font-semibold text-slate-900 leading-tight">SIPETA</p>
        <p class="text-xs text-slate-500 leading-tight">Pelaporan Sengketa Tanah</p>
      </div>
    </div>
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-6">
      @yield('content')
    </div>
    <p class="text-center text-xs text-slate-400 mt-6">© {{ date('Y') }} SIPETA</p>
  </div>
</body>
</html>
EOF

# ---------- 6. Views: auth ----------
cat > resources/views/auth/login.blade.php << 'EOF'
@extends('layouts.guest')
@section('title', 'Masuk')
@section('content')
  <h1 class="text-lg font-semibold text-slate-900 mb-1">Masuk ke akun</h1>
  <p class="text-sm text-slate-500 mb-5">Silakan masuk untuk melanjutkan.</p>

  @if($errors->any())
    <div class="mb-4 rounded-lg bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-3 py-2">
      {{ $errors->first() }}
    </div>
  @endif

  <form method="POST" action="{{ route('login') }}" class="space-y-4">
    @csrf
    <div>
      <label class="block text-sm font-medium text-slate-700 mb-1">Email</label>
      <input name="email" type="email" value="{{ old('email') }}" required autofocus
             class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100 outline-none">
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700 mb-1">Kata sandi</label>
      <input name="password" type="password" required
             class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100 outline-none">
    </div>
    <label class="flex items-center gap-2 text-sm text-slate-600">
      <input type="checkbox" name="remember" class="rounded border-slate-300 text-emerald-600"> Ingat saya
    </label>
    <button class="w-full rounded-lg bg-emerald-700 text-white py-2.5 text-sm font-medium hover:bg-emerald-800">Masuk</button>
  </form>

  <p class="text-sm text-slate-500 text-center mt-5">
    Belum punya akun? <a href="{{ route('register') }}" class="text-emerald-700 font-medium hover:underline">Daftar</a>
  </p>
@endsection
EOF

cat > resources/views/auth/register.blade.php << 'EOF'
@extends('layouts.guest')
@section('title', 'Daftar')
@section('content')
  <h1 class="text-lg font-semibold text-slate-900 mb-1">Buat akun warga</h1>
  <p class="text-sm text-slate-500 mb-5">Daftar untuk mengajukan laporan sengketa tanah.</p>

  @if($errors->any())
    <div class="mb-4 rounded-lg bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-3 py-2">
      <ul class="list-disc pl-4 space-y-0.5">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul>
    </div>
  @endif

  <form method="POST" action="{{ route('register') }}" class="space-y-4">
    @csrf
    <div>
      <label class="block text-sm font-medium text-slate-700 mb-1">Nama lengkap</label>
      <input name="name" value="{{ old('name') }}" required
             class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100 outline-none">
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700 mb-1">Email</label>
      <input name="email" type="email" value="{{ old('email') }}" required
             class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100 outline-none">
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700 mb-1">No. HP / WhatsApp</label>
      <input name="no_hp" value="{{ old('no_hp') }}" required
             class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100 outline-none">
    </div>
    <div class="grid grid-cols-2 gap-3">
      <div>
        <label class="block text-sm font-medium text-slate-700 mb-1">Kata sandi</label>
        <input name="password" type="password" required
               class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100 outline-none">
      </div>
      <div>
        <label class="block text-sm font-medium text-slate-700 mb-1">Ulangi sandi</label>
        <input name="password_confirmation" type="password" required
               class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100 outline-none">
      </div>
    </div>
    <button class="w-full rounded-lg bg-emerald-700 text-white py-2.5 text-sm font-medium hover:bg-emerald-800">Daftar</button>
  </form>

  <p class="text-sm text-slate-500 text-center mt-5">
    Sudah punya akun? <a href="{{ route('login') }}" class="text-emerald-700 font-medium hover:underline">Masuk</a>
  </p>
@endsection
EOF

# ---------- 7. Views: dashboard ----------
cat > resources/views/dashboard.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Dashboard')
@section('content')
  <div class="flex items-end justify-between gap-3 mb-5">
    <div>
      <h1 class="text-xl font-semibold text-slate-900">Dashboard</h1>
      <p class="text-sm text-slate-500">{{ auth()->user()->isPetugas() ? 'Ringkasan seluruh laporan masuk.' : 'Ringkasan laporan yang Anda ajukan.' }}</p>
    </div>
    @unless(auth()->user()->isPetugas())
      <a href="{{ route('reports.create') }}" class="hidden sm:inline-flex rounded-lg bg-emerald-700 text-white px-4 py-2 text-sm hover:bg-emerald-800">+ Buat Laporan</a>
    @endunless
  </div>

  <div class="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-6">
    @foreach([
      ['Total', $stats['total'], 'text-slate-900', 'bg-slate-100'],
      ['Baru', $stats['baru'], 'text-sky-700', 'bg-sky-50'],
      ['Diproses', $stats['diproses'], 'text-amber-700', 'bg-amber-50'],
      ['Selesai', $stats['selesai'], 'text-emerald-700', 'bg-emerald-50'],
    ] as [$label, $val, $tc, $bg])
      <div class="bg-white rounded-xl ring-1 ring-slate-200 p-4">
        <div class="inline-flex w-9 h-9 rounded-lg {{ $bg }} mb-3"></div>
        <p class="text-2xl font-semibold {{ $tc }}">{{ $val }}</p>
        <p class="text-sm text-slate-500">{{ $label }}</p>
      </div>
    @endforeach
  </div>

  <div class="bg-white rounded-xl ring-1 ring-slate-200 overflow-hidden">
    <div class="flex items-center justify-between px-4 py-3 border-b border-slate-100">
      <h2 class="font-medium text-slate-900">Laporan terbaru</h2>
      <a href="{{ route('reports.index') }}" class="text-sm text-emerald-700 hover:underline">Lihat semua</a>
    </div>
    @forelse($terbaru as $r)
      <a href="{{ route('reports.show', $r) }}" class="flex items-center gap-3 px-4 py-3 border-b border-slate-50 hover:bg-slate-50">
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-slate-900 truncate">{{ $r->judul }}</p>
          <p class="text-xs text-slate-500 truncate">{{ $r->nomor }} · {{ $r->lokasi }}</p>
        </div>
        <span class="shrink-0 text-xs px-2 py-1 rounded-full ring-1 {{ $r->statusClasses() }}">{{ $r->statusLabel() }}</span>
      </a>
    @empty
      <div class="px-4 py-10 text-center text-sm text-slate-400">Belum ada laporan.</div>
    @endforelse
  </div>
@endsection
EOF

# ---------- 8. Views: reports index ----------
cat > resources/views/reports/index.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Laporan')
@section('content')
  <div class="flex items-end justify-between gap-3 mb-4">
    <h1 class="text-xl font-semibold text-slate-900">{{ auth()->user()->isPetugas() ? 'Semua Laporan' : 'Laporan Saya' }}</h1>
    @unless(auth()->user()->isPetugas())
      <a href="{{ route('reports.create') }}" class="rounded-lg bg-emerald-700 text-white px-4 py-2 text-sm hover:bg-emerald-800">+ Buat</a>
    @endunless
  </div>

  <form method="GET" class="flex flex-wrap gap-2 mb-4">
    <input name="q" value="{{ request('q') }}" placeholder="Cari nomor / judul / lokasi"
           class="flex-1 min-w-[180px] rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">
    <select name="status" class="rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">
      <option value="">Semua status</option>
      @foreach(['baru'=>'Baru','diproses'=>'Diproses','selesai'=>'Selesai','ditolak'=>'Ditolak'] as $k=>$v)
        <option value="{{ $k }}" @selected(request('status')===$k)>{{ $v }}</option>
      @endforeach
    </select>
    <button class="rounded-lg bg-slate-900 text-white px-4 py-2 text-sm">Filter</button>
  </form>

  <div class="bg-white rounded-xl ring-1 ring-slate-200 overflow-hidden">
    @forelse($reports as $r)
      <a href="{{ route('reports.show', $r) }}" class="flex items-center gap-3 px-4 py-3 border-b border-slate-50 hover:bg-slate-50">
        <div class="flex-1 min-w-0">
          <div class="flex items-center gap-2">
            <span class="text-xs font-mono text-slate-400">{{ $r->nomor }}</span>
            <span class="text-xs px-2 py-0.5 rounded-full ring-1 {{ $r->statusClasses() }}">{{ $r->statusLabel() }}</span>
          </div>
          <p class="text-sm font-medium text-slate-900 truncate mt-0.5">{{ $r->judul }}</p>
          <p class="text-xs text-slate-500 truncate">{{ $r->lokasi }}@if(auth()->user()->isPetugas()) · oleh {{ $r->user->name }}@endif</p>
        </div>
        <span class="text-xs text-slate-400 shrink-0">{{ $r->created_at->format('d/m/y') }}</span>
      </a>
    @empty
      <div class="px-4 py-10 text-center text-sm text-slate-400">Tidak ada laporan.</div>
    @endforelse
  </div>

  <div class="mt-4">{{ $reports->links() }}</div>
@endsection
EOF

# ---------- 9. Views: reports create ----------
cat > resources/views/reports/create.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Buat Laporan')
@section('content')
  <a href="{{ route('reports.index') }}" class="text-sm text-slate-500 hover:underline">&larr; Kembali</a>
  <h1 class="text-xl font-semibold text-slate-900 mt-2 mb-1">Buat Laporan Sengketa Tanah</h1>
  <p class="text-sm text-slate-500 mb-5">Isi data selengkap mungkin agar mudah ditindaklanjuti.</p>

  @if($errors->any())
    <div class="mb-4 rounded-lg bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-3 py-2">
      <ul class="list-disc pl-4 space-y-0.5">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul>
    </div>
  @endif

  <form method="POST" action="{{ route('reports.store') }}" enctype="multipart/form-data"
        x-data="reportForm()" class="space-y-6">
    @csrf

    <div class="bg-white rounded-xl ring-1 ring-slate-200 p-4 space-y-4">
      <p class="text-sm font-semibold text-slate-700">Data Pelapor & Perkara</p>
      <div>
        <label class="block text-sm font-medium text-slate-700 mb-1">Judul laporan</label>
        <input name="judul" value="{{ old('judul') }}" required placeholder="Cth: Sengketa batas tanah dengan tetangga"
               class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">
      </div>
      <div class="grid sm:grid-cols-2 gap-3">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">Nama pelapor</label>
          <input name="nama_pelapor" value="{{ old('nama_pelapor', auth()->user()->name) }}" required
                 class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">No. HP</label>
          <input name="no_hp" value="{{ old('no_hp', auth()->user()->no_hp) }}" required
                 class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">
        </div>
      </div>
      <div class="grid sm:grid-cols-2 gap-3">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">Jenis sengketa</label>
          <select name="jenis" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">
            <option value="">— pilih —</option>
            @foreach(['Batas tanah','Kepemilikan','Warisan','Jual beli','Sewa','Lainnya'] as $j)
              <option value="{{ $j }}" @selected(old('jenis')===$j)>{{ $j }}</option>
            @endforeach
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">Pihak terlapor (opsional)</label>
          <input name="pihak_terlapor" value="{{ old('pihak_terlapor') }}"
                 class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">
        </div>
      </div>
    </div>

    <div class="bg-white rounded-xl ring-1 ring-slate-200 p-4 space-y-4">
      <p class="text-sm font-semibold text-slate-700">Lokasi Tanah</p>
      <div>
        <label class="block text-sm font-medium text-slate-700 mb-1">Alamat / letak tanah</label>
        <textarea name="lokasi" rows="2" required placeholder="Dusun/Jalan, RT/RW, Desa/Kelurahan"
                  class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">{{ old('lokasi') }}</textarea>
      </div>
      <div class="grid sm:grid-cols-2 gap-3">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">Kecamatan</label>
          <input name="kecamatan" value="{{ old('kecamatan') }}"
                 class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">Luas (m²)</label>
          <input name="luas" type="number" step="0.01" value="{{ old('luas') }}"
                 class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">
        </div>
      </div>
      <div class="grid sm:grid-cols-2 gap-3">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">Latitude</label>
          <input name="latitude" x-ref="lat" value="{{ old('latitude') }}"
                 class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">
        </div>
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">Longitude</label>
          <input name="longitude" x-ref="lng" value="{{ old('longitude') }}"
                 class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">
        </div>
      </div>
      <button type="button" @click="ambilLokasi()"
              class="inline-flex items-center gap-2 rounded-lg ring-1 ring-emerald-300 text-emerald-700 px-3 py-2 text-sm hover:bg-emerald-50">
        <svg viewBox="0 0 24 24" class="w-4 h-4" fill="none"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" stroke="currentColor" stroke-width="2"/></svg>
        <span x-text="locLabel"></span>
      </button>
    </div>

    <div class="bg-white rounded-xl ring-1 ring-slate-200 p-4 space-y-4">
      <p class="text-sm font-semibold text-slate-700">Kronologi & Bukti</p>
      <div>
        <label class="block text-sm font-medium text-slate-700 mb-1">Kronologi kejadian</label>
        <textarea name="kronologi" rows="5" required placeholder="Ceritakan urutan kejadian sengketa..."
                  class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">{{ old('kronologi') }}</textarea>
      </div>
      <div>
        <label class="block text-sm font-medium text-slate-700 mb-1">Dokumen / foto bukti (maks. 6 file, jpg/png/pdf, ≤5MB)</label>
        <input type="file" name="dokumen[]" multiple accept=".jpg,.jpeg,.png,.pdf" @change="pickFiles($event)"
               class="block w-full text-sm text-slate-600 file:mr-3 file:rounded-lg file:border-0 file:bg-emerald-50 file:text-emerald-700 file:px-3 file:py-2">
        <ul class="mt-2 space-y-1" x-show="files.length">
          <template x-for="f in files" :key="f"><li class="text-xs text-slate-500">• <span x-text="f"></span></li></template>
        </ul>
      </div>
    </div>

    <div class="flex gap-3">
      <button class="rounded-lg bg-emerald-700 text-white px-5 py-2.5 text-sm font-medium hover:bg-emerald-800">Kirim Laporan</button>
      <a href="{{ route('reports.index') }}" class="rounded-lg ring-1 ring-slate-300 text-slate-600 px-5 py-2.5 text-sm hover:bg-slate-50">Batal</a>
    </div>
  </form>

  <script>
    function reportForm(){
      return {
        files: [], locLabel: 'Ambil lokasi saya (GPS)',
        pickFiles(e){ this.files = Array.from(e.target.files).map(f => f.name + ' (' + Math.round(f.size/1024) + ' KB)'); },
        ambilLokasi(){
          if(!navigator.geolocation){ this.locLabel = 'GPS tidak didukung'; return; }
          this.locLabel = 'Mengambil lokasi...';
          navigator.geolocation.getCurrentPosition(
            p => { this.$refs.lat.value = p.coords.latitude.toFixed(7); this.$refs.lng.value = p.coords.longitude.toFixed(7); this.locLabel = 'Lokasi terisi ✓'; },
            () => { this.locLabel = 'Gagal — isi manual'; }
          );
        },
      }
    }
  </script>
@endsection
EOF

# ---------- 10. Views: reports show ----------
cat > resources/views/reports/show.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Detail Laporan')
@section('content')
  <a href="{{ route('reports.index') }}" class="text-sm text-slate-500 hover:underline">&larr; Kembali</a>

  <div class="flex flex-wrap items-start justify-between gap-3 mt-2 mb-4">
    <div>
      <div class="flex items-center gap-2">
        <span class="text-xs font-mono text-slate-400">{{ $report->nomor }}</span>
        <span class="text-xs px-2 py-0.5 rounded-full ring-1 {{ $report->statusClasses() }}">{{ $report->statusLabel() }}</span>
      </div>
      <h1 class="text-xl font-semibold text-slate-900 mt-1">{{ $report->judul }}</h1>
      <p class="text-sm text-slate-500">Diajukan {{ $report->created_at->format('d M Y, H:i') }} oleh {{ $report->user->name }}</p>
    </div>
    <a href="{{ route('reports.print', $report) }}" target="_blank"
       class="inline-flex items-center gap-2 rounded-lg ring-1 ring-slate-300 text-slate-700 px-3 py-2 text-sm hover:bg-slate-50">
      🖨 Cetak / PDF
    </a>
  </div>

  <div class="grid lg:grid-cols-3 gap-4">
    <div class="lg:col-span-2 space-y-4">
      <div class="bg-white rounded-xl ring-1 ring-slate-200 p-4">
        <h2 class="text-sm font-semibold text-slate-700 mb-3">Rincian</h2>
        <dl class="grid sm:grid-cols-2 gap-x-6 gap-y-3 text-sm">
          <div><dt class="text-slate-400">Pelapor</dt><dd class="text-slate-800">{{ $report->nama_pelapor }} · {{ $report->no_hp }}</dd></div>
          <div><dt class="text-slate-400">Jenis</dt><dd class="text-slate-800">{{ $report->jenis ?: '—' }}</dd></div>
          <div><dt class="text-slate-400">Pihak terlapor</dt><dd class="text-slate-800">{{ $report->pihak_terlapor ?: '—' }}</dd></div>
          <div><dt class="text-slate-400">Luas</dt><dd class="text-slate-800">{{ $report->luas ? number_format($report->luas, 0, ',', '.').' m²' : '—' }}</dd></div>
          <div class="sm:col-span-2"><dt class="text-slate-400">Lokasi</dt><dd class="text-slate-800">{{ $report->lokasi }}{{ $report->kecamatan ? ', Kec. '.$report->kecamatan : '' }}</dd></div>
          @if($report->latitude && $report->longitude)
            <div class="sm:col-span-2"><dt class="text-slate-400">Koordinat</dt>
              <dd><a class="text-emerald-700 hover:underline" target="_blank" href="https://www.google.com/maps?q={{ $report->latitude }},{{ $report->longitude }}">{{ $report->latitude }}, {{ $report->longitude }} (lihat peta)</a></dd>
            </div>
          @endif
        </dl>
      </div>

      <div class="bg-white rounded-xl ring-1 ring-slate-200 p-4">
        <h2 class="text-sm font-semibold text-slate-700 mb-2">Kronologi</h2>
        <p class="text-sm text-slate-700 whitespace-pre-line">{{ $report->kronologi }}</p>
      </div>

      <div class="bg-white rounded-xl ring-1 ring-slate-200 p-4">
        <h2 class="text-sm font-semibold text-slate-700 mb-3">Dokumen / Bukti</h2>
        @forelse($report->documents as $doc)
          <a href="{{ asset('storage/'.$doc->path) }}" target="_blank" class="flex items-center gap-3 py-2 border-b border-slate-50 last:border-0 hover:bg-slate-50 -mx-1 px-1 rounded">
            @if($doc->isImage())
              <img src="{{ asset('storage/'.$doc->path) }}" class="w-10 h-10 rounded object-cover ring-1 ring-slate-200">
            @else
              <span class="grid place-items-center w-10 h-10 rounded bg-rose-50 text-rose-600 text-xs font-medium">PDF</span>
            @endif
            <span class="text-sm text-slate-700 truncate">{{ $doc->nama_asli }}</span>
          </a>
        @empty
          <p class="text-sm text-slate-400">Tidak ada dokumen.</p>
        @endforelse
      </div>
    </div>

    <div class="space-y-4">
      <div class="bg-white rounded-xl ring-1 ring-slate-200 p-4">
        <h2 class="text-sm font-semibold text-slate-700 mb-3">Status</h2>
        <span class="inline-block text-sm px-3 py-1 rounded-full ring-1 {{ $report->statusClasses() }}">{{ $report->statusLabel() }}</span>
        @if($report->catatan_petugas)
          <div class="mt-3 text-sm text-slate-600 bg-slate-50 rounded-lg p-3">
            <p class="text-xs text-slate-400 mb-1">Catatan petugas</p>{{ $report->catatan_petugas }}
          </div>
        @endif
      </div>

      @if(auth()->user()->isPetugas())
        <div class="bg-white rounded-xl ring-1 ring-slate-200 p-4">
          <h2 class="text-sm font-semibold text-slate-700 mb-3">Tindak lanjut (Petugas)</h2>
          <form method="POST" action="{{ route('reports.status', $report) }}" class="space-y-3">
            @csrf @method('PATCH')
            <select name="status" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">
              @foreach(['baru'=>'Baru','diproses'=>'Diproses','selesai'=>'Selesai','ditolak'=>'Ditolak'] as $k=>$v)
                <option value="{{ $k }}" @selected($report->status===$k)>{{ $v }}</option>
              @endforeach
            </select>
            <textarea name="catatan_petugas" rows="3" placeholder="Catatan untuk pelapor (opsional)"
                      class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">{{ $report->catatan_petugas }}</textarea>
            <button class="w-full rounded-lg bg-emerald-700 text-white py-2 text-sm hover:bg-emerald-800">Simpan</button>
          </form>
        </div>
      @endif

      @if(auth()->user()->isPetugas() || $report->user_id === auth()->id())
        <form method="POST" action="{{ route('reports.destroy', $report) }}" onsubmit="return confirm('Hapus laporan ini?')">
          @csrf @method('DELETE')
          <button class="w-full rounded-lg ring-1 ring-rose-300 text-rose-600 py-2 text-sm hover:bg-rose-50">Hapus laporan</button>
        </form>
      @endif
    </div>
  </div>
@endsection
EOF

# ---------- 11. Views: reports print ----------
cat > resources/views/reports/print.blade.php << 'EOF'
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <title>Laporan {{ $report->nomor }}</title>
  <style>
    *{box-sizing:border-box} body{font-family:'Times New Roman',serif;color:#111;margin:0;padding:32px;line-height:1.5}
    .sheet{max-width:720px;margin:0 auto}
    .kop{text-align:center;border-bottom:3px double #111;padding-bottom:10px;margin-bottom:18px}
    .kop h1{font-size:18px;margin:0;text-transform:uppercase}
    .kop p{margin:2px 0;font-size:13px}
    h2{font-size:15px;text-align:center;text-decoration:underline;margin:18px 0 4px}
    .meta{text-align:center;font-size:13px;margin-bottom:18px}
    table{width:100%;border-collapse:collapse;font-size:14px}
    td{padding:4px 6px;vertical-align:top}
    td.l{width:160px;color:#333}
    td.s{width:14px}
    .sec{margin-top:14px;font-size:14px}
    .sec b{display:block;margin-bottom:4px}
    .ttd{margin-top:48px;display:flex;justify-content:flex-end;text-align:center;font-size:14px}
    .bar{position:fixed;top:0;left:0;right:0;background:#047857;color:#fff;padding:10px;text-align:center}
    .bar button{background:#fff;color:#047857;border:0;padding:6px 14px;border-radius:6px;font-weight:600;cursor:pointer}
    @media print{ .bar{display:none} body{padding:0} }
  </style>
</head>
<body>
  <div class="bar">Tekan tombol untuk menyimpan sebagai PDF &nbsp; <button onclick="window.print()">Cetak / Simpan PDF</button></div>

  <div class="sheet" style="margin-top:48px">
    <div class="kop">
      <h1>Pemerintah Kabupaten</h1>
      <p>Sistem Informasi Pelaporan Sengketa Tanah (SIPETA)</p>
    </div>

    <h2>Laporan Sengketa Tanah</h2>
    <p class="meta">Nomor: {{ $report->nomor }}</p>

    <table>
      <tr><td class="l">Judul</td><td class="s">:</td><td>{{ $report->judul }}</td></tr>
      <tr><td class="l">Nama Pelapor</td><td class="s">:</td><td>{{ $report->nama_pelapor }}</td></tr>
      <tr><td class="l">No. HP</td><td class="s">:</td><td>{{ $report->no_hp }}</td></tr>
      <tr><td class="l">Jenis Sengketa</td><td class="s">:</td><td>{{ $report->jenis ?: '-' }}</td></tr>
      <tr><td class="l">Pihak Terlapor</td><td class="s">:</td><td>{{ $report->pihak_terlapor ?: '-' }}</td></tr>
      <tr><td class="l">Lokasi Tanah</td><td class="s">:</td><td>{{ $report->lokasi }}{{ $report->kecamatan ? ', Kec. '.$report->kecamatan : '' }}</td></tr>
      <tr><td class="l">Luas</td><td class="s">:</td><td>{{ $report->luas ? number_format($report->luas,0,',','.').' m²' : '-' }}</td></tr>
      @if($report->latitude)<tr><td class="l">Koordinat</td><td class="s">:</td><td>{{ $report->latitude }}, {{ $report->longitude }}</td></tr>@endif
      <tr><td class="l">Status</td><td class="s">:</td><td>{{ $report->statusLabel() }}</td></tr>
      <tr><td class="l">Tanggal Lapor</td><td class="s">:</td><td>{{ $report->created_at->format('d F Y') }}</td></tr>
    </table>

    <div class="sec"><b>Kronologi:</b>{{ $report->kronologi }}</div>
    @if($report->catatan_petugas)<div class="sec"><b>Catatan Petugas:</b>{{ $report->catatan_petugas }}</div>@endif

    <div class="ttd">
      <div>
        <p>{{ $report->kecamatan ?: '....................' }}, {{ now()->format('d F Y') }}</p>
        <p>Pelapor,</p>
        <br><br><br>
        <p>( {{ $report->nama_pelapor }} )</p>
      </div>
    </div>
  </div>
</body>
</html>
EOF

# ---------- 12. Routes ----------
echo "==> Tambah routes"
if ! grep -q "reports.index" routes/web.php; then
cat >> routes/web.php << 'EOF'

// ===== SIPETA — Pelaporan Sengketa Tanah =====
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
EOF
fi

# ---------- 13. Migrate, storage, akun petugas, build ----------
echo "==> Migrasi database"
php artisan migrate --force

echo "==> Link storage (untuk file bukti)"
php artisan storage:link || true

echo "==> Buat akun petugas contoh"
php artisan tinker --execute="App\Models\User::updateOrCreate(['email'=>'petugas@sipeta.test'],['name'=>'Petugas Camat','password'=>bcrypt('password'),'role'=>'petugas','no_hp'=>'08123456789']);"

echo "==> Build asset"
php artisan optimize:clear
npm run build

echo ""
echo "============================================================"
echo "  SELESAI ✓  SIPETA siap dipakai."
echo "  Jalankan server:  php artisan serve --host=0.0.0.0 --port=8000"
echo "  Buka:             http://127.0.0.1:8000/login"
echo ""
echo "  Akun petugas siap pakai:"
echo "     email    : petugas@sipeta.test"
echo "     password : password"
echo "  (Warga daftar sendiri lewat tombol 'Daftar'.)"
echo "============================================================"
