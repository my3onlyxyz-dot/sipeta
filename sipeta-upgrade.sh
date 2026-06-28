#!/usr/bin/env bash
# ============================================================
#  SIPETA v2 — Upgrade ke aplikasi kantor lengkap
#  Jalankan di dalam folder ~/myapp:  bash sipeta-upgrade.sh
#  Aman: menimpa view/controller & menambah modul. Data lama tetap.
# ============================================================
set -e
APP_DIR="$(pwd)"
[ -f artisan ] || { echo "!! Jalankan di dalam folder Laravel (~/myapp)."; exit 1; }
echo "==> Project: $APP_DIR"

mkdir -p app/Http/Controllers app/Models database/migrations \
         resources/views/layouts resources/views/auth resources/views/reports \
         resources/views/mediations resources/views/users resources/views/profile \
         resources/views/rekap resources/views/notifications resources/views/partials

# ============================================================
# 1. MIGRATIONS (tambahan)
# ============================================================
echo "==> Migrations tambahan"

cat > database/migrations/2026_06_28_120001_extend_users_and_reports.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        if (! Schema::hasColumn('users', 'is_active')) {
            Schema::table('users', fn (Blueprint $t) => $t->boolean('is_active')->default(true)->after('no_hp'));
        }
        Schema::table('reports', function (Blueprint $t) {
            if (! Schema::hasColumn('reports', 'assigned_to'))      $t->foreignId('assigned_to')->nullable()->after('user_id')->constrained('users')->nullOnDelete();
            if (! Schema::hasColumn('reports', 'prioritas'))        $t->string('prioritas')->default('sedang')->after('status');
            if (! Schema::hasColumn('reports', 'tanggal_kejadian')) $t->date('tanggal_kejadian')->nullable()->after('kronologi');
        });
    }
    public function down(): void {}
};
EOF

cat > database/migrations/2026_06_28_120002_create_report_activities_table.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('report_activities', function (Blueprint $t) {
            $t->id();
            $t->foreignId('report_id')->constrained()->cascadeOnDelete();
            $t->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $t->string('tipe')->default('info');
            $t->text('deskripsi');
            $t->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('report_activities'); }
};
EOF

cat > database/migrations/2026_06_28_120003_create_mediations_table.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('mediations', function (Blueprint $t) {
            $t->id();
            $t->foreignId('report_id')->constrained()->cascadeOnDelete();
            $t->foreignId('dijadwalkan_oleh')->nullable()->constrained('users')->nullOnDelete();
            $t->dateTime('tanggal');
            $t->string('tempat')->nullable();
            $t->text('agenda')->nullable();
            $t->text('hasil')->nullable();
            $t->string('status')->default('dijadwalkan'); // dijadwalkan | selesai | batal
            $t->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('mediations'); }
};
EOF

cat > database/migrations/2026_06_28_120004_create_pemberitahuan_table.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('pemberitahuan', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->string('judul');
            $t->text('isi')->nullable();
            $t->string('url')->nullable();
            $t->timestamp('dibaca_pada')->nullable();
            $t->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('pemberitahuan'); }
};
EOF

# ============================================================
# 2. MODELS
# ============================================================
echo "==> Models"

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

    protected $fillable = ['name', 'email', 'password', 'role', 'no_hp', 'is_active'];
    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return ['email_verified_at' => 'datetime', 'password' => 'hashed', 'is_active' => 'boolean'];
    }

    public function reports(): HasMany { return $this->hasMany(Report::class); }
    public function pemberitahuan(): HasMany { return $this->hasMany(Pemberitahuan::class); }

    public function isPetugas(): bool { return $this->role === 'petugas'; }
    public function isAdmin(): bool { return $this->role === 'admin'; }
    public function isStaff(): bool { return in_array($this->role, ['petugas', 'admin'], true); }
    public function isWarga(): bool { return $this->role === 'warga'; }

    public function roleLabel(): string
    {
        return ['admin' => 'Administrator', 'petugas' => 'Petugas', 'warga' => 'Warga'][$this->role] ?? $this->role;
    }

    public function initials(): string
    {
        $p = preg_split('/\s+/', trim($this->name));
        return strtoupper(mb_substr($p[0] ?? '', 0, 1) . mb_substr($p[1] ?? '', 0, 1));
    }

    public function unreadNotif(): int
    {
        return $this->pemberitahuan()->whereNull('dibaca_pada')->count();
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
        'user_id', 'assigned_to', 'nomor', 'judul', 'nama_pelapor', 'no_hp', 'jenis',
        'lokasi', 'kecamatan', 'luas', 'latitude', 'longitude', 'pihak_terlapor',
        'kronologi', 'tanggal_kejadian', 'status', 'prioritas', 'catatan_petugas',
    ];

    protected $casts = ['tanggal_kejadian' => 'date'];

    public function user(): BelongsTo { return $this->belongsTo(User::class); }
    public function assignee(): BelongsTo { return $this->belongsTo(User::class, 'assigned_to'); }
    public function documents(): HasMany { return $this->hasMany(ReportDocument::class); }
    public function activities(): HasMany { return $this->hasMany(ReportActivity::class)->latest(); }
    public function mediations(): HasMany { return $this->hasMany(Mediation::class)->latest('tanggal'); }

    public function addActivity(string $tipe, string $deskripsi): void
    {
        $this->activities()->create(['user_id' => auth()->id(), 'tipe' => $tipe, 'deskripsi' => $deskripsi]);
    }

    public function notifyOwner(string $judul, string $isi): void
    {
        if (auth()->id() === $this->user_id) return;
        Pemberitahuan::create([
            'user_id' => $this->user_id, 'judul' => $judul, 'isi' => $isi,
            'url' => route('reports.show', $this),
        ]);
    }

    public function statusLabel(): string
    {
        return ['baru'=>'Baru','diproses'=>'Diproses','selesai'=>'Selesai','ditolak'=>'Ditolak'][$this->status] ?? ucfirst($this->status);
    }
    public function statusClasses(): string
    {
        return [
            'baru'=>'bg-sky-50 text-sky-700 ring-sky-200',
            'diproses'=>'bg-amber-50 text-amber-700 ring-amber-200',
            'selesai'=>'bg-emerald-50 text-emerald-700 ring-emerald-200',
            'ditolak'=>'bg-rose-50 text-rose-700 ring-rose-200',
        ][$this->status] ?? 'bg-slate-100 text-slate-600 ring-slate-200';
    }
    public function prioritasLabel(): string
    {
        return ['rendah'=>'Rendah','sedang'=>'Sedang','tinggi'=>'Tinggi'][$this->prioritas] ?? ucfirst((string)$this->prioritas);
    }
    public function prioritasDot(): string
    {
        return ['rendah'=>'bg-slate-400','sedang'=>'bg-amber-500','tinggi'=>'bg-rose-500'][$this->prioritas] ?? 'bg-slate-400';
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
    public function isImage(): bool { return str_starts_with((string) $this->mime, 'image/'); }
}
EOF

cat > app/Models/ReportActivity.php << 'EOF'
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReportActivity extends Model
{
    protected $fillable = ['report_id', 'user_id', 'tipe', 'deskripsi'];
    public function report(): BelongsTo { return $this->belongsTo(Report::class); }
    public function user(): BelongsTo { return $this->belongsTo(User::class); }

    public function dotColor(): string
    {
        return [
            'dibuat'=>'bg-sky-500','status'=>'bg-amber-500','disposisi'=>'bg-violet-500',
            'mediasi'=>'bg-emerald-500','hapus'=>'bg-rose-500',
        ][$this->tipe] ?? 'bg-slate-400';
    }
}
EOF

cat > app/Models/Mediation.php << 'EOF'
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Mediation extends Model
{
    protected $fillable = ['report_id', 'dijadwalkan_oleh', 'tanggal', 'tempat', 'agenda', 'hasil', 'status'];
    protected $casts = ['tanggal' => 'datetime'];

    public function report(): BelongsTo { return $this->belongsTo(Report::class); }
    public function penjadwal(): BelongsTo { return $this->belongsTo(User::class, 'dijadwalkan_oleh'); }

    public function statusClasses(): string
    {
        return [
            'dijadwalkan'=>'bg-sky-50 text-sky-700 ring-sky-200',
            'selesai'=>'bg-emerald-50 text-emerald-700 ring-emerald-200',
            'batal'=>'bg-rose-50 text-rose-700 ring-rose-200',
        ][$this->status] ?? 'bg-slate-100 text-slate-600 ring-slate-200';
    }
}
EOF

cat > app/Models/Pemberitahuan.php << 'EOF'
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Pemberitahuan extends Model
{
    protected $table = 'pemberitahuan';
    protected $fillable = ['user_id', 'judul', 'isi', 'url', 'dibaca_pada'];
    protected $casts = ['dibaca_pada' => 'datetime'];
    public function user(): BelongsTo { return $this->belongsTo(User::class); }
}
EOF

# ============================================================
# 3. CONTROLLERS
# ============================================================
echo "==> Controllers"

cat > app/Http/Controllers/DashboardController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\Mediation;
use App\Models\Report;
use App\Models\ReportActivity;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $base = fn () => $user->isStaff() ? Report::query() : $user->reports();

        $stats = [
            'total'    => $base()->count(),
            'baru'     => $base()->where('status', 'baru')->count(),
            'diproses' => $base()->where('status', 'diproses')->count(),
            'selesai'  => $base()->where('status', 'selesai')->count(),
        ];

        $chart = collect(range(5, 0))->map(function ($i) use ($base) {
            $m = now()->subMonths($i);
            return ['label' => $m->format('M'), 'count' => $base()->whereYear('created_at', $m->year)->whereMonth('created_at', $m->month)->count()];
        });

        $ids = $base()->pluck('id');
        $activities = ReportActivity::with('report', 'user')->whereIn('report_id', $ids)->latest()->limit(8)->get();

        $mediasiMendatang = Mediation::with('report')->whereIn('report_id', $ids)
            ->where('status', 'dijadwalkan')->where('tanggal', '>=', now()->startOfDay())
            ->orderBy('tanggal')->limit(5)->get();

        return view('dashboard', compact('stats', 'chart', 'activities', 'mediasiMendatang'));
    }
}
EOF

cat > app/Http/Controllers/ReportController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\Report;
use App\Models\User;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = $user->isStaff() ? Report::query()->with('user', 'assignee') : $user->reports();

        if ($s = $request->query('status'))   $query->where('status', $s);
        if ($p = $request->query('prioritas')) $query->where('prioritas', $p);
        if ($request->query('saya') && $user->isStaff()) $query->where('assigned_to', $user->id);
        if ($q = $request->query('q')) {
            $query->where(fn ($w) => $w->where('judul', 'like', "%$q%")->orWhere('nomor', 'like', "%$q%")->orWhere('lokasi', 'like', "%$q%"));
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
            'prioritas' => ['required', 'in:rendah,sedang,tinggi'],
            'lokasi' => ['required', 'string'],
            'kecamatan' => ['nullable', 'string', 'max:100'],
            'luas' => ['nullable', 'numeric', 'min:0'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'pihak_terlapor' => ['nullable', 'string', 'max:255'],
            'tanggal_kejadian' => ['nullable', 'date'],
            'kronologi' => ['required', 'string'],
            'dokumen' => ['nullable', 'array', 'max:6'],
            'dokumen.*' => ['file', 'mimes:jpg,jpeg,png,pdf', 'max:5120'],
        ]);

        $report = $request->user()->reports()->create($data + ['status' => 'baru']);
        $report->update(['nomor' => 'TS-' . str_pad($report->id, 5, '0', STR_PAD_LEFT)]);

        foreach ((array) $request->file('dokumen') as $file) {
            $path = $file->store('dokumen', 'public');
            $report->documents()->create([
                'path' => $path, 'nama_asli' => $file->getClientOriginalName(),
                'mime' => $file->getMimeType(), 'ukuran' => $file->getSize(),
            ]);
        }

        $report->addActivity('dibuat', 'Laporan dibuat oleh ' . $request->user()->name);

        return redirect()->route('reports.show', $report)->with('success', 'Laporan terkirim. Nomor: ' . $report->nomor);
    }

    public function show(Request $request, Report $report)
    {
        $this->authorizeView($request, $report);
        $report->load('documents', 'user', 'assignee', 'activities.user', 'mediations.penjadwal');
        $petugasList = $request->user()->isStaff()
            ? User::whereIn('role', ['petugas', 'admin'])->where('is_active', true)->orderBy('name')->get()
            : collect();
        return view('reports.show', compact('report', 'petugasList'));
    }

    public function updateStatus(Request $request, Report $report)
    {
        abort_unless($request->user()->isStaff(), 403);
        $data = $request->validate([
            'status' => ['required', 'in:baru,diproses,selesai,ditolak'],
            'catatan_petugas' => ['nullable', 'string'],
        ]);
        $old = $report->statusLabel();
        $report->update($data);
        $report->addActivity('status', "Status diubah: {$old} → {$report->statusLabel()}");
        $report->notifyOwner('Status laporan diperbarui', "{$report->nomor} kini berstatus {$report->statusLabel()}.");
        return back()->with('success', 'Status laporan diperbarui.');
    }

    public function assign(Request $request, Report $report)
    {
        abort_unless($request->user()->isStaff(), 403);
        $data = $request->validate(['assigned_to' => ['nullable', 'exists:users,id']]);
        $report->update($data);
        $nama = $report->assignee?->name ?? '—';
        $report->addActivity('disposisi', "Laporan didisposisikan ke: {$nama}");
        if ($report->assigned_to) {
            \App\Models\Pemberitahuan::create([
                'user_id' => $report->assigned_to, 'judul' => 'Disposisi laporan baru',
                'isi' => "Anda ditugaskan menangani {$report->nomor}.", 'url' => route('reports.show', $report),
            ]);
        }
        return back()->with('success', 'Disposisi diperbarui.');
    }

    public function print(Request $request, Report $report)
    {
        $this->authorizeView($request, $report);
        $report->load('documents', 'user', 'assignee');
        return view('reports.print', compact('report'));
    }

    public function destroy(Request $request, Report $report)
    {
        $user = $request->user();
        abort_unless($user->isStaff() || $report->user_id === $user->id, 403);
        $report->delete();
        return redirect()->route('reports.index')->with('success', 'Laporan dihapus.');
    }

    private function authorizeView(Request $request, Report $report): void
    {
        $user = $request->user();
        abort_unless($user->isStaff() || $report->user_id === $user->id, 403);
    }
}
EOF

cat > app/Http/Controllers/MediationController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\Mediation;
use App\Models\Report;
use Illuminate\Http\Request;

class MediationController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $q = Mediation::with('report', 'penjadwal');
        if (! $user->isStaff()) {
            $q->whereIn('report_id', $user->reports()->pluck('id'));
        }
        $mediations = $q->orderByDesc('tanggal')->paginate(15);
        return view('mediations.index', compact('mediations'));
    }

    public function store(Request $request, Report $report)
    {
        abort_unless($request->user()->isStaff(), 403);
        $data = $request->validate([
            'tanggal' => ['required', 'date'],
            'tempat' => ['nullable', 'string', 'max:255'],
            'agenda' => ['nullable', 'string'],
        ]);
        $report->mediations()->create($data + ['dijadwalkan_oleh' => $request->user()->id, 'status' => 'dijadwalkan']);
        $report->addActivity('mediasi', 'Mediasi dijadwalkan: ' . \Illuminate\Support\Carbon::parse($data['tanggal'])->format('d M Y H:i'));
        $report->notifyOwner('Jadwal mediasi', "Mediasi {$report->nomor} dijadwalkan " . \Illuminate\Support\Carbon::parse($data['tanggal'])->format('d M Y H:i') . '.');
        return back()->with('success', 'Jadwal mediasi ditambahkan.');
    }

    public function update(Request $request, Mediation $mediation)
    {
        abort_unless($request->user()->isStaff(), 403);
        $data = $request->validate([
            'status' => ['required', 'in:dijadwalkan,selesai,batal'],
            'hasil' => ['nullable', 'string'],
        ]);
        $mediation->update($data);
        $mediation->report->addActivity('mediasi', "Mediasi {$mediation->status}");
        return back()->with('success', 'Mediasi diperbarui.');
    }

    public function destroy(Request $request, Mediation $mediation)
    {
        abort_unless($request->user()->isStaff(), 403);
        $mediation->delete();
        return back()->with('success', 'Jadwal mediasi dihapus.');
    }
}
EOF

cat > app/Http/Controllers/NotificationController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\Pemberitahuan;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $items = $request->user()->pemberitahuan()->latest()->paginate(20);
        return view('notifications.index', compact('items'));
    }

    public function open(Request $request, Pemberitahuan $pemberitahuan)
    {
        abort_unless($pemberitahuan->user_id === $request->user()->id, 403);
        $pemberitahuan->update(['dibaca_pada' => now()]);
        return redirect($pemberitahuan->url ?: route('dashboard'));
    }

    public function readAll(Request $request)
    {
        $request->user()->pemberitahuan()->whereNull('dibaca_pada')->update(['dibaca_pada' => now()]);
        return back()->with('success', 'Semua notifikasi ditandai dibaca.');
    }
}
EOF

cat > app/Http/Controllers/ProfileController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class ProfileController extends Controller
{
    public function edit() { return view('profile.edit'); }

    public function update(Request $request)
    {
        $user = $request->user();
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email,' . $user->id],
            'no_hp' => ['required', 'string', 'max:20'],
        ]);
        $user->update($data);
        return back()->with('success', 'Profil diperbarui.');
    }

    public function password(Request $request)
    {
        $request->validate([
            'current_password' => ['required'],
            'password' => ['required', 'confirmed', Password::min(6)],
        ]);
        if (! Hash::check($request->current_password, $request->user()->password)) {
            return back()->withErrors(['current_password' => 'Kata sandi saat ini salah.']);
        }
        $request->user()->update(['password' => $request->password]);
        return back()->with('success', 'Kata sandi diperbarui.');
    }
}
EOF

cat > app/Http/Controllers/UserController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class UserController extends Controller
{
    public function __construct()
    {
        $this->middleware(function ($request, $next) {
            abort_unless($request->user() && $request->user()->isAdmin(), 403);
            return $next($request);
        });
    }

    public function index(Request $request)
    {
        $users = User::when($request->query('q'), fn ($q, $s) => $q->where('name', 'like', "%$s%")->orWhere('email', 'like', "%$s%"))
            ->orderBy('name')->paginate(15)->withQueryString();
        return view('users.index', compact('users'));
    }

    public function create() { return view('users.create'); }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'no_hp' => ['nullable', 'string', 'max:20'],
            'role' => ['required', 'in:admin,petugas,warga'],
            'password' => ['required', 'min:6'],
        ]);
        User::create($data + ['is_active' => true]);
        return redirect()->route('users.index')->with('success', 'Pengguna ditambahkan.');
    }

    public function update(Request $request, User $user)
    {
        $data = $request->validate([
            'role' => ['required', 'in:admin,petugas,warga'],
            'is_active' => ['required', 'boolean'],
        ]);
        $user->update($data);
        return back()->with('success', 'Pengguna diperbarui.');
    }

    public function resetPassword(User $user)
    {
        $new = Str::password(10, true, true, false);
        $user->update(['password' => $new]);
        return back()->with('success', "Sandi {$user->name} direset menjadi: {$new}");
    }

    public function destroy(Request $request, User $user)
    {
        abort_if($user->id === $request->user()->id, 403, 'Tidak bisa menghapus akun sendiri.');
        $user->delete();
        return back()->with('success', 'Pengguna dihapus.');
    }
}
EOF

cat > app/Http/Controllers/RekapController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\Report;
use Illuminate\Http\Request;

class RekapController extends Controller
{
    public function index(Request $request)
    {
        abort_unless($request->user()->isStaff(), 403);

        $byStatus = Report::selectRaw('status, count(*) c')->groupBy('status')->pluck('c', 'status');
        $byJenis  = Report::selectRaw('jenis, count(*) c')->groupBy('jenis')->orderByDesc('c')->get();
        $byKec    = Report::selectRaw('kecamatan, count(*) c')->whereNotNull('kecamatan')->groupBy('kecamatan')->orderByDesc('c')->limit(10)->get();
        $total    = Report::count();

        return view('rekap.index', compact('byStatus', 'byJenis', 'byKec', 'total'));
    }
}
EOF

# ============================================================
# 4. LAYOUT (app shell elegan)
# ============================================================
echo "==> Layout & partials"

cat > resources/views/layouts/app.blade.php << 'EOF'
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="csrf-token" content="{{ csrf_token() }}">
  <title>@yield('title', 'Dashboard') · SIPETA</title>
  @vite(['resources/css/app.css', 'resources/js/app.js'])
  <style>
    body{background:#f1f5f9;color:#0f172a}
    *:focus-visible{outline-color:#047857}
    [x-cloak]{display:none!important}
    .nav-ico{width:18px;height:18px;flex:none}
  </style>
</head>
<body class="min-h-screen" x-data="{ sidebar:false, notif:false, user:false }">

  @php
    $u = auth()->user();
    $active = fn ($p) => request()->routeIs($p)
        ? 'bg-emerald-50 text-emerald-700 font-medium'
        : 'text-slate-600 hover:bg-slate-50';
    $notifs = $u->pemberitahuan()->latest()->limit(8)->get();
    $unread = $u->unreadNotif();
  @endphp

  <!-- overlay mobile -->
  <div x-show="sidebar" x-cloak @click="sidebar=false" class="fixed inset-0 bg-slate-900/40 z-30 lg:hidden"></div>

  <!-- SIDEBAR -->
  <aside class="fixed inset-y-0 left-0 w-64 bg-white border-r border-slate-200 z-40 flex flex-col transition-transform lg:translate-x-0"
         :class="sidebar ? 'translate-x-0' : '-translate-x-full'">
    <div class="h-16 flex items-center gap-2.5 px-5 border-b border-slate-100">
      <span class="grid place-items-center w-9 h-9 rounded-xl bg-emerald-700 text-white">
        <svg viewBox="0 0 24 24" fill="none" class="w-5 h-5"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" stroke="currentColor" stroke-width="2"/></svg>
      </span>
      <div class="leading-tight">
        <p class="font-display font-bold text-slate-900">SIPETA</p>
        <p class="text-[11px] text-slate-400">Sengketa Tanah</p>
      </div>
    </div>

    <nav class="flex-1 overflow-y-auto p-3 space-y-1 text-sm">
      <p class="px-3 pt-2 pb-1 text-[11px] font-semibold tracking-wider text-slate-400 uppercase">Menu Utama</p>
      <a href="{{ route('dashboard') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('dashboard') }}">
        <svg class="nav-ico" viewBox="0 0 24 24" fill="none"><path d="M4 13h6V4H4v9zM14 20h6v-9h-6v9zM14 4v4h6V4h-6zM4 20h6v-4H4v4z" stroke="currentColor" stroke-width="1.8"/></svg> Dashboard
      </a>
      <a href="{{ route('reports.index') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('reports.index') }}">
        <svg class="nav-ico" viewBox="0 0 24 24" fill="none"><path d="M8 4h8a2 2 0 012 2v14l-6-3-6 3V6a2 2 0 012-2z" stroke="currentColor" stroke-width="1.8"/></svg>
        {{ $u->isStaff() ? 'Semua Laporan' : 'Laporan Saya' }}
      </a>
      @unless($u->isStaff())
        <a href="{{ route('reports.create') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('reports.create') }}">
          <svg class="nav-ico" viewBox="0 0 24 24" fill="none"><path d="M12 5v14M5 12h14" stroke="currentColor" stroke-width="1.8"/></svg> Buat Laporan
        </a>
      @endunless
      <a href="{{ route('mediations.index') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('mediations.*') }}">
        <svg class="nav-ico" viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="16" rx="2" stroke="currentColor" stroke-width="1.8"/><path d="M3 9h18M8 3v4M16 3v4" stroke="currentColor" stroke-width="1.8"/></svg> Jadwal Mediasi
      </a>

      @if($u->isStaff())
        <p class="px-3 pt-4 pb-1 text-[11px] font-semibold tracking-wider text-slate-400 uppercase">Administrasi</p>
        <a href="{{ route('rekap.index') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('rekap.*') }}">
          <svg class="nav-ico" viewBox="0 0 24 24" fill="none"><path d="M4 19V5M4 19h16M8 16v-5M12 16V8M16 16v-3" stroke="currentColor" stroke-width="1.8"/></svg> Rekap & Statistik
        </a>
        @if($u->isAdmin())
          <a href="{{ route('users.index') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('users.*') }}">
            <svg class="nav-ico" viewBox="0 0 24 24" fill="none"><circle cx="9" cy="8" r="3" stroke="currentColor" stroke-width="1.8"/><path d="M3 20c0-3 3-5 6-5s6 2 6 5M17 11l2 2 3-3" stroke="currentColor" stroke-width="1.8"/></svg> Manajemen Pengguna
          </a>
        @endif
      @endif

      <p class="px-3 pt-4 pb-1 text-[11px] font-semibold tracking-wider text-slate-400 uppercase">Akun</p>
      <a href="{{ route('profile.edit') }}" class="flex items-center gap-3 px-3 py-2 rounded-lg {{ $active('profile.*') }}">
        <svg class="nav-ico" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="3.2" stroke="currentColor" stroke-width="1.8"/><path d="M5 20c0-3.3 3-6 7-6s7 2.7 7 6" stroke="currentColor" stroke-width="1.8"/></svg> Profil
      </a>
    </nav>

    <div class="p-3 border-t border-slate-100">
      <form method="POST" action="{{ route('logout') }}">@csrf
        <button class="flex items-center gap-3 w-full px-3 py-2 rounded-lg text-slate-600 hover:bg-rose-50 hover:text-rose-600 text-sm">
          <svg class="nav-ico" viewBox="0 0 24 24" fill="none"><path d="M15 12H3m4-4l-4 4 4 4M11 4h6a2 2 0 012 2v12a2 2 0 01-2 2h-6" stroke="currentColor" stroke-width="1.8"/></svg> Keluar
        </button>
      </form>
    </div>
  </aside>

  <!-- MAIN -->
  <div class="lg:pl-64">
    <!-- TOPBAR -->
    <header class="h-16 bg-white/90 backdrop-blur border-b border-slate-200 sticky top-0 z-20 flex items-center gap-3 px-4 lg:px-6">
      <button @click="sidebar=true" class="lg:hidden w-9 h-9 grid place-items-center rounded-lg hover:bg-slate-100">
        <svg viewBox="0 0 24 24" class="w-6 h-6" fill="none"><path d="M4 7h16M4 12h16M4 17h16" stroke="currentColor" stroke-width="2"/></svg>
      </button>
      <h1 class="font-display font-semibold text-slate-900 truncate">@yield('heading', View::getSection('title') ?? 'Dashboard')</h1>

      <div class="ml-auto flex items-center gap-1.5">
        <!-- notif -->
        <div class="relative">
          <button @click="notif=!notif; user=false" class="relative w-9 h-9 grid place-items-center rounded-lg hover:bg-slate-100">
            <svg viewBox="0 0 24 24" class="w-5 h-5" fill="none"><path d="M6 9a6 6 0 1112 0c0 5 2 6 2 6H4s2-1 2-6zM10 19a2 2 0 004 0" stroke="currentColor" stroke-width="1.8"/></svg>
            @if($unread)<span class="absolute top-1.5 right-1.5 w-4 h-4 rounded-full bg-rose-500 text-white text-[10px] grid place-items-center">{{ $unread > 9 ? '9+' : $unread }}</span>@endif
          </button>
          <div x-show="notif" x-cloak @click.outside="notif=false" class="absolute right-0 mt-2 w-80 bg-white rounded-xl ring-1 ring-slate-200 shadow-lg overflow-hidden">
            <div class="flex items-center justify-between px-4 py-2.5 border-b border-slate-100">
              <span class="text-sm font-medium">Notifikasi</span>
              @if($unread)<form method="POST" action="{{ route('notif.readAll') }}">@csrf<button class="text-xs text-emerald-700">Tandai dibaca</button></form>@endif
            </div>
            <div class="max-h-80 overflow-y-auto">
              @forelse($notifs as $n)
                <a href="{{ route('notif.open', $n) }}" class="block px-4 py-3 border-b border-slate-50 hover:bg-slate-50 {{ $n->dibaca_pada ? '' : 'bg-emerald-50/40' }}">
                  <p class="text-sm font-medium text-slate-800">{{ $n->judul }}</p>
                  <p class="text-xs text-slate-500">{{ $n->isi }}</p>
                  <p class="text-[11px] text-slate-400 mt-0.5">{{ $n->created_at->diffForHumans() }}</p>
                </a>
              @empty
                <p class="px-4 py-8 text-center text-sm text-slate-400">Belum ada notifikasi.</p>
              @endforelse
            </div>
          </div>
        </div>

        <!-- user -->
        <div class="relative">
          <button @click="user=!user; notif=false" class="flex items-center gap-2 pl-1 pr-2 py-1 rounded-lg hover:bg-slate-100">
            <span class="grid place-items-center w-8 h-8 rounded-full bg-emerald-700 text-white text-xs font-semibold">{{ $u->initials() }}</span>
            <span class="hidden sm:block text-left leading-tight">
              <span class="block text-sm font-medium text-slate-800">{{ $u->name }}</span>
              <span class="block text-[11px] text-slate-400">{{ $u->roleLabel() }}</span>
            </span>
          </button>
          <div x-show="user" x-cloak @click.outside="user=false" class="absolute right-0 mt-2 w-44 bg-white rounded-xl ring-1 ring-slate-200 shadow-lg py-1 text-sm">
            <a href="{{ route('profile.edit') }}" class="block px-4 py-2 hover:bg-slate-50">Profil & Sandi</a>
            <form method="POST" action="{{ route('logout') }}">@csrf<button class="block w-full text-left px-4 py-2 text-rose-600 hover:bg-rose-50">Keluar</button></form>
          </div>
        </div>
      </div>
    </header>

    <main class="p-4 lg:p-6 max-w-6xl mx-auto">
      @if(session('success'))
        <div x-data="{s:true}" x-show="s" class="mb-4 flex items-start gap-3 rounded-xl bg-emerald-50 ring-1 ring-emerald-200 text-emerald-800 px-4 py-3">
          <span class="mt-0.5">✓</span><p class="flex-1 text-sm">{{ session('success') }}</p><button @click="s=false">✕</button>
        </div>
      @endif
      @yield('content')
    </main>
  </div>
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
  <style>body{background:#0f172a;color:#0f172a}*:focus-visible{outline-color:#047857}</style>
</head>
<body class="min-h-screen grid lg:grid-cols-2">
  <div class="hidden lg:flex flex-col justify-between p-12 text-white relative overflow-hidden"
       style="background:radial-gradient(120% 120% at 0% 0%, #065f46 0%, #0f172a 70%)">
    <div class="flex items-center gap-2.5">
      <span class="grid place-items-center w-10 h-10 rounded-xl bg-white/10">
        <svg viewBox="0 0 24 24" fill="none" class="w-6 h-6"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" stroke="currentColor" stroke-width="2"/></svg>
      </span>
      <span class="font-display font-bold text-lg">SIPETA</span>
    </div>
    <div>
      <h2 class="font-display text-3xl font-bold leading-tight">Sistem Pelaporan<br>Sengketa Tanah</h2>
      <p class="text-emerald-100/80 mt-3 max-w-sm text-sm">Pelaporan, disposisi, penjadwalan mediasi, hingga rekap — dalam satu tempat yang rapi dan terpantau.</p>
    </div>
    <p class="text-emerald-100/50 text-xs">© {{ date('Y') }} SIPETA</p>
  </div>

  <div class="grid place-items-center px-4 py-10 bg-slate-50">
    <div class="w-full max-w-sm">
      <div class="lg:hidden flex items-center justify-center gap-2 mb-6">
        <span class="grid place-items-center w-9 h-9 rounded-xl bg-emerald-700 text-white">
          <svg viewBox="0 0 24 24" fill="none" class="w-5 h-5"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" stroke="currentColor" stroke-width="2"/></svg>
        </span>
        <span class="font-display font-bold">SIPETA</span>
      </div>
      @yield('content')
    </div>
  </div>
</body>
</html>
EOF

# ============================================================
# 5. VIEWS — auth (refresh ringan)
# ============================================================
cat > resources/views/auth/login.blade.php << 'EOF'
@extends('layouts.guest')
@section('title', 'Masuk')
@section('content')
  <h1 class="font-display text-2xl font-bold text-slate-900 mb-1">Selamat datang</h1>
  <p class="text-sm text-slate-500 mb-6">Masuk untuk melanjutkan ke SIPETA.</p>
  @if($errors->any())<div class="mb-4 rounded-lg bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-3 py-2">{{ $errors->first() }}</div>@endif
  <form method="POST" action="{{ route('login') }}" class="space-y-4">
    @csrf
    <div><label class="block text-sm font-medium text-slate-700 mb-1">Email</label>
      <input name="email" type="email" value="{{ old('email') }}" required autofocus class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100"></div>
    <div><label class="block text-sm font-medium text-slate-700 mb-1">Kata sandi</label>
      <input name="password" type="password" required class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100"></div>
    <label class="flex items-center gap-2 text-sm text-slate-600"><input type="checkbox" name="remember" class="rounded border-slate-300 text-emerald-600"> Ingat saya</label>
    <button class="w-full rounded-lg bg-emerald-700 text-white py-2.5 text-sm font-medium hover:bg-emerald-800">Masuk</button>
  </form>
  <p class="text-sm text-slate-500 text-center mt-6">Belum punya akun? <a href="{{ route('register') }}" class="text-emerald-700 font-medium hover:underline">Daftar sebagai warga</a></p>
@endsection
EOF

cat > resources/views/auth/register.blade.php << 'EOF'
@extends('layouts.guest')
@section('title', 'Daftar')
@section('content')
  <h1 class="font-display text-2xl font-bold text-slate-900 mb-1">Buat akun warga</h1>
  <p class="text-sm text-slate-500 mb-6">Daftar untuk mengajukan laporan.</p>
  @if($errors->any())<div class="mb-4 rounded-lg bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-3 py-2"><ul class="list-disc pl-4">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>@endif
  <form method="POST" action="{{ route('register') }}" class="space-y-4">
    @csrf
    <div><label class="block text-sm font-medium text-slate-700 mb-1">Nama lengkap</label><input name="name" value="{{ old('name') }}" required class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-emerald-600"></div>
    <div><label class="block text-sm font-medium text-slate-700 mb-1">Email</label><input name="email" type="email" value="{{ old('email') }}" required class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-emerald-600"></div>
    <div><label class="block text-sm font-medium text-slate-700 mb-1">No. HP / WhatsApp</label><input name="no_hp" value="{{ old('no_hp') }}" required class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-emerald-600"></div>
    <div class="grid grid-cols-2 gap-3">
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Sandi</label><input name="password" type="password" required class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-emerald-600"></div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Ulangi</label><input name="password_confirmation" type="password" required class="w-full rounded-lg border border-slate-300 px-3 py-2.5 text-sm outline-none focus:border-emerald-600"></div>
    </div>
    <button class="w-full rounded-lg bg-emerald-700 text-white py-2.5 text-sm font-medium hover:bg-emerald-800">Daftar</button>
  </form>
  <p class="text-sm text-slate-500 text-center mt-6">Sudah punya akun? <a href="{{ route('login') }}" class="text-emerald-700 font-medium hover:underline">Masuk</a></p>
@endsection
EOF

# ============================================================
# 6. VIEWS — dashboard
# ============================================================
cat > resources/views/dashboard.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Dashboard')
@section('content')
  @php $max = max($chart->max('count'), 1); @endphp
  <div class="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-5">
    @foreach([
      ['Total laporan',$stats['total'],'text-slate-900','from-slate-100 to-slate-50'],
      ['Baru',$stats['baru'],'text-sky-700','from-sky-100 to-sky-50'],
      ['Diproses',$stats['diproses'],'text-amber-700','from-amber-100 to-amber-50'],
      ['Selesai',$stats['selesai'],'text-emerald-700','from-emerald-100 to-emerald-50'],
    ] as [$l,$v,$tc,$bg])
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-4">
        <div class="w-10 h-10 rounded-xl bg-gradient-to-br {{ $bg }} mb-3"></div>
        <p class="font-display text-3xl font-bold {{ $tc }}">{{ $v }}</p>
        <p class="text-sm text-slate-500">{{ $l }}</p>
      </div>
    @endforeach
  </div>

  <div class="grid lg:grid-cols-3 gap-4">
    <div class="lg:col-span-2 bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <h2 class="font-display font-semibold text-slate-900 mb-4">Laporan 6 bulan terakhir</h2>
      <div class="flex items-end gap-3 h-40">
        @foreach($chart as $c)
          <div class="flex-1 bg-gradient-to-t from-emerald-600 to-emerald-400 rounded-t-lg relative" style="height:{{ max(3, round($c['count']/$max*100)) }}%">
            <span class="absolute -top-5 inset-x-0 text-center text-[11px] font-medium text-slate-500">{{ $c['count'] }}</span>
          </div>
        @endforeach
      </div>
      <div class="flex gap-3 mt-2">@foreach($chart as $c)<div class="flex-1 text-center text-xs text-slate-400">{{ $c['label'] }}</div>@endforeach</div>
    </div>

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <h2 class="font-display font-semibold text-slate-900 mb-3">Mediasi mendatang</h2>
      @forelse($mediasiMendatang as $m)
        <a href="{{ route('reports.show', $m->report) }}" class="block py-2 border-b border-slate-50 last:border-0">
          <p class="text-sm font-medium text-slate-800">{{ $m->tanggal->format('d M Y · H:i') }}</p>
          <p class="text-xs text-slate-500 truncate">{{ $m->report->judul }}</p>
        </a>
      @empty
        <p class="text-sm text-slate-400 py-6 text-center">Tidak ada jadwal.</p>
      @endforelse
    </div>
  </div>

  <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm mt-4">
    <div class="px-5 py-3 border-b border-slate-100 flex items-center justify-between">
      <h2 class="font-display font-semibold text-slate-900">Aktivitas terbaru</h2>
      <a href="{{ route('reports.index') }}" class="text-sm text-emerald-700 hover:underline">Lihat laporan</a>
    </div>
    <div class="p-5 space-y-4">
      @forelse($activities as $a)
        <div class="flex gap-3">
          <span class="mt-1.5 w-2 h-2 rounded-full {{ $a->dotColor() }} shrink-0"></span>
          <div class="flex-1 min-w-0">
            <p class="text-sm text-slate-700">{{ $a->deskripsi }}</p>
            <a href="{{ route('reports.show', $a->report) }}" class="text-xs text-slate-400 hover:text-emerald-700">{{ $a->report->nomor }} · {{ $a->created_at->diffForHumans() }}</a>
          </div>
        </div>
      @empty
        <p class="text-sm text-slate-400 text-center py-6">Belum ada aktivitas.</p>
      @endforelse
    </div>
  </div>
@endsection
EOF

# ============================================================
# 7. VIEWS — reports index
# ============================================================
cat > resources/views/reports/index.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Laporan')
@section('content')
  <div class="flex items-center justify-between gap-3 mb-4">
    <h1 class="font-display text-xl font-bold text-slate-900">{{ auth()->user()->isStaff() ? 'Semua Laporan' : 'Laporan Saya' }}</h1>
    @unless(auth()->user()->isStaff())
      <a href="{{ route('reports.create') }}" class="rounded-lg bg-emerald-700 text-white px-4 py-2 text-sm hover:bg-emerald-800">+ Buat</a>
    @endunless
  </div>

  <form method="GET" class="flex flex-wrap gap-2 mb-4">
    <input name="q" value="{{ request('q') }}" placeholder="Cari nomor / judul / lokasi" class="flex-1 min-w-[160px] rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600">
    <select name="status" class="rounded-lg border border-slate-300 px-3 py-2 text-sm">
      <option value="">Status</option>@foreach(['baru'=>'Baru','diproses'=>'Diproses','selesai'=>'Selesai','ditolak'=>'Ditolak'] as $k=>$v)<option value="{{ $k }}" @selected(request('status')===$k)>{{ $v }}</option>@endforeach
    </select>
    <select name="prioritas" class="rounded-lg border border-slate-300 px-3 py-2 text-sm">
      <option value="">Prioritas</option>@foreach(['rendah'=>'Rendah','sedang'=>'Sedang','tinggi'=>'Tinggi'] as $k=>$v)<option value="{{ $k }}" @selected(request('prioritas')===$k)>{{ $v }}</option>@endforeach
    </select>
    @if(auth()->user()->isStaff())
      <label class="flex items-center gap-1.5 text-sm text-slate-600 px-2"><input type="checkbox" name="saya" value="1" @checked(request('saya')) class="rounded border-slate-300 text-emerald-600"> Tugas saya</label>
    @endif
    <button class="rounded-lg bg-slate-900 text-white px-4 py-2 text-sm">Filter</button>
  </form>

  <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden">
    @forelse($reports as $r)
      <a href="{{ route('reports.show', $r) }}" class="flex items-center gap-3 px-4 py-3.5 border-b border-slate-50 last:border-0 hover:bg-slate-50">
        <span class="w-2 h-2 rounded-full {{ $r->prioritasDot() }} shrink-0" title="Prioritas {{ $r->prioritasLabel() }}"></span>
        <div class="flex-1 min-w-0">
          <div class="flex items-center gap-2">
            <span class="text-xs font-mono text-slate-400">{{ $r->nomor }}</span>
            <span class="text-xs px-2 py-0.5 rounded-full ring-1 {{ $r->statusClasses() }}">{{ $r->statusLabel() }}</span>
          </div>
          <p class="text-sm font-medium text-slate-900 truncate mt-0.5">{{ $r->judul }}</p>
          <p class="text-xs text-slate-500 truncate">{{ $r->lokasi }}@if(auth()->user()->isStaff()) · {{ $r->user->name }}@if($r->assignee) → {{ $r->assignee->name }}@endif @endif</p>
        </div>
        <span class="text-xs text-slate-400 shrink-0">{{ $r->created_at->format('d/m/y') }}</span>
      </a>
    @empty
      <div class="px-4 py-12 text-center text-sm text-slate-400">Tidak ada laporan.</div>
    @endforelse
  </div>
  <div class="mt-4">{{ $reports->links() }}</div>
@endsection
EOF

# ============================================================
# 8. VIEWS — reports create
# ============================================================
cat > resources/views/reports/create.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Buat Laporan')
@section('content')
  <a href="{{ route('reports.index') }}" class="text-sm text-slate-500 hover:underline">&larr; Kembali</a>
  <h1 class="font-display text-xl font-bold text-slate-900 mt-2 mb-1">Buat Laporan Sengketa Tanah</h1>
  <p class="text-sm text-slate-500 mb-5">Lengkapi data agar mudah ditindaklanjuti petugas.</p>
  @if($errors->any())<div class="mb-4 rounded-lg bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-3 py-2"><ul class="list-disc pl-4">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>@endif

  <form method="POST" action="{{ route('reports.store') }}" enctype="multipart/form-data" x-data="reportForm()" class="space-y-5">
    @csrf
    @php $inp = 'w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600 focus:ring-2 focus:ring-emerald-100'; @endphp

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 space-y-4">
      <p class="font-display font-semibold text-slate-700">Data Pelapor & Perkara</p>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Judul laporan</label><input name="judul" value="{{ old('judul') }}" required placeholder="Cth: Sengketa batas tanah dengan tetangga" class="{{ $inp }}"></div>
      <div class="grid sm:grid-cols-2 gap-3">
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Nama pelapor</label><input name="nama_pelapor" value="{{ old('nama_pelapor', auth()->user()->name) }}" required class="{{ $inp }}"></div>
        <div><label class="block text-sm font-medium text-slate-700 mb-1">No. HP</label><input name="no_hp" value="{{ old('no_hp', auth()->user()->no_hp) }}" required class="{{ $inp }}"></div>
      </div>
      <div class="grid sm:grid-cols-3 gap-3">
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Jenis sengketa</label>
          <select name="jenis" class="{{ $inp }}"><option value="">— pilih —</option>@foreach(['Batas tanah','Kepemilikan','Warisan','Jual beli','Sewa','Lainnya'] as $j)<option value="{{ $j }}" @selected(old('jenis')===$j)>{{ $j }}</option>@endforeach</select></div>
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Prioritas</label>
          <select name="prioritas" class="{{ $inp }}">@foreach(['rendah'=>'Rendah','sedang'=>'Sedang','tinggi'=>'Tinggi'] as $k=>$v)<option value="{{ $k }}" @selected(old('prioritas','sedang')===$k)>{{ $v }}</option>@endforeach</select></div>
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Tanggal kejadian</label><input name="tanggal_kejadian" type="date" value="{{ old('tanggal_kejadian') }}" class="{{ $inp }}"></div>
      </div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Pihak terlapor (opsional)</label><input name="pihak_terlapor" value="{{ old('pihak_terlapor') }}" class="{{ $inp }}"></div>
    </div>

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 space-y-4">
      <p class="font-display font-semibold text-slate-700">Lokasi Tanah</p>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Alamat / letak tanah</label><textarea name="lokasi" rows="2" required class="{{ $inp }}">{{ old('lokasi') }}</textarea></div>
      <div class="grid sm:grid-cols-2 gap-3">
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Kecamatan</label><input name="kecamatan" value="{{ old('kecamatan') }}" class="{{ $inp }}"></div>
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Luas (m²)</label><input name="luas" type="number" step="0.01" value="{{ old('luas') }}" class="{{ $inp }}"></div>
      </div>
      <div class="grid sm:grid-cols-2 gap-3">
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Latitude</label><input name="latitude" x-ref="lat" value="{{ old('latitude') }}" class="{{ $inp }}"></div>
        <div><label class="block text-sm font-medium text-slate-700 mb-1">Longitude</label><input name="longitude" x-ref="lng" value="{{ old('longitude') }}" class="{{ $inp }}"></div>
      </div>
      <button type="button" @click="ambilLokasi()" class="inline-flex items-center gap-2 rounded-lg ring-1 ring-emerald-300 text-emerald-700 px-3 py-2 text-sm hover:bg-emerald-50">
        <svg viewBox="0 0 24 24" class="w-4 h-4" fill="none"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" stroke="currentColor" stroke-width="2"/></svg><span x-text="locLabel"></span>
      </button>
    </div>

    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 space-y-4">
      <p class="font-display font-semibold text-slate-700">Kronologi & Bukti</p>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Kronologi kejadian</label><textarea name="kronologi" rows="5" required class="{{ $inp }}">{{ old('kronologi') }}</textarea></div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Dokumen / foto bukti (maks 6, jpg/png/pdf ≤5MB)</label>
        <input type="file" name="dokumen[]" multiple accept=".jpg,.jpeg,.png,.pdf" @change="pickFiles($event)" class="block w-full text-sm text-slate-600 file:mr-3 file:rounded-lg file:border-0 file:bg-emerald-50 file:text-emerald-700 file:px-3 file:py-2">
        <ul class="mt-2 space-y-1" x-show="files.length"><template x-for="f in files" :key="f"><li class="text-xs text-slate-500">• <span x-text="f"></span></li></template></ul>
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
          if(!navigator.geolocation){ this.locLabel='GPS tidak didukung'; return; }
          this.locLabel='Mengambil lokasi...';
          navigator.geolocation.getCurrentPosition(
            p => { this.$refs.lat.value=p.coords.latitude.toFixed(7); this.$refs.lng.value=p.coords.longitude.toFixed(7); this.locLabel='Lokasi terisi ✓'; },
            () => { this.locLabel='Gagal — isi manual'; });
        },
      }
    }
  </script>
@endsection
EOF

# ============================================================
# 9. VIEWS — reports show
# ============================================================
cat > resources/views/reports/show.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Detail Laporan')
@section('content')
  <a href="{{ route('reports.index') }}" class="text-sm text-slate-500 hover:underline">&larr; Kembali</a>
  <div class="flex flex-wrap items-start justify-between gap-3 mt-2 mb-4">
    <div>
      <div class="flex items-center gap-2 flex-wrap">
        <span class="text-xs font-mono text-slate-400">{{ $report->nomor }}</span>
        <span class="text-xs px-2 py-0.5 rounded-full ring-1 {{ $report->statusClasses() }}">{{ $report->statusLabel() }}</span>
        <span class="inline-flex items-center gap-1 text-xs text-slate-500"><span class="w-1.5 h-1.5 rounded-full {{ $report->prioritasDot() }}"></span>Prioritas {{ $report->prioritasLabel() }}</span>
      </div>
      <h1 class="font-display text-xl font-bold text-slate-900 mt-1">{{ $report->judul }}</h1>
      <p class="text-sm text-slate-500">Diajukan {{ $report->created_at->format('d M Y, H:i') }} oleh {{ $report->user->name }}</p>
    </div>
    <a href="{{ route('reports.print', $report) }}" target="_blank" class="inline-flex items-center gap-2 rounded-lg ring-1 ring-slate-300 text-slate-700 px-3 py-2 text-sm hover:bg-slate-50">🖨 Cetak / PDF</a>
  </div>

  <div class="grid lg:grid-cols-3 gap-4">
    <div class="lg:col-span-2 space-y-4">
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-700 mb-3">Rincian</h2>
        <dl class="grid sm:grid-cols-2 gap-x-6 gap-y-3 text-sm">
          <div><dt class="text-slate-400">Pelapor</dt><dd class="text-slate-800">{{ $report->nama_pelapor }} · {{ $report->no_hp }}</dd></div>
          <div><dt class="text-slate-400">Jenis</dt><dd class="text-slate-800">{{ $report->jenis ?: '—' }}</dd></div>
          <div><dt class="text-slate-400">Pihak terlapor</dt><dd class="text-slate-800">{{ $report->pihak_terlapor ?: '—' }}</dd></div>
          <div><dt class="text-slate-400">Luas</dt><dd class="text-slate-800">{{ $report->luas ? number_format($report->luas,0,',','.').' m²' : '—' }}</dd></div>
          <div><dt class="text-slate-400">Tanggal kejadian</dt><dd class="text-slate-800">{{ $report->tanggal_kejadian?->format('d M Y') ?: '—' }}</dd></div>
          <div><dt class="text-slate-400">Petugas penanganan</dt><dd class="text-slate-800">{{ $report->assignee?->name ?: 'Belum didisposisi' }}</dd></div>
          <div class="sm:col-span-2"><dt class="text-slate-400">Lokasi</dt><dd class="text-slate-800">{{ $report->lokasi }}{{ $report->kecamatan ? ', Kec. '.$report->kecamatan : '' }}</dd></div>
          @if($report->latitude && $report->longitude)
            <div class="sm:col-span-2"><dt class="text-slate-400">Koordinat</dt><dd><a class="text-emerald-700 hover:underline" target="_blank" href="https://www.google.com/maps?q={{ $report->latitude }},{{ $report->longitude }}">{{ $report->latitude }}, {{ $report->longitude }} (peta)</a></dd></div>
          @endif
        </dl>
      </div>

      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-700 mb-2">Kronologi</h2>
        <p class="text-sm text-slate-700 whitespace-pre-line">{{ $report->kronologi }}</p>
      </div>

      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-700 mb-3">Dokumen / Bukti</h2>
        @forelse($report->documents as $doc)
          <a href="{{ asset('storage/'.$doc->path) }}" target="_blank" class="flex items-center gap-3 py-2 border-b border-slate-50 last:border-0 hover:bg-slate-50 -mx-1 px-1 rounded">
            @if($doc->isImage())<img src="{{ asset('storage/'.$doc->path) }}" class="w-10 h-10 rounded object-cover ring-1 ring-slate-200">@else<span class="grid place-items-center w-10 h-10 rounded bg-rose-50 text-rose-600 text-xs font-medium">PDF</span>@endif
            <span class="text-sm text-slate-700 truncate">{{ $doc->nama_asli }}</span>
          </a>
        @empty<p class="text-sm text-slate-400">Tidak ada dokumen.</p>@endforelse
      </div>

      <!-- TIMELINE -->
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-700 mb-4">Riwayat / Timeline</h2>
        <div class="relative pl-4 space-y-4 before:absolute before:left-1 before:top-1 before:bottom-1 before:w-px before:bg-slate-200">
          @foreach($report->activities as $a)
            <div class="relative">
              <span class="absolute -left-[13px] top-1 w-2.5 h-2.5 rounded-full ring-4 ring-white {{ $a->dotColor() }}"></span>
              <p class="text-sm text-slate-700">{{ $a->deskripsi }}</p>
              <p class="text-xs text-slate-400">{{ $a->user?->name ?? 'Sistem' }} · {{ $a->created_at->format('d M Y H:i') }}</p>
            </div>
          @endforeach
        </div>
      </div>
    </div>

    <div class="space-y-4">
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-700 mb-3">Status</h2>
        <span class="inline-block text-sm px-3 py-1 rounded-full ring-1 {{ $report->statusClasses() }}">{{ $report->statusLabel() }}</span>
        @if($report->catatan_petugas)<div class="mt-3 text-sm text-slate-600 bg-slate-50 rounded-lg p-3"><p class="text-xs text-slate-400 mb-1">Catatan petugas</p>{{ $report->catatan_petugas }}</div>@endif
      </div>

      @if(auth()->user()->isStaff())
        <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
          <h2 class="font-display font-semibold text-slate-700 mb-3">Disposisi</h2>
          <form method="POST" action="{{ route('reports.assign', $report) }}" class="flex gap-2">@csrf
            <select name="assigned_to" class="flex-1 rounded-lg border border-slate-300 px-3 py-2 text-sm">
              <option value="">— belum —</option>
              @foreach($petugasList as $p)<option value="{{ $p->id }}" @selected($report->assigned_to==$p->id)>{{ $p->name }} ({{ $p->roleLabel() }})</option>@endforeach
            </select>
            <button class="rounded-lg bg-slate-900 text-white px-3 py-2 text-sm">Set</button>
          </form>
        </div>

        <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
          <h2 class="font-display font-semibold text-slate-700 mb-3">Ubah Status</h2>
          <form method="POST" action="{{ route('reports.status', $report) }}" class="space-y-3">@csrf @method('PATCH')
            <select name="status" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">@foreach(['baru'=>'Baru','diproses'=>'Diproses','selesai'=>'Selesai','ditolak'=>'Ditolak'] as $k=>$v)<option value="{{ $k }}" @selected($report->status===$k)>{{ $v }}</option>@endforeach</select>
            <textarea name="catatan_petugas" rows="3" placeholder="Catatan untuk pelapor" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">{{ $report->catatan_petugas }}</textarea>
            <button class="w-full rounded-lg bg-emerald-700 text-white py-2 text-sm hover:bg-emerald-800">Simpan</button>
          </form>
        </div>

        <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
          <h2 class="font-display font-semibold text-slate-700 mb-3">Jadwalkan Mediasi</h2>
          <form method="POST" action="{{ route('mediations.store', $report) }}" class="space-y-2">@csrf
            <input type="datetime-local" name="tanggal" required class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">
            <input name="tempat" placeholder="Tempat" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">
            <textarea name="agenda" rows="2" placeholder="Agenda" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"></textarea>
            <button class="w-full rounded-lg ring-1 ring-emerald-300 text-emerald-700 py-2 text-sm hover:bg-emerald-50">+ Tambah jadwal</button>
          </form>
        </div>
      @endif

      @if($report->mediations->count())
        <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
          <h2 class="font-display font-semibold text-slate-700 mb-3">Mediasi</h2>
          <div class="space-y-3">
            @foreach($report->mediations as $m)
              <div class="border border-slate-100 rounded-lg p-3">
                <div class="flex items-center justify-between">
                  <p class="text-sm font-medium text-slate-800">{{ $m->tanggal->format('d M Y · H:i') }}</p>
                  <span class="text-xs px-2 py-0.5 rounded-full ring-1 {{ $m->statusClasses() }}">{{ ucfirst($m->status) }}</span>
                </div>
                @if($m->tempat)<p class="text-xs text-slate-500">📍 {{ $m->tempat }}</p>@endif
                @if($m->agenda)<p class="text-xs text-slate-500 mt-1">{{ $m->agenda }}</p>@endif
                @if($m->hasil)<p class="text-xs text-emerald-700 mt-1">Hasil: {{ $m->hasil }}</p>@endif
                @if(auth()->user()->isStaff())
                  <form method="POST" action="{{ route('mediations.update', $m) }}" class="mt-2 flex gap-2">@csrf @method('PATCH')
                    <select name="status" class="rounded-lg border border-slate-300 px-2 py-1 text-xs">@foreach(['dijadwalkan'=>'Dijadwalkan','selesai'=>'Selesai','batal'=>'Batal'] as $k=>$v)<option value="{{ $k }}" @selected($m->status===$k)>{{ $v }}</option>@endforeach</select>
                    <input name="hasil" value="{{ $m->hasil }}" placeholder="Hasil" class="flex-1 rounded-lg border border-slate-300 px-2 py-1 text-xs">
                    <button class="rounded-lg bg-slate-900 text-white px-2 py-1 text-xs">OK</button>
                  </form>
                @endif
              </div>
            @endforeach
          </div>
        </div>
      @endif

      @if(auth()->user()->isStaff() || $report->user_id === auth()->id())
        <form method="POST" action="{{ route('reports.destroy', $report) }}" onsubmit="return confirm('Hapus laporan ini?')">@csrf @method('DELETE')
          <button class="w-full rounded-lg ring-1 ring-rose-300 text-rose-600 py-2 text-sm hover:bg-rose-50">Hapus laporan</button>
        </form>
      @endif
    </div>
  </div>
@endsection
EOF

# ============================================================
# 10. VIEWS — reports print (kop)
# ============================================================
cat > resources/views/reports/print.blade.php << 'EOF'
<!doctype html><html lang="id"><head><meta charset="utf-8"><title>Laporan {{ $report->nomor }}</title>
<style>
*{box-sizing:border-box}body{font-family:'Times New Roman',serif;color:#111;margin:0;padding:32px;line-height:1.5}
.sheet{max-width:720px;margin:0 auto}.kop{text-align:center;border-bottom:3px double #111;padding-bottom:10px;margin-bottom:18px}
.kop h1{font-size:18px;margin:0;text-transform:uppercase}.kop p{margin:2px 0;font-size:13px}
h2{font-size:15px;text-align:center;text-decoration:underline;margin:18px 0 4px}.meta{text-align:center;font-size:13px;margin-bottom:18px}
table{width:100%;border-collapse:collapse;font-size:14px}td{padding:4px 6px;vertical-align:top}td.l{width:160px;color:#333}td.s{width:14px}
.sec{margin-top:14px;font-size:14px}.sec b{display:block;margin-bottom:4px}.ttd{margin-top:48px;display:flex;justify-content:flex-end;text-align:center;font-size:14px}
.bar{position:fixed;top:0;left:0;right:0;background:#047857;color:#fff;padding:10px;text-align:center}
.bar button{background:#fff;color:#047857;border:0;padding:6px 14px;border-radius:6px;font-weight:600;cursor:pointer}
@media print{.bar{display:none}body{padding:0}}
</style></head><body>
<div class="bar">Simpan sebagai PDF &nbsp;<button onclick="window.print()">Cetak / Simpan PDF</button></div>
<div class="sheet" style="margin-top:48px">
  <div class="kop"><h1>Pemerintah Kabupaten</h1><p>Sistem Informasi Pelaporan Sengketa Tanah (SIPETA)</p></div>
  <h2>Laporan Sengketa Tanah</h2><p class="meta">Nomor: {{ $report->nomor }}</p>
  <table>
    <tr><td class="l">Judul</td><td class="s">:</td><td>{{ $report->judul }}</td></tr>
    <tr><td class="l">Nama Pelapor</td><td class="s">:</td><td>{{ $report->nama_pelapor }}</td></tr>
    <tr><td class="l">No. HP</td><td class="s">:</td><td>{{ $report->no_hp }}</td></tr>
    <tr><td class="l">Jenis Sengketa</td><td class="s">:</td><td>{{ $report->jenis ?: '-' }}</td></tr>
    <tr><td class="l">Prioritas</td><td class="s">:</td><td>{{ $report->prioritasLabel() }}</td></tr>
    <tr><td class="l">Pihak Terlapor</td><td class="s">:</td><td>{{ $report->pihak_terlapor ?: '-' }}</td></tr>
    <tr><td class="l">Lokasi Tanah</td><td class="s">:</td><td>{{ $report->lokasi }}{{ $report->kecamatan ? ', Kec. '.$report->kecamatan : '' }}</td></tr>
    <tr><td class="l">Luas</td><td class="s">:</td><td>{{ $report->luas ? number_format($report->luas,0,',','.').' m²' : '-' }}</td></tr>
    @if($report->latitude)<tr><td class="l">Koordinat</td><td class="s">:</td><td>{{ $report->latitude }}, {{ $report->longitude }}</td></tr>@endif
    <tr><td class="l">Petugas</td><td class="s">:</td><td>{{ $report->assignee?->name ?: '-' }}</td></tr>
    <tr><td class="l">Status</td><td class="s">:</td><td>{{ $report->statusLabel() }}</td></tr>
    <tr><td class="l">Tanggal Lapor</td><td class="s">:</td><td>{{ $report->created_at->format('d F Y') }}</td></tr>
  </table>
  <div class="sec"><b>Kronologi:</b>{{ $report->kronologi }}</div>
  @if($report->catatan_petugas)<div class="sec"><b>Catatan Petugas:</b>{{ $report->catatan_petugas }}</div>@endif
  <div class="ttd"><div><p>{{ $report->kecamatan ?: '....................' }}, {{ now()->format('d F Y') }}</p><p>Pelapor,</p><br><br><br><p>( {{ $report->nama_pelapor }} )</p></div></div>
</div></body></html>
EOF

# ============================================================
# 11. VIEWS — mediations, users, profile, rekap, notifications
# ============================================================
cat > resources/views/mediations/index.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Jadwal Mediasi')
@section('content')
  <h1 class="font-display text-xl font-bold text-slate-900 mb-4">Jadwal Mediasi</h1>
  <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden">
    @forelse($mediations as $m)
      <a href="{{ route('reports.show', $m->report) }}" class="flex items-center gap-3 px-4 py-3.5 border-b border-slate-50 last:border-0 hover:bg-slate-50">
        <div class="text-center shrink-0 w-12">
          <p class="font-display font-bold text-emerald-700 leading-none">{{ $m->tanggal->format('d') }}</p>
          <p class="text-[11px] text-slate-400 uppercase">{{ $m->tanggal->format('M') }}</p>
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-slate-800 truncate">{{ $m->report->judul }}</p>
          <p class="text-xs text-slate-500 truncate">{{ $m->tanggal->format('H:i') }}@if($m->tempat) · {{ $m->tempat }}@endif · {{ $m->report->nomor }}</p>
        </div>
        <span class="text-xs px-2 py-0.5 rounded-full ring-1 {{ $m->statusClasses() }} shrink-0">{{ ucfirst($m->status) }}</span>
      </a>
    @empty
      <div class="px-4 py-12 text-center text-sm text-slate-400">Belum ada jadwal mediasi.</div>
    @endforelse
  </div>
  <div class="mt-4">{{ $mediations->links() }}</div>
@endsection
EOF

cat > resources/views/users/index.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Manajemen Pengguna')
@section('content')
  <div class="flex items-center justify-between gap-3 mb-4">
    <h1 class="font-display text-xl font-bold text-slate-900">Manajemen Pengguna</h1>
    <a href="{{ route('users.create') }}" class="rounded-lg bg-emerald-700 text-white px-4 py-2 text-sm hover:bg-emerald-800">+ Tambah</a>
  </div>
  <form method="GET" class="mb-4"><input name="q" value="{{ request('q') }}" placeholder="Cari nama / email" class="w-full max-w-sm rounded-lg border border-slate-300 px-3 py-2 text-sm"></form>

  <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm divide-y divide-slate-50">
    @foreach($users as $usr)
      <div class="flex items-center gap-3 px-4 py-3">
        <span class="grid place-items-center w-9 h-9 rounded-full bg-slate-100 text-slate-600 text-xs font-semibold shrink-0">{{ $usr->initials() }}</span>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-slate-800 truncate">{{ $usr->name }} @unless($usr->is_active)<span class="text-xs text-rose-500">(nonaktif)</span>@endunless</p>
          <p class="text-xs text-slate-500 truncate">{{ $usr->email }}</p>
        </div>
        <form method="POST" action="{{ route('users.update', $usr) }}" class="hidden sm:flex items-center gap-2">@csrf @method('PATCH')
          <select name="role" class="rounded-lg border border-slate-300 px-2 py-1.5 text-xs">@foreach(['admin'=>'Admin','petugas'=>'Petugas','warga'=>'Warga'] as $k=>$v)<option value="{{ $k }}" @selected($usr->role===$k)>{{ $v }}</option>@endforeach</select>
          <select name="is_active" class="rounded-lg border border-slate-300 px-2 py-1.5 text-xs"><option value="1" @selected($usr->is_active)>Aktif</option><option value="0" @selected(!$usr->is_active)>Nonaktif</option></select>
          <button class="rounded-lg bg-slate-900 text-white px-2.5 py-1.5 text-xs">Simpan</button>
        </form>
        <form method="POST" action="{{ route('users.reset', $usr) }}">@csrf<button class="text-xs text-amber-600 hover:underline px-1">Reset sandi</button></form>
        @if($usr->id !== auth()->id())<form method="POST" action="{{ route('users.destroy', $usr) }}" onsubmit="return confirm('Hapus pengguna?')">@csrf @method('DELETE')<button class="text-xs text-rose-600 hover:underline px-1">Hapus</button></form>@endif
      </div>
    @endforeach
  </div>
  <div class="mt-4">{{ $users->links() }}</div>
@endsection
EOF

cat > resources/views/users/create.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Tambah Pengguna')
@section('content')
  <a href="{{ route('users.index') }}" class="text-sm text-slate-500 hover:underline">&larr; Kembali</a>
  <h1 class="font-display text-xl font-bold text-slate-900 mt-2 mb-4">Tambah Pengguna</h1>
  @if($errors->any())<div class="mb-4 rounded-lg bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-3 py-2"><ul class="list-disc pl-4">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>@endif
  @php $inp='w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600'; @endphp
  <form method="POST" action="{{ route('users.store') }}" class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 space-y-4 max-w-lg">@csrf
    <div><label class="block text-sm font-medium text-slate-700 mb-1">Nama</label><input name="name" value="{{ old('name') }}" required class="{{ $inp }}"></div>
    <div><label class="block text-sm font-medium text-slate-700 mb-1">Email</label><input name="email" type="email" value="{{ old('email') }}" required class="{{ $inp }}"></div>
    <div class="grid grid-cols-2 gap-3">
      <div><label class="block text-sm font-medium text-slate-700 mb-1">No. HP</label><input name="no_hp" value="{{ old('no_hp') }}" class="{{ $inp }}"></div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Role</label><select name="role" class="{{ $inp }}">@foreach(['petugas'=>'Petugas','admin'=>'Admin','warga'=>'Warga'] as $k=>$v)<option value="{{ $k }}" @selected(old('role')===$k)>{{ $v }}</option>@endforeach</select></div>
    </div>
    <div><label class="block text-sm font-medium text-slate-700 mb-1">Kata sandi</label><input name="password" type="text" required class="{{ $inp }}"></div>
    <button class="rounded-lg bg-emerald-700 text-white px-5 py-2.5 text-sm font-medium hover:bg-emerald-800">Simpan</button>
  </form>
@endsection
EOF

cat > resources/views/profile/edit.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Profil')
@section('content')
  <h1 class="font-display text-xl font-bold text-slate-900 mb-4">Profil & Keamanan</h1>
  @if($errors->any())<div class="mb-4 rounded-lg bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-3 py-2">{{ $errors->first() }}</div>@endif
  @php $inp='w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-emerald-600'; $u=auth()->user(); @endphp
  <div class="grid lg:grid-cols-2 gap-4">
    <form method="POST" action="{{ route('profile.update') }}" class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 space-y-4">@csrf @method('PATCH')
      <h2 class="font-display font-semibold text-slate-700">Data diri</h2>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Nama</label><input name="name" value="{{ old('name',$u->name) }}" required class="{{ $inp }}"></div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Email</label><input name="email" type="email" value="{{ old('email',$u->email) }}" required class="{{ $inp }}"></div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">No. HP</label><input name="no_hp" value="{{ old('no_hp',$u->no_hp) }}" required class="{{ $inp }}"></div>
      <button class="rounded-lg bg-emerald-700 text-white px-5 py-2.5 text-sm font-medium hover:bg-emerald-800">Simpan</button>
    </form>
    <form method="POST" action="{{ route('profile.password') }}" class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 space-y-4">@csrf @method('PATCH')
      <h2 class="font-display font-semibold text-slate-700">Ganti kata sandi</h2>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Sandi saat ini</label><input name="current_password" type="password" required class="{{ $inp }}"></div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Sandi baru</label><input name="password" type="password" required class="{{ $inp }}"></div>
      <div><label class="block text-sm font-medium text-slate-700 mb-1">Ulangi sandi baru</label><input name="password_confirmation" type="password" required class="{{ $inp }}"></div>
      <button class="rounded-lg bg-slate-900 text-white px-5 py-2.5 text-sm font-medium">Perbarui sandi</button>
    </form>
  </div>
@endsection
EOF

cat > resources/views/notifications/index.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Notifikasi')
@section('content')
  <h1 class="font-display text-xl font-bold text-slate-900 mb-4">Notifikasi</h1>
  <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm divide-y divide-slate-50">
    @forelse($items as $n)
      <a href="{{ route('notif.open', $n) }}" class="block px-4 py-3 hover:bg-slate-50 {{ $n->dibaca_pada ? '' : 'bg-emerald-50/40' }}">
        <p class="text-sm font-medium text-slate-800">{{ $n->judul }}</p>
        <p class="text-xs text-slate-500">{{ $n->isi }}</p>
        <p class="text-[11px] text-slate-400 mt-0.5">{{ $n->created_at->diffForHumans() }}</p>
      </a>
    @empty<div class="px-4 py-12 text-center text-sm text-slate-400">Belum ada notifikasi.</div>@endforelse
  </div>
  <div class="mt-4">{{ $items->links() }}</div>
@endsection
EOF

cat > resources/views/rekap/index.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Rekap & Statistik')
@section('content')
  <div class="flex items-center justify-between mb-4">
    <h1 class="font-display text-xl font-bold text-slate-900">Rekap & Statistik</h1>
    <button onclick="window.print()" class="rounded-lg ring-1 ring-slate-300 text-slate-700 px-3 py-2 text-sm hover:bg-slate-50">🖨 Cetak</button>
  </div>
  <div class="grid sm:grid-cols-2 gap-4">
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <h2 class="font-display font-semibold text-slate-700 mb-3">Per Status</h2>
      @foreach(['baru'=>'Baru','diproses'=>'Diproses','selesai'=>'Selesai','ditolak'=>'Ditolak'] as $k=>$v)
        <div class="flex items-center justify-between py-1.5 text-sm border-b border-slate-50 last:border-0"><span class="text-slate-600">{{ $v }}</span><span class="font-medium text-slate-900">{{ $byStatus[$k] ?? 0 }}</span></div>
      @endforeach
      <div class="flex items-center justify-between pt-2 mt-1 text-sm font-semibold"><span>Total</span><span>{{ $total }}</span></div>
    </div>
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
      <h2 class="font-display font-semibold text-slate-700 mb-3">Per Jenis Sengketa</h2>
      @forelse($byJenis as $row)<div class="flex items-center justify-between py-1.5 text-sm border-b border-slate-50 last:border-0"><span class="text-slate-600">{{ $row->jenis ?: '—' }}</span><span class="font-medium text-slate-900">{{ $row->c }}</span></div>@empty<p class="text-sm text-slate-400">Belum ada data.</p>@endforelse
    </div>
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5 sm:col-span-2">
      <h2 class="font-display font-semibold text-slate-700 mb-3">Per Kecamatan (Top 10)</h2>
      @forelse($byKec as $row)<div class="flex items-center justify-between py-1.5 text-sm border-b border-slate-50 last:border-0"><span class="text-slate-600">{{ $row->kecamatan }}</span><span class="font-medium text-slate-900">{{ $row->c }}</span></div>@empty<p class="text-sm text-slate-400">Belum ada data.</p>@endforelse
    </div>
  </div>
@endsection
EOF

# ============================================================
# 12. ROUTES (tambahan, dijaga agar tak dobel)
# ============================================================
echo "==> Routes tambahan"
if ! grep -q "mediations.index" routes/web.php; then
cat >> routes/web.php << 'EOF'

// ===== SIPETA v2 — modul tambahan =====
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
EOF
fi

# ============================================================
# 13. Migrate, akun, build
# ============================================================
echo "==> Migrasi"
php artisan migrate --force

echo "==> Akun admin & petugas"
php artisan tinker --execute="App\Models\User::updateOrCreate(['email'=>'admin@sipeta.test'],['name'=>'Administrator','password'=>bcrypt('password'),'role'=>'admin','no_hp'=>'0800000000','is_active'=>true]);"
php artisan tinker --execute="App\Models\User::updateOrCreate(['email'=>'petugas@sipeta.test'],['name'=>'Petugas Camat','password'=>bcrypt('password'),'role'=>'petugas','no_hp'=>'08123456789','is_active'=>true]);"

echo "==> Build"
php artisan optimize:clear
npm run build

echo ""
echo "============================================================"
echo "  SIPETA v2 SIAP ✓"
echo "  Jalankan:  php artisan serve --host=0.0.0.0 --port=8000"
echo "  Buka:      http://127.0.0.1:8000/login"
echo ""
echo "  Admin   : admin@sipeta.test   / password"
echo "  Petugas : petugas@sipeta.test / password"
echo "  Warga   : daftar sendiri lewat tombol 'Daftar'"
echo "============================================================"
