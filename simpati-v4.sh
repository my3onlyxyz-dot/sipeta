#!/usr/bin/env bash
# ============================================================
#  SIMPATI v4 — Upgrade menyeluruh
#  1. Login elegan bergambar
#  2. Ikon lebih rapi di semua halaman
#  3. NIK, KK, KTP, dll di form laporan
#  4. Opsi mengambang / accordion
#  5. Kode rapi, scroll mulus
#  6. Lebih banyak opsi pelaporan (referensi BPN/Ombudsman)
#  7. Dashboard berbeda: warga vs petugas vs admin
#  8. Teliti dan maksimal
#  Jalankan: bash simpati-v4.sh
# ============================================================
set -e
[ -f artisan ] || { echo "!! Jalankan di ~/myapp"; exit 1; }
echo "==> SIMPATI v4 — mulai upgrade"

mkdir -p database/migrations app/Models app/Http/Controllers \
  resources/views/layouts resources/views/auth \
  resources/views/dashboard resources/views/reports \
  resources/views/mediations resources/views/users \
  resources/views/profile resources/views/settings \
  resources/views/rekap resources/views/notifications

# ============================================================
# 1. MIGRATION — field baru di tabel reports
# ============================================================
echo "==> Migration field baru"
cat > database/migrations/2026_06_29_010001_extend_reports_v4.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::table('reports', function (Blueprint $t) {
            // Identitas pelapor
            if (!Schema::hasColumn('reports','nik_pelapor'))     $t->string('nik_pelapor',20)->nullable()->after('no_hp');
            if (!Schema::hasColumn('reports','no_kk'))           $t->string('no_kk',20)->nullable()->after('nik_pelapor');
            if (!Schema::hasColumn('reports','pekerjaan'))        $t->string('pekerjaan',100)->nullable()->after('no_kk');
            if (!Schema::hasColumn('reports','alamat_ktp'))       $t->text('alamat_ktp')->nullable()->after('pekerjaan');
            if (!Schema::hasColumn('reports','rt_rw'))            $t->string('rt_rw',20)->nullable()->after('alamat_ktp');
            if (!Schema::hasColumn('reports','desa_kelurahan'))   $t->string('desa_kelurahan',100)->nullable()->after('rt_rw');
            if (!Schema::hasColumn('reports','kecamatan_pelapor'))$t->string('kecamatan_pelapor',100)->nullable()->after('desa_kelurahan');
            // Data kepemilikan tanah
            if (!Schema::hasColumn('reports','jenis_hak'))        $t->string('jenis_hak',50)->nullable();
            if (!Schema::hasColumn('reports','no_sertifikat'))    $t->string('no_sertifikat',100)->nullable();
            if (!Schema::hasColumn('reports','cara_perolehan'))   $t->string('cara_perolehan',50)->nullable();
            if (!Schema::hasColumn('reports','luas_dokumen'))     $t->decimal('luas_dokumen',12,2)->nullable();
            if (!Schema::hasColumn('reports','batas_utara'))      $t->string('batas_utara')->nullable();
            if (!Schema::hasColumn('reports','batas_selatan'))    $t->string('batas_selatan')->nullable();
            if (!Schema::hasColumn('reports','batas_timur'))      $t->string('batas_timur')->nullable();
            if (!Schema::hasColumn('reports','batas_barat'))      $t->string('batas_barat')->nullable();
            if (!Schema::hasColumn('reports','desa_lokasi'))      $t->string('desa_lokasi',100)->nullable();
            // Data sengketa
            if (!Schema::hasColumn('reports','nik_terlapor'))     $t->string('nik_terlapor',20)->nullable();
            if (!Schema::hasColumn('reports','saksi_1'))          $t->string('saksi_1')->nullable();
            if (!Schema::hasColumn('reports','saksi_2'))          $t->string('saksi_2')->nullable();
            if (!Schema::hasColumn('reports','upaya_sebelumnya')) $t->text('upaya_sebelumnya')->nullable();
            if (!Schema::hasColumn('reports','tanggal_sengketa')) $t->date('tanggal_sengketa')->nullable();
        });
    }
    public function down(): void {}
};
EOF

# ============================================================
# 2. MODEL Report — fillable lengkap
# ============================================================
echo "==> Model Report"
cat > app/Models/Report.php << 'EOF'
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Report extends Model
{
    protected $fillable = [
        'user_id','assigned_to','nomor','judul',
        'nama_pelapor','no_hp','nik_pelapor','no_kk','pekerjaan',
        'alamat_ktp','rt_rw','desa_kelurahan','kecamatan_pelapor',
        'jenis','prioritas','tanggal_kejadian',
        'lokasi','kecamatan','desa_lokasi','luas','luas_dokumen',
        'latitude','longitude',
        'jenis_hak','no_sertifikat','cara_perolehan',
        'batas_utara','batas_selatan','batas_timur','batas_barat',
        'pihak_terlapor','nik_terlapor','saksi_1','saksi_2',
        'upaya_sebelumnya','tanggal_sengketa',
        'kronologi','status','catatan_petugas',
    ];

    protected $casts = ['tanggal_kejadian'=>'date','tanggal_sengketa'=>'date'];

    public function user(): BelongsTo { return $this->belongsTo(User::class); }
    public function assignee(): BelongsTo { return $this->belongsTo(User::class,'assigned_to'); }
    public function documents(): HasMany { return $this->hasMany(ReportDocument::class); }
    public function activities(): HasMany { return $this->hasMany(ReportActivity::class)->latest(); }
    public function mediations(): HasMany { return $this->hasMany(Mediation::class)->latest('tanggal'); }

    public function addActivity(string $tipe, string $deskripsi): void {
        $this->activities()->create(['user_id'=>auth()->id(),'tipe'=>$tipe,'deskripsi'=>$deskripsi]);
    }
    public function notifyOwner(string $judul, string $isi): void {
        if (auth()->id()===$this->user_id) return;
        Pemberitahuan::create(['user_id'=>$this->user_id,'judul'=>$judul,'isi'=>$isi,'url'=>route('reports.show',$this)]);
    }

    public function statusLabel(): string {
        return ['baru'=>'Baru','diproses'=>'Diproses','selesai'=>'Selesai','ditolak'=>'Ditolak'][$this->status] ?? ucfirst($this->status);
    }
    public function statusBadge(): string {
        return ['baru'=>'badge-sky','diproses'=>'badge-amber','selesai'=>'badge-emerald','ditolak'=>'badge-rose'][$this->status] ?? 'badge-slate';
    }
    public function prioritasLabel(): string {
        return ['rendah'=>'Rendah','sedang'=>'Sedang','tinggi'=>'Tinggi'][$this->prioritas] ?? ucfirst((string)$this->prioritas);
    }
    public function prioritasDot(): string {
        return ['rendah'=>'bg-slate-400','sedang'=>'bg-amber-500','tinggi'=>'bg-rose-500'][$this->prioritas] ?? 'bg-slate-400';
    }
    public function statusClasses(): string {
        return [
            'baru'    =>'bg-sky-50 text-sky-700 ring-sky-200',
            'diproses'=>'bg-amber-50 text-amber-700 ring-amber-200',
            'selesai' =>'bg-emerald-50 text-emerald-700 ring-emerald-200',
            'ditolak' =>'bg-rose-50 text-rose-700 ring-rose-200',
        ][$this->status] ?? 'bg-slate-100 text-slate-600 ring-slate-200';
    }
}
EOF

# ============================================================
# 3. DashboardController — tampilan berbeda per role
# ============================================================
echo "==> DashboardController"
cat > app/Http/Controllers/DashboardController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\{Mediation, Report, ReportActivity, User};
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        return match(true) {
            $user->isAdmin()   => $this->adminDashboard($user),
            $user->isStaff()   => $this->staffDashboard($user),
            default            => $this->wargaDashboard($user),
        };
    }

    private function wargaDashboard($user)
    {
        $laporan = $user->reports();
        $stats = [
            'total'    => (clone $laporan)->count(),
            'baru'     => (clone $laporan)->where('status','baru')->count(),
            'diproses' => (clone $laporan)->where('status','diproses')->count(),
            'selesai'  => (clone $laporan)->where('status','selesai')->count(),
        ];
        $terbaru = $user->reports()->with('activities')->latest()->limit(5)->get();
        $mediasi = Mediation::whereIn('report_id',$user->reports()->pluck('id'))
            ->where('status','dijadwalkan')->where('tanggal','>=',now())->orderBy('tanggal')->limit(3)->get();
        return view('dashboard.warga', compact('stats','terbaru','mediasi'));
    }

    private function staffDashboard($user)
    {
        $stats = [
            'total'    => Report::count(),
            'baru'     => Report::where('status','baru')->count(),
            'diproses' => Report::where('status','diproses')->count(),
            'selesai'  => Report::where('status','selesai')->count(),
            'ditolak'  => Report::where('status','ditolak')->count(),
            'tugas_ku' => Report::where('assigned_to',$user->id)->whereIn('status',['baru','diproses'])->count(),
        ];
        $chart = collect(range(5,0))->map(fn($i) => [
            'label' => now()->subMonths($i)->format('M'),
            'count' => Report::whereYear('created_at',now()->subMonths($i)->year)
                             ->whereMonth('created_at',now()->subMonths($i)->month)->count(),
        ]);
        $activities   = ReportActivity::with('report','user')->latest()->limit(8)->get();
        $mediasiMendatang = Mediation::with('report')->where('status','dijadwalkan')
            ->where('tanggal','>=',now()->startOfDay())->orderBy('tanggal')->limit(5)->get();
        $laporanMasuk = Report::with('user','assignee')->where('status','baru')->latest()->limit(5)->get();
        return view('dashboard.staff', compact('stats','chart','activities','mediasiMendatang','laporanMasuk'));
    }

    private function adminDashboard($user)
    {
        $stats = [
            'total'      => Report::count(),
            'baru'       => Report::where('status','baru')->count(),
            'diproses'   => Report::where('status','diproses')->count(),
            'selesai'    => Report::where('status','selesai')->count(),
            'ditolak'    => Report::where('status','ditolak')->count(),
            'pengguna'   => User::count(),
            'warga'      => User::where('role','warga')->count(),
            'petugas'    => User::where('role','petugas')->count(),
            'mediasi'    => Mediation::count(),
        ];
        $chart = collect(range(5,0))->map(fn($i) => [
            'label' => now()->subMonths($i)->format('M'),
            'count' => Report::whereYear('created_at',now()->subMonths($i)->year)
                             ->whereMonth('created_at',now()->subMonths($i)->month)->count(),
        ]);
        $activities   = ReportActivity::with('report','user')->latest()->limit(10)->get();
        $mediasiMendatang = Mediation::with('report')->where('status','dijadwalkan')
            ->where('tanggal','>=',now()->startOfDay())->orderBy('tanggal')->limit(5)->get();
        $laporanMasuk = Report::with('user','assignee')->where('status','baru')->latest()->limit(5)->get();
        $byJenis      = Report::selectRaw('jenis, count(*) c')->groupBy('jenis')->orderByDesc('c')->limit(6)->get();
        return view('dashboard.admin', compact('stats','chart','activities','mediasiMendatang','laporanMasuk','byJenis'));
    }
}
EOF

# ============================================================
# 4. ReportController — validasi field baru
# ============================================================
echo "==> ReportController"
cat > app/Http/Controllers/ReportController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\{Report, User};
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        $user  = $request->user();
        $query = $user->isStaff() ? Report::query()->with('user','assignee') : $user->reports();

        if ($s = $request->query('status'))    $query->where('status',$s);
        if ($p = $request->query('prioritas')) $query->where('prioritas',$p);
        if ($request->query('saya') && $user->isStaff()) $query->where('assigned_to',$user->id);
        if ($q = $request->query('q')) {
            $query->where(fn($w) => $w->where('judul','like',"%$q%")
                ->orWhere('nomor','like',"%$q%")->orWhere('nik_pelapor','like',"%$q%")
                ->orWhere('nama_pelapor','like',"%$q%")->orWhere('lokasi','like',"%$q%"));
        }
        $reports = $query->latest()->paginate(12)->withQueryString();
        return view('reports.index', compact('reports'));
    }

    public function create() { return view('reports.create'); }

    public function store(Request $request)
    {
        $data = $request->validate([
            // Pelapor
            'judul'            =>['required','string','max:200'],
            'nama_pelapor'     =>['required','string','max:255'],
            'no_hp'            =>['required','string','max:20'],
            'nik_pelapor'      =>['nullable','string','max:20'],
            'no_kk'            =>['nullable','string','max:20'],
            'pekerjaan'        =>['nullable','string','max:100'],
            'alamat_ktp'       =>['nullable','string'],
            'rt_rw'            =>['nullable','string','max:20'],
            'desa_kelurahan'   =>['nullable','string','max:100'],
            'kecamatan_pelapor'=>['nullable','string','max:100'],
            // Sengketa
            'jenis'            =>['nullable','string','max:50'],
            'prioritas'        =>['required','in:rendah,sedang,tinggi'],
            'tanggal_sengketa' =>['nullable','date'],
            'tanggal_kejadian' =>['nullable','date'],
            'pihak_terlapor'   =>['nullable','string','max:255'],
            'nik_terlapor'     =>['nullable','string','max:20'],
            'saksi_1'          =>['nullable','string','max:255'],
            'saksi_2'          =>['nullable','string','max:255'],
            'upaya_sebelumnya' =>['nullable','string'],
            // Lokasi tanah
            'lokasi'           =>['required','string'],
            'kecamatan'        =>['nullable','string','max:100'],
            'desa_lokasi'      =>['nullable','string','max:100'],
            'luas'             =>['nullable','numeric','min:0'],
            'latitude'         =>['nullable','numeric','between:-90,90'],
            'longitude'        =>['nullable','numeric','between:-180,180'],
            // Kepemilikan
            'jenis_hak'        =>['nullable','string','max:50'],
            'no_sertifikat'    =>['nullable','string','max:100'],
            'cara_perolehan'   =>['nullable','string','max:50'],
            'luas_dokumen'     =>['nullable','numeric','min:0'],
            'batas_utara'      =>['nullable','string','max:255'],
            'batas_selatan'    =>['nullable','string','max:255'],
            'batas_timur'      =>['nullable','string','max:255'],
            'batas_barat'      =>['nullable','string','max:255'],
            // Kronologi
            'kronologi'        =>['required','string'],
            // Dokumen
            'dokumen'          =>['nullable','array','max:8'],
            'dokumen.*'        =>['file','mimes:jpg,jpeg,png,pdf','max:5120'],
        ]);

        $report = $request->user()->reports()->create($data + ['status'=>'baru']);
        $report->update(['nomor'=>'TS-'.str_pad($report->id,5,'0',STR_PAD_LEFT)]);

        foreach ((array)$request->file('dokumen') as $file) {
            $path = $file->store('dokumen','public');
            $report->documents()->create([
                'path'=>$path,'nama_asli'=>$file->getClientOriginalName(),
                'mime'=>$file->getMimeType(),'ukuran'=>$file->getSize(),
            ]);
        }
        $report->addActivity('dibuat','Laporan dibuat oleh '.$request->user()->name);
        return redirect()->route('reports.show',$report)->with('success','Laporan berhasil dikirim. Nomor: '.$report->nomor);
    }

    public function show(Request $request, Report $report)
    {
        $this->authorize($request,$report);
        $report->load('documents','user','assignee','activities.user','mediations.penjadwal');
        $petugasList = $request->user()->isStaff()
            ? User::whereIn('role',['petugas','admin'])->where('is_active',true)->orderBy('name')->get()
            : collect();
        return view('reports.show', compact('report','petugasList'));
    }

    public function updateStatus(Request $request, Report $report)
    {
        abort_unless($request->user()->isStaff(),403);
        $data = $request->validate(['status'=>['required','in:baru,diproses,selesai,ditolak'],'catatan_petugas'=>['nullable','string']]);
        $old  = $report->statusLabel();
        $report->update($data);
        $report->addActivity('status',"Status diubah: {$old} → {$report->statusLabel()}");
        $report->notifyOwner('Status laporan diperbarui',"{$report->nomor} kini berstatus {$report->statusLabel()}.");
        return back()->with('success','Status laporan diperbarui.');
    }

    public function assign(Request $request, Report $report)
    {
        abort_unless($request->user()->isStaff(),403);
        $data = $request->validate(['assigned_to'=>['nullable','exists:users,id']]);
        $report->update($data);
        $nama = $report->assignee?->name ?? '—';
        $report->addActivity('disposisi',"Laporan didisposisikan ke: {$nama}");
        if ($report->assigned_to) {
            \App\Models\Pemberitahuan::create([
                'user_id'=>$report->assigned_to,'judul'=>'Disposisi laporan baru',
                'isi'=>"Anda ditugaskan menangani {$report->nomor}.","url"=>route('reports.show',$report),
            ]);
        }
        return back()->with('success','Disposisi diperbarui.');
    }

    public function print(Request $request, Report $report)
    {
        $this->authorize($request,$report);
        $report->load('documents','user','assignee');
        return view('reports.print', compact('report'));
    }

    public function destroy(Request $request, Report $report)
    {
        $user = $request->user();
        abort_unless($user->isStaff() || $report->user_id===$user->id,403);
        $report->delete();
        return redirect()->route('reports.index')->with('success','Laporan dihapus.');
    }

    private function authorize(Request $request, Report $report): void
    {
        $user = $request->user();
        abort_unless($user->isStaff() || $report->user_id===$user->id,403);
    }
}
EOF

# ============================================================
# 5. AUTH VIEW — Login elegan (gambar + pattern)
# ============================================================
echo "==> Login view elegan"
cat > resources/views/auth/login.blade.php << 'EOF'
@extends('layouts.guest')
@section('title','Masuk')
@section('content')
  <div class="mb-6">
    <h1 class="font-display text-2xl font-bold text-slate-900">Selamat datang</h1>
    <p class="text-sm text-slate-500 mt-1">Masuk untuk mengakses sistem SIMPATI.</p>
  </div>
  @if($errors->any())
    <div class="mb-4 rounded-xl bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm px-4 py-3 flex items-center gap-2">
      <svg class="w-4 h-4 shrink-0" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.28 7.22a.75.75 0 00-1.06 1.06L8.94 10l-1.72 1.72a.75.75 0 101.06 1.06L10 11.06l1.72 1.72a.75.75 0 101.06-1.06L11.06 10l1.72-1.72a.75.75 0 00-1.06-1.06L10 8.94 8.28 7.22z" clip-rule="evenodd"/></svg>
      {{ $errors->first() }}
    </div>
  @endif
  <form method="POST" action="{{ route('login') }}" class="space-y-4">
    @csrf
    <div>
      <label class="block text-sm font-medium text-slate-700 mb-1.5">Alamat Email</label>
      <div class="relative">
        <span class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">
          <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path d="M3 4a2 2 0 00-2 2v1.161l8.441 4.221a1.25 1.25 0 001.118 0L19 7.162V6a2 2 0 00-2-2H3z"/><path d="M19 8.839l-7.77 3.885a2.75 2.75 0 01-2.46 0L1 8.839V14a2 2 0 002 2h14a2 2 0 002-2V8.839z"/></svg>
        </span>
        <input name="email" type="email" value="{{ old('email') }}" required autofocus
          class="w-full pl-10 pr-4 py-2.5 rounded-xl border border-slate-300 text-sm outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition">
      </div>
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700 mb-1.5">Kata Sandi</label>
      <div class="relative" x-data="{show:false}">
        <span class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">
          <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 1a4.5 4.5 0 00-4.5 4.5V9H5a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6a2 2 0 00-2-2h-.5V5.5A4.5 4.5 0 0010 1zm3 8V5.5a3 3 0 10-6 0V9h6z" clip-rule="evenodd"/></svg>
        </span>
        <input :type="show?'text':'password'" name="password" required
          class="w-full pl-10 pr-10 py-2.5 rounded-xl border border-slate-300 text-sm outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition">
        <button type="button" @click="show=!show" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
          <svg x-show="!show" class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path d="M10 12.5a2.5 2.5 0 100-5 2.5 2.5 0 000 5z"/><path fill-rule="evenodd" d="M.664 10.59a1.651 1.651 0 010-1.186A10.004 10.004 0 0110 3c4.257 0 7.893 2.66 9.336 6.41.147.381.146.804 0 1.186A10.004 10.004 0 0110 17c-4.257 0-7.893-2.66-9.336-6.41zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd"/></svg>
          <svg x-show="show" x-cloak class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M3.28 2.22a.75.75 0 00-1.06 1.06l14.5 14.5a.75.75 0 101.06-1.06l-1.745-1.745a10.029 10.029 0 003.3-4.38 1.651 1.651 0 000-1.185A10.004 10.004 0 009.999 3a9.956 9.956 0 00-4.744 1.194L3.28 2.22zM7.752 6.69l1.092 1.092a2.5 2.5 0 013.374 3.373l1.091 1.092a4 4 0 00-5.557-5.557z" clip-rule="evenodd"/><path d="M10.748 13.93l2.523 2.523a10.003 10.003 0 01-8.33-2.952l-.36-.359c-.17-.17-.34-.34-.5-.513A10.015 10.015 0 010 10c0-.36.02-.716.058-1.065l2.414 2.414a4 4 0 005.088 5.088 4 4 0 003.188-2.507z"/></svg>
        </button>
      </div>
    </div>
    <label class="flex items-center gap-2 text-sm text-slate-600 cursor-pointer">
      <input type="checkbox" name="remember" class="w-4 h-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500">
      Ingat saya di perangkat ini
    </label>
    <button class="w-full rounded-xl bg-emerald-700 text-white py-2.5 text-sm font-semibold hover:bg-emerald-800 transition shadow-sm shadow-emerald-200">
      Masuk ke SIMPATI
    </button>
  </form>
  <div class="mt-6 pt-5 border-t border-slate-100 text-center">
    <p class="text-sm text-slate-500">Belum punya akun? <a href="{{ route('register') }}" class="font-semibold text-emerald-700 hover:underline">Daftar sebagai warga</a></p>
  </div>
@endsection
EOF

# ============================================================
# 6. LAYOUT GUEST — Panel kiri gambar elegan
# ============================================================
echo "==> Guest layout"
cat > resources/views/layouts/guest.blade.php << 'EOF'
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>@yield('title','Masuk') · SIMPATI</title>
  @vite(['resources/css/app.css','resources/js/app.js'])
  <style>
    body{background:#f1f5f9;color:#0f172a}
    *:focus-visible{outline-color:#047857}
    [x-cloak]{display:none!important}
    .hero-pattern{background-color:#064e3b;background-image:url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23065f46' fill-opacity='0.6'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")}
  </style>
</head>
<body class="min-h-screen grid lg:grid-cols-[1.1fr_1fr]" x-data>

  {{-- PANEL KIRI --}}
  <div class="hidden lg:flex flex-col hero-pattern relative overflow-hidden">
    {{-- overlay gradient --}}
    <div class="absolute inset-0" style="background:linear-gradient(135deg,rgba(6,78,59,.95) 0%,rgba(4,120,87,.85) 50%,rgba(5,46,22,.98) 100%)"></div>

    {{-- ilustrasi peta/tanah --}}
    <div class="absolute inset-0 flex items-center justify-center opacity-10">
      <svg viewBox="0 0 400 400" class="w-3/4" fill="none">
        <rect x="20" y="80" width="120" height="90" rx="4" stroke="white" stroke-width="2"/>
        <rect x="160" y="60" width="100" height="110" rx="4" stroke="white" stroke-width="2"/>
        <rect x="280" y="90" width="100" height="70" rx="4" stroke="white" stroke-width="2"/>
        <rect x="40" y="200" width="90" height="80" rx="4" stroke="white" stroke-width="2"/>
        <rect x="150" y="190" width="130" height="100" rx="4" stroke="white" stroke-width="2"/>
        <rect x="300" y="180" width="80" height="110" rx="4" stroke="white" stroke-width="2"/>
        <line x1="20" y1="80" x2="380" y2="80" stroke="white" stroke-width="1" stroke-dasharray="4"/>
        <line x1="20" y1="170" x2="380" y2="170" stroke="white" stroke-width="1" stroke-dasharray="4"/>
        <line x1="20" y1="290" x2="380" y2="290" stroke="white" stroke-width="1" stroke-dasharray="4"/>
        <line x1="140" y1="40" x2="140" y2="380" stroke="white" stroke-width="1" stroke-dasharray="4"/>
        <line x1="260" y1="40" x2="260" y2="380" stroke="white" stroke-width="1" stroke-dasharray="4"/>
        <circle cx="200" cy="210" r="8" stroke="white" stroke-width="2" fill="rgba(255,255,255,0.2)"/>
        <path d="M200 202 L200 218 M192 210 L208 210" stroke="white" stroke-width="1.5"/>
      </svg>
    </div>

    <div class="relative z-10 flex flex-col h-full p-12">
      {{-- logo --}}
      <div class="flex items-center gap-3">
        <span class="grid place-items-center w-12 h-12 rounded-2xl bg-white/15 backdrop-blur-sm border border-white/20">
          <svg viewBox="0 0 24 24" fill="none" class="w-6 h-6 text-white"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" fill="currentColor"/></svg>
        </span>
        <div>
          <p class="font-display font-extrabold text-white text-xl tracking-tight">SIMPATI</p>
          <p class="text-emerald-200/70 text-xs">Kantor Camat Brang Ene</p>
        </div>
      </div>

      {{-- konten tengah --}}
      <div class="flex-1 flex flex-col justify-center">
        <p class="text-emerald-300/70 text-xs uppercase tracking-widest font-semibold mb-4">Seksi Ketentraman & Ketertiban</p>
        <h2 class="font-display text-3xl font-bold text-white leading-snug">
          Sistem Informasi<br>Mediasi & Penanganan<br><span class="text-emerald-300">Sengketa Tanah</span>
        </h2>
        <p class="text-emerald-100/60 text-sm mt-4 max-w-xs leading-relaxed">Platform digital terpadu untuk pelaporan, penanganan, mediasi, dan rekap sengketa tanah masyarakat.</p>

        {{-- fitur kecil --}}
        <div class="mt-8 space-y-3">
          @foreach([
            ['Pelaporan online dengan identitas lengkap','M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'],
            ['Tracking status real-time','M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9'],
            ['Jadwal mediasi terstruktur','M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z'],
          ] as [$teks,$path])
            <div class="flex items-center gap-3 text-emerald-100/80 text-sm">
              <span class="grid place-items-center w-7 h-7 rounded-lg bg-white/10 shrink-0">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none"><path d="{{ $path }}" stroke="currentColor" stroke-width="1.8"/></svg>
              </span>
              {{ $teks }}
            </div>
          @endforeach
        </div>
      </div>

      {{-- footer panel kiri --}}
      <div class="border-t border-white/10 pt-5 space-y-1 text-xs text-emerald-100/50">
        <p>📞 +62 85173464488</p>
        <p>✉ kantorbrangene@gmail.com</p>
        <p>📍 Kantor Brang Ene, Kab. Sumbawa Barat</p>
        <p class="mt-2">© {{ date('Y') }} Kantor Camat Brang Ene</p>
      </div>
    </div>
  </div>

  {{-- PANEL KANAN --}}
  <div class="flex items-center justify-center px-4 py-10 bg-white min-h-screen">
    <div class="w-full max-w-sm">
      <div class="lg:hidden flex flex-col items-center gap-2 mb-8 text-center">
        <span class="grid place-items-center w-12 h-12 rounded-2xl bg-emerald-700 text-white">
          <svg viewBox="0 0 24 24" fill="none" class="w-6 h-6"><path d="M12 21s-7-5.2-7-11a7 7 0 1114 0c0 5.8-7 11-7 11z" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2.5" fill="currentColor"/></svg>
        </span>
        <div>
          <p class="font-display font-bold">SIMPATI</p>
          <p class="text-xs text-slate-500">Sistem Informasi Mediasi Sengketa Tanah</p>
        </div>
      </div>
      @yield('content')
    </div>
  </div>
</body>
</html>
EOF

# ============================================================
# 7. DASHBOARD — Warga
# ============================================================
echo "==> Dashboard warga"
cat > resources/views/dashboard/warga.blade.php << 'EOF'
@extends('layouts.app')
@section('title','Dashboard Warga')
@section('content')
  @php $u = auth()->user(); @endphp

  {{-- HERO --}}
  <div class="rounded-2xl p-6 mb-5 text-white overflow-hidden relative"
       style="background:linear-gradient(135deg,#047857 0%,#065f46 100%)"
       x-data="jamSimpati()" x-init="start()">
    <div class="absolute top-0 right-0 w-48 h-48 rounded-full opacity-10" style="background:white;transform:translate(30%,-30%)"></div>
    <div class="flex flex-wrap items-start justify-between gap-4">
      <div>
        <p class="text-emerald-200/80 text-sm" x-text="sapaan"></p>
        <h1 class="font-display text-xl font-bold mt-0.5">{{ $u->name }}</h1>
        <p class="text-emerald-100/60 text-xs mt-0.5">Warga · SIMPATI</p>
        <a href="{{ route('reports.create') }}" class="mt-4 inline-flex items-center gap-2 bg-white/15 hover:bg-white/25 text-white text-sm font-medium px-4 py-2 rounded-xl transition">
          <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path d="M10.75 4.75a.75.75 0 00-1.5 0v4.5h-4.5a.75.75 0 000 1.5h4.5v4.5a.75.75 0 001.5 0v-4.5h4.5a.75.75 0 000-1.5h-4.5v-4.5z"/></svg>
          Buat Laporan Baru
        </a>
      </div>
      <div class="text-right">
        <p class="font-display font-bold tabular-nums text-4xl sm:text-5xl leading-none"><span x-text="jam"></span><span class="text-emerald-300 text-3xl" x-text="detik"></span></p>
        <p class="text-emerald-100/70 text-xs mt-2" x-text="tanggal"></p>
      </div>
    </div>
  </div>

  {{-- STAT CARDS --}}
  <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-5">
    @foreach([
      ['Total','total','#0ea5e9','M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 002.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 00-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 00.75-.75 2.25 2.25 0 00-.1-.664m-5.8 0A2.251 2.251 0 0113.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25zM6.75 12h.008v.008H6.75V12zm0 3h.008v.008H6.75V15zm0 3h.008v.008H6.75V18z'],
      ['Baru','baru','#38bdf8','M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z'],
      ['Diproses','diproses','#f59e0b','M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z'],
      ['Selesai','selesai','#10b981','M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z'],
    ] as [$l,$k,$c,$p])
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-4">
        <span class="inline-flex w-9 h-9 rounded-xl items-center justify-center mb-3" style="background:{{ $c }}20">
          <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" style="color:{{ $c }}"><path d="{{ $p }}" stroke="currentColor" stroke-width="1.8"/></svg>
        </span>
        <p class="font-display text-3xl font-bold text-slate-900">{{ $stats[$k] }}</p>
        <p class="text-xs text-slate-500 mt-0.5">{{ $l }}</p>
      </div>
    @endforeach
  </div>

  <div class="grid lg:grid-cols-3 gap-4">
    {{-- Laporan terbaru --}}
    <div class="lg:col-span-2 bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm">
      <div class="flex items-center justify-between px-5 py-3.5 border-b border-slate-100">
        <h2 class="font-display font-semibold text-slate-900">Laporan Saya</h2>
        <a href="{{ route('reports.index') }}" class="text-xs text-emerald-700 font-medium hover:underline">Lihat semua</a>
      </div>
      @forelse($terbaru as $r)
        <a href="{{ route('reports.show',$r) }}" class="flex items-center gap-3 px-5 py-3.5 border-b border-slate-50 last:border-0 hover:bg-slate-50 transition">
          <span class="w-2 h-2 rounded-full {{ $r->prioritasDot() }} shrink-0"></span>
          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-2 flex-wrap">
              <span class="text-xs font-mono text-slate-400">{{ $r->nomor }}</span>
              <span class="text-xs px-2 py-0.5 rounded-full ring-1 {{ $r->statusClasses() }}">{{ $r->statusLabel() }}</span>
            </div>
            <p class="text-sm font-medium text-slate-800 truncate mt-0.5">{{ $r->judul }}</p>
          </div>
          <span class="text-xs text-slate-400 shrink-0">{{ $r->created_at->format('d/m/y') }}</span>
        </a>
      @empty
        <div class="px-5 py-12 text-center">
          <svg class="w-10 h-10 text-slate-200 mx-auto mb-3" viewBox="0 0 24 24" fill="none"><path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke="currentColor" stroke-width="1.5"/></svg>
          <p class="text-sm text-slate-400">Belum ada laporan.</p>
          <a href="{{ route('reports.create') }}" class="mt-2 inline-block text-sm text-emerald-700 font-medium hover:underline">Buat laporan pertama</a>
        </div>
      @endforelse
    </div>

    {{-- Mediasi + panduan --}}
    <div class="space-y-4">
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-900 mb-3">Jadwal Mediasi Saya</h2>
        @forelse($mediasi as $m)
          <div class="flex items-start gap-3 py-2 border-b border-slate-50 last:border-0">
            <div class="text-center shrink-0 w-10 bg-emerald-50 rounded-lg py-1">
              <p class="font-bold text-emerald-700 leading-none text-lg">{{ $m->tanggal->format('d') }}</p>
              <p class="text-[10px] text-slate-400 uppercase">{{ $m->tanggal->format('M') }}</p>
            </div>
            <div class="min-w-0">
              <p class="text-sm font-medium text-slate-700 truncate">{{ $m->report->judul }}</p>
              <p class="text-xs text-slate-400">{{ $m->tanggal->format('H:i') }}@if($m->tempat) · {{ $m->tempat }}@endif</p>
            </div>
          </div>
        @empty
          <p class="text-sm text-slate-400 text-center py-4">Tidak ada jadwal mediasi.</p>
        @endforelse
      </div>

      <div class="bg-emerald-50 rounded-2xl ring-1 ring-emerald-100 p-5">
        <h2 class="font-display font-semibold text-emerald-800 mb-3 flex items-center gap-2">
          <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a.75.75 0 000 1.5h.253a.25.25 0 01.244.304l-.459 2.066A1.75 1.75 0 0010.747 15H11a.75.75 0 000-1.5h-.253a.25.25 0 01-.244-.304l.459-2.066A1.75 1.75 0 009.253 9H9z" clip-rule="evenodd"/></svg>
          Panduan Pelaporan
        </h2>
        <ol class="space-y-2 text-xs text-emerald-700">
          @foreach(['Siapkan KTP, KK, dan dokumen tanah','Isi formulir laporan dengan lengkap','Upload bukti foto atau dokumen','Pantau status laporan secara berkala','Hadiri mediasi sesuai jadwal yang ditetapkan'] as $i=>$p)
            <li class="flex items-start gap-2"><span class="font-bold shrink-0">{{ $i+1 }}.</span>{{ $p }}</li>
          @endforeach
        </ol>
      </div>
    </div>
  </div>

  <script>
    function jamSimpati(){
      const hr=['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
      const bl=['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];
      return {
        jam:'00:00',detik:':00',tanggal:'',sapaan:'',
        tick(){
          const d=new Date(),p=n=>String(n).padStart(2,'0');
          this.jam=p(d.getHours())+':'+p(d.getMinutes());
          this.detik=':'+p(d.getSeconds());
          this.tanggal=hr[d.getDay()]+', '+d.getDate()+' '+bl[d.getMonth()]+' '+d.getFullYear();
          const h=d.getHours();
          this.sapaan=h<5?'Selamat dini hari':h<11?'Selamat pagi':h<15?'Selamat siang':h<19?'Selamat sore':'Selamat malam';
        },
        start(){this.tick();setInterval(()=>this.tick(),1000);}
      }
    }
  </script>
@endsection
EOF

# ============================================================
# 8. DASHBOARD — Staff (Petugas)
# ============================================================
echo "==> Dashboard staff"
cat > resources/views/dashboard/staff.blade.php << 'EOF'
@extends('layouts.app')
@section('title','Dashboard Petugas')
@section('content')
  @php $u=auth()->user(); $max=max($chart->max('count'),1); @endphp

  <div class="rounded-2xl p-6 mb-5 text-white overflow-hidden relative"
       style="background:linear-gradient(135deg,#1e40af 0%,#1e3a8a 100%)"
       x-data="jamSimpati()" x-init="start()">
    <div class="absolute top-0 right-0 w-48 h-48 rounded-full opacity-10" style="background:white;transform:translate(30%,-30%)"></div>
    <div class="flex flex-wrap items-start justify-between gap-4">
      <div>
        <p class="text-blue-200/80 text-sm" x-text="sapaan"></p>
        <h1 class="font-display text-xl font-bold mt-0.5">{{ $u->name }}</h1>
        <p class="text-blue-100/60 text-xs mt-0.5">Petugas · Seksi Ketentraman & Ketertiban</p>
        <div class="flex gap-2 mt-3">
          <a href="{{ route('reports.index') }}" class="inline-flex items-center gap-1.5 bg-white/15 hover:bg-white/25 text-white text-xs font-medium px-3 py-1.5 rounded-lg transition">
            <svg class="w-3.5 h-3.5" viewBox="0 0 20 20" fill="currentColor"><path d="M10.75 4.75a.75.75 0 00-1.5 0v4.5h-4.5a.75.75 0 000 1.5h4.5v4.5a.75.75 0 001.5 0v-4.5h4.5a.75.75 0 000-1.5h-4.5v-4.5z"/></svg>
            Laporan Masuk
            @if($stats['baru']>0)<span class="bg-rose-500 text-white text-[10px] rounded-full w-4 h-4 grid place-items-center">{{ $stats['baru'] }}</span>@endif
          </a>
          <a href="{{ route('mediations.index') }}" class="inline-flex items-center gap-1.5 bg-white/15 hover:bg-white/25 text-white text-xs font-medium px-3 py-1.5 rounded-lg transition">Mediasi</a>
        </div>
      </div>
      <div class="text-right">
        <p class="font-display font-bold tabular-nums text-4xl sm:text-5xl leading-none"><span x-text="jam"></span><span class="text-blue-300 text-3xl" x-text="detik"></span></p>
        <p class="text-blue-100/70 text-xs mt-2" x-text="tanggal"></p>
      </div>
    </div>
  </div>

  <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3 mb-5">
    @foreach([
      ['Total',$stats['total'],'#64748b'],['Baru',$stats['baru'],'#0ea5e9'],
      ['Diproses',$stats['diproses'],'#f59e0b'],['Selesai',$stats['selesai'],'#10b981'],
      ['Ditolak',$stats['ditolak'],'#ef4444'],['Tugas Saya',$stats['tugas_ku'],'#8b5cf6'],
    ] as [$l,$v,$c])
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-3.5 text-center">
        <p class="font-display text-2xl font-bold text-slate-900">{{ $v }}</p>
        <p class="text-xs mt-0.5" style="color:{{ $c }}">{{ $l }}</p>
      </div>
    @endforeach
  </div>

  <div class="grid lg:grid-cols-3 gap-4">
    <div class="lg:col-span-2 space-y-4">
      {{-- Chart --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-900 mb-4">Tren laporan 6 bulan</h2>
        <div class="flex items-end gap-3 h-36">
          @foreach($chart as $c)
            <div class="flex-1 bg-gradient-to-t from-blue-600 to-blue-400 rounded-t-lg relative" style="height:{{ max(3,round($c['count']/$max*100)) }}%">
              <span class="absolute -top-5 inset-x-0 text-center text-[11px] font-medium text-slate-500">{{ $c['count'] }}</span>
            </div>
          @endforeach
        </div>
        <div class="flex gap-3 mt-2">@foreach($chart as $c)<div class="flex-1 text-center text-xs text-slate-400">{{ $c['label'] }}</div>@endforeach</div>
      </div>

      {{-- Laporan masuk baru --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm">
        <div class="flex items-center justify-between px-5 py-3.5 border-b border-slate-100">
          <h2 class="font-display font-semibold text-slate-900">Laporan Masuk (Baru)</h2>
          <a href="{{ route('reports.index','?status=baru') }}" class="text-xs text-blue-600 font-medium hover:underline">Lihat semua</a>
        </div>
        @forelse($laporanMasuk as $r)
          <a href="{{ route('reports.show',$r) }}" class="flex items-center gap-3 px-5 py-3 border-b border-slate-50 last:border-0 hover:bg-slate-50 transition">
            <span class="w-2 h-2 rounded-full {{ $r->prioritasDot() }} shrink-0"></span>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-slate-800 truncate">{{ $r->judul }}</p>
              <p class="text-xs text-slate-400 truncate">{{ $r->user->name }} · {{ $r->lokasi }}</p>
            </div>
            <span class="text-xs text-slate-400 shrink-0">{{ $r->created_at->diffForHumans() }}</span>
          </a>
        @empty
          <p class="px-5 py-8 text-center text-sm text-slate-400">Tidak ada laporan baru.</p>
        @endforelse
      </div>
    </div>

    <div class="space-y-4">
      {{-- Mediasi mendatang --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-900 mb-3">Mediasi Mendatang</h2>
        @forelse($mediasiMendatang as $m)
          <a href="{{ route('reports.show',$m->report) }}" class="flex gap-3 py-2 border-b border-slate-50 last:border-0">
            <div class="text-center shrink-0 w-10 bg-blue-50 rounded-lg py-1">
              <p class="font-bold text-blue-700 leading-none">{{ $m->tanggal->format('d') }}</p>
              <p class="text-[10px] text-slate-400 uppercase">{{ $m->tanggal->format('M') }}</p>
            </div>
            <div class="min-w-0"><p class="text-sm text-slate-700 truncate">{{ $m->report->judul }}</p><p class="text-xs text-slate-400">{{ $m->tanggal->format('H:i') }}</p></div>
          </a>
        @empty<p class="text-sm text-slate-400 py-4 text-center">Tidak ada jadwal.</p>@endforelse
      </div>

      {{-- Aktivitas --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-900 mb-3">Aktivitas Terbaru</h2>
        <div class="space-y-3">
          @foreach($activities->take(5) as $a)
            <div class="flex gap-2.5">
              <span class="mt-1.5 w-2 h-2 rounded-full {{ $a->dotColor() }} shrink-0"></span>
              <div><p class="text-xs text-slate-700 leading-relaxed">{{ $a->deskripsi }}</p><p class="text-[11px] text-slate-400">{{ $a->created_at->diffForHumans() }}</p></div>
            </div>
          @endforeach
        </div>
      </div>
    </div>
  </div>
  <script>function jamSimpati(){const hr=['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'],bl=['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];return{jam:'00:00',detik:':00',tanggal:'',sapaan:'',tick(){const d=new Date(),p=n=>String(n).padStart(2,'0');this.jam=p(d.getHours())+':'+p(d.getMinutes());this.detik=':'+p(d.getSeconds());this.tanggal=hr[d.getDay()]+', '+d.getDate()+' '+bl[d.getMonth()]+' '+d.getFullYear();const h=d.getHours();this.sapaan=h<5?'Selamat dini hari':h<11?'Selamat pagi':h<15?'Selamat siang':h<19?'Selamat sore':'Selamat malam';},start(){this.tick();setInterval(()=>this.tick(),1000);}}}
  </script>
@endsection
EOF

# ============================================================
# 9. DASHBOARD — Admin
# ============================================================
echo "==> Dashboard admin"
cat > resources/views/dashboard/admin.blade.php << 'EOF'
@extends('layouts.app')
@section('title','Dashboard Administrator')
@section('content')
  @php $u=auth()->user(); $max=max($chart->max('count'),1); @endphp

  <div class="rounded-2xl p-6 mb-5 text-white overflow-hidden relative"
       style="background:linear-gradient(135deg,#7c3aed 0%,#5b21b6 100%)"
       x-data="jamSimpati()" x-init="start()">
    <div class="absolute top-0 right-0 w-64 h-64 rounded-full opacity-10" style="background:white;transform:translate(40%,-40%)"></div>
    <div class="flex flex-wrap items-start justify-between gap-4">
      <div>
        <p class="text-violet-200/80 text-sm" x-text="sapaan"></p>
        <h1 class="font-display text-xl font-bold">{{ $u->name }}</h1>
        <p class="text-violet-100/60 text-xs mt-0.5">Administrator · SIMPATI</p>
        <div class="flex flex-wrap gap-2 mt-3">
          <a href="{{ route('users.index') }}" class="inline-flex items-center gap-1.5 bg-white/15 hover:bg-white/25 text-white text-xs font-medium px-3 py-1.5 rounded-lg transition">Kelola Pengguna</a>
          <a href="{{ route('rekap.index') }}" class="inline-flex items-center gap-1.5 bg-white/15 hover:bg-white/25 text-white text-xs font-medium px-3 py-1.5 rounded-lg transition">Rekap & Statistik</a>
          <a href="{{ route('settings.edit') }}" class="inline-flex items-center gap-1.5 bg-white/15 hover:bg-white/25 text-white text-xs font-medium px-3 py-1.5 rounded-lg transition">Pengaturan</a>
        </div>
      </div>
      <div class="text-right">
        <p class="font-display font-bold tabular-nums text-4xl sm:text-5xl leading-none"><span x-text="jam"></span><span class="text-violet-300 text-3xl" x-text="detik"></span></p>
        <p class="text-violet-100/70 text-xs mt-2" x-text="tanggal"></p>
      </div>
    </div>
  </div>

  {{-- Stat cards admin --}}
  <div class="grid grid-cols-3 sm:grid-cols-3 lg:grid-cols-9 gap-3 mb-5">
    @foreach([
      ['Laporan',$stats['total'],'#64748b'],['Baru',$stats['baru'],'#0ea5e9'],['Proses',$stats['diproses'],'#f59e0b'],
      ['Selesai',$stats['selesai'],'#10b981'],['Ditolak',$stats['ditolak'],'#ef4444'],['Mediasi',$stats['mediasi'],'#6366f1'],
      ['Pengguna',$stats['pengguna'],'#8b5cf6'],['Warga',$stats['warga'],'#14b8a6'],['Petugas',$stats['petugas'],'#f97316'],
    ] as [$l,$v,$c])
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-3 text-center col-span-1">
        <p class="font-display text-xl font-bold text-slate-900">{{ $v }}</p>
        <p class="text-[11px] mt-0.5 leading-tight" style="color:{{ $c }}">{{ $l }}</p>
      </div>
    @endforeach
  </div>

  <div class="grid lg:grid-cols-3 gap-4">
    <div class="lg:col-span-2 space-y-4">
      {{-- Chart --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <div class="flex items-center justify-between mb-4">
          <h2 class="font-display font-semibold text-slate-900">Tren laporan 6 bulan</h2>
          <a href="{{ route('rekap.index') }}" class="text-xs text-violet-600 hover:underline font-medium">Rekap lengkap</a>
        </div>
        <div class="flex items-end gap-3 h-36">
          @foreach($chart as $c)
            <div class="flex-1 bg-gradient-to-t from-violet-600 to-violet-400 rounded-t-lg relative" style="height:{{ max(3,round($c['count']/$max*100)) }}%">
              <span class="absolute -top-5 inset-x-0 text-center text-[11px] font-medium text-slate-500">{{ $c['count'] }}</span>
            </div>
          @endforeach
        </div>
        <div class="flex gap-3 mt-2">@foreach($chart as $c)<div class="flex-1 text-center text-xs text-slate-400">{{ $c['label'] }}</div>@endforeach</div>
      </div>

      {{-- Per jenis sengketa --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-900 mb-3">Per Jenis Sengketa</h2>
        @foreach($byJenis as $row)
          @php $pct = $stats['total']>0 ? round($row->c/$stats['total']*100) : 0; @endphp
          <div class="flex items-center gap-3 py-1.5">
            <span class="text-xs text-slate-600 w-28 shrink-0 truncate">{{ $row->jenis ?: 'Belum ditentukan' }}</span>
            <div class="flex-1 h-2 bg-slate-100 rounded-full overflow-hidden">
              <div class="h-full bg-violet-500 rounded-full" style="width:{{ $pct }}%"></div>
            </div>
            <span class="text-xs font-medium text-slate-700 w-6 text-right">{{ $row->c }}</span>
          </div>
        @endforeach
      </div>
    </div>

    <div class="space-y-4">
      {{-- Laporan masuk --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm">
        <div class="px-5 py-3.5 border-b border-slate-100 flex items-center justify-between">
          <h2 class="font-display font-semibold text-slate-900">Laporan Baru</h2>
          <span class="text-xs bg-rose-100 text-rose-600 font-medium px-2 py-0.5 rounded-full">{{ $stats['baru'] }}</span>
        </div>
        @forelse($laporanMasuk as $r)
          <a href="{{ route('reports.show',$r) }}" class="flex items-center gap-3 px-5 py-3 border-b border-slate-50 last:border-0 hover:bg-slate-50 transition">
            <span class="w-1.5 h-1.5 rounded-full {{ $r->prioritasDot() }} shrink-0"></span>
            <div class="flex-1 min-w-0">
              <p class="text-sm text-slate-800 truncate font-medium">{{ $r->judul }}</p>
              <p class="text-xs text-slate-400 truncate">{{ $r->user->name }}</p>
            </div>
          </a>
        @empty<p class="px-5 py-6 text-center text-sm text-slate-400">Tidak ada laporan baru.</p>@endforelse
      </div>

      {{-- Mediasi --}}
      <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm p-5">
        <h2 class="font-display font-semibold text-slate-900 mb-3">Mediasi Mendatang</h2>
        @forelse($mediasiMendatang as $m)
          <a href="{{ route('reports.show',$m->report) }}" class="flex gap-3 py-2 border-b border-slate-50 last:border-0">
            <div class="text-center shrink-0 w-10 bg-violet-50 rounded-lg py-1">
              <p class="font-bold text-violet-700 leading-none">{{ $m->tanggal->format('d') }}</p>
              <p class="text-[10px] text-slate-400 uppercase">{{ $m->tanggal->format('M') }}</p>
            </div>
            <div class="min-w-0"><p class="text-sm text-slate-700 truncate">{{ $m->report->judul }}</p><p class="text-xs text-slate-400">{{ $m->tanggal->format('H:i') }}</p></div>
          </a>
        @empty<p class="text-sm text-slate-400 py-4 text-center">Tidak ada jadwal.</p>@endforelse
      </div>
    </div>
  </div>
  <script>function jamSimpati(){const hr=['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'],bl=['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];return{jam:'00:00',detik:':00',tanggal:'',sapaan:'',tick(){const d=new Date(),p=n=>String(n).padStart(2,'0');this.jam=p(d.getHours())+':'+p(d.getMinutes());this.detik=':'+p(d.getSeconds());this.tanggal=hr[d.getDay()]+', '+d.getDate()+' '+bl[d.getMonth()]+' '+d.getFullYear();const h=d.getHours();this.sapaan=h<5?'Selamat dini hari':h<11?'Selamat pagi':h<15?'Selamat siang':h<19?'Selamat sore':'Selamat malam';},start(){this.tick();setInterval(()=>this.tick(),1000);}}}
  </script>
@endsection
EOF

# ============================================================
# 10. REPORT CREATE — form accordion lengkap
# ============================================================
echo "==> Report create form"
cat > resources/views/reports/create.blade.php << 'BEOF'
@extends('layouts.app')
@section('title','Buat Laporan Sengketa')
@section('content')

<a href="{{ route('reports.index') }}" class="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700 mb-4">
  <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M17 10a.75.75 0 01-.75.75H5.612l4.158 3.96a.75.75 0 11-1.04 1.08l-5.5-5.25a.75.75 0 010-1.08l5.5-5.25a.75.75 0 111.04 1.08L5.612 9.25H16.25A.75.75 0 0117 10z" clip-rule="evenodd"/></svg>
  Kembali
</a>

<div class="max-w-3xl">
  <h1 class="font-display text-xl font-bold text-slate-900">Buat Laporan Sengketa Tanah</h1>
  <p class="text-sm text-slate-500 mt-1 mb-6">Isi semua data dengan lengkap dan benar. Laporan yang lengkap akan mempercepat proses penanganan.</p>

  @if($errors->any())
    <div class="mb-5 rounded-xl bg-rose-50 ring-1 ring-rose-200 text-rose-700 text-sm p-4">
      <p class="font-medium mb-1">Terdapat {{ $errors->count() }} kesalahan:</p>
      <ul class="list-disc pl-4 space-y-0.5">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul>
    </div>
  @endif

  <form method="POST" action="{{ route('reports.store') }}" enctype="multipart/form-data"
        x-data="laporanForm()" class="space-y-4">
    @csrf
    @php $inp='w-full rounded-xl border border-slate-300 px-3.5 py-2.5 text-sm outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition'; @endphp

    {{-- === SEKSI 1: JUDUL & PRIORITAS === --}}
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden">
      <div class="px-5 py-4 border-b border-slate-100">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1.5">Judul Laporan <span class="text-rose-500">*</span></label>
          <input name="judul" value="{{ old('judul') }}" required placeholder="Contoh: Sengketa batas tanah dengan pihak X di Desa Y"
            class="{{ $inp }}">
        </div>
        <div class="grid sm:grid-cols-2 gap-3 mt-3">
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-1.5">Jenis Sengketa</label>
            <select name="jenis" class="{{ $inp }}">
              <option value="">— Pilih jenis sengketa —</option>
              @foreach(['Batas tanah','Kepemilikan / Sertifikat','Warisan / Pembagian harta','Jual beli bermasalah','Sewa / Perjanjian tanah','Tanah adat / Ulayat','Tanah negara / Fasilitas umum','Tumpang tindih sertifikat','Penggusuran / Pengambilalihan','Lainnya'] as $j)
                <option value="{{ $j }}" @selected(old('jenis')===$j)>{{ $j }}</option>
              @endforeach
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-1.5">Prioritas <span class="text-rose-500">*</span></label>
            <select name="prioritas" class="{{ $inp }}">
              <option value="rendah" @selected(old('prioritas','sedang')==='rendah')>🟢 Rendah</option>
              <option value="sedang" @selected(old('prioritas','sedang')==='sedang')>🟡 Sedang</option>
              <option value="tinggi" @selected(old('prioritas')==='tinggi')>🔴 Tinggi / Mendesak</option>
            </select>
          </div>
        </div>
      </div>
    </div>

    {{-- === SEKSI 2: IDENTITAS PELAPOR (accordion) === --}}
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden" x-data="{open:true}">
      <button type="button" @click="open=!open"
        class="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-slate-50 transition">
        <div class="flex items-center gap-3">
          <span class="grid place-items-center w-8 h-8 rounded-xl bg-emerald-50 text-emerald-700">
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-5.5-2.5a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0zM10 12a5.99 5.99 0 00-4.793 2.39A6.483 6.483 0 0010 16.5a6.483 6.483 0 004.793-2.11A5.99 5.99 0 0010 12z" clip-rule="evenodd"/></svg>
          </span>
          <div class="text-left">
            <p class="font-semibold text-slate-800 text-sm">Identitas Pelapor</p>
            <p class="text-xs text-slate-400">NIK, KK, pekerjaan, alamat KTP</p>
          </div>
        </div>
        <svg class="w-4 h-4 text-slate-400 transition-transform" :class="open?'rotate-180':''" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.22 8.22a.75.75 0 011.06 0L10 11.94l3.72-3.72a.75.75 0 111.06 1.06l-4.25 4.25a.75.75 0 01-1.06 0L5.22 9.28a.75.75 0 010-1.06z" clip-rule="evenodd"/></svg>
      </button>
      <div x-show="open" x-transition class="px-5 pb-5 border-t border-slate-100">
        <div class="grid sm:grid-cols-2 gap-3 mt-4">
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Nama Lengkap Pelapor <span class="text-rose-500">*</span></label>
            <input name="nama_pelapor" value="{{ old('nama_pelapor',auth()->user()->name) }}" required class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">No. HP / WhatsApp <span class="text-rose-500">*</span></label>
            <input name="no_hp" value="{{ old('no_hp',auth()->user()->no_hp) }}" required class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">NIK (Nomor Induk Kependudukan)</label>
            <input name="nik_pelapor" value="{{ old('nik_pelapor') }}" maxlength="16" placeholder="16 digit sesuai KTP" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">No. Kartu Keluarga (KK)</label>
            <input name="no_kk" value="{{ old('no_kk') }}" maxlength="16" placeholder="16 digit" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Pekerjaan</label>
            <select name="pekerjaan" class="{{ $inp }}">
              <option value="">— Pilih pekerjaan —</option>
              @foreach(['Petani','Nelayan','Pedagang','PNS / ASN','TNI / Polri','Swasta','Wiraswasta','Pensiunan','Ibu Rumah Tangga','Pelajar / Mahasiswa','Tidak Bekerja','Lainnya'] as $p)
                <option value="{{ $p }}" @selected(old('pekerjaan')===$p)>{{ $p }}</option>
              @endforeach
            </select>
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">RT / RW</label>
            <input name="rt_rw" value="{{ old('rt_rw') }}" placeholder="Contoh: 002/005" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Desa / Kelurahan (domisili)</label>
            <input name="desa_kelurahan" value="{{ old('desa_kelurahan') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Kecamatan (domisili)</label>
            <input name="kecamatan_pelapor" value="{{ old('kecamatan_pelapor') }}" class="{{ $inp }}">
          </div>
          <div class="sm:col-span-2">
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Alamat Sesuai KTP</label>
            <textarea name="alamat_ktp" rows="2" placeholder="Alamat lengkap sesuai KTP" class="{{ $inp }}">{{ old('alamat_ktp') }}</textarea>
          </div>
        </div>
      </div>
    </div>

    {{-- === SEKSI 3: DATA SENGKETA & PIHAK TERLAPOR === --}}
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden" x-data="{open:true}">
      <button type="button" @click="open=!open"
        class="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-slate-50 transition">
        <div class="flex items-center gap-3">
          <span class="grid place-items-center w-8 h-8 rounded-xl bg-rose-50 text-rose-600">
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 1a4.5 4.5 0 00-4.5 4.5V9H5a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6a2 2 0 00-2-2h-.5V5.5A4.5 4.5 0 0010 1zm3 8V5.5a3 3 0 10-6 0V9h6z" clip-rule="evenodd"/></svg>
          </span>
          <div class="text-left">
            <p class="font-semibold text-slate-800 text-sm">Data Sengketa & Pihak Terlapor</p>
            <p class="text-xs text-slate-400">Tanggal sengketa, pihak terlapor, saksi</p>
          </div>
        </div>
        <svg class="w-4 h-4 text-slate-400 transition-transform" :class="open?'rotate-180':''" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.22 8.22a.75.75 0 011.06 0L10 11.94l3.72-3.72a.75.75 0 111.06 1.06l-4.25 4.25a.75.75 0 01-1.06 0L5.22 9.28a.75.75 0 010-1.06z" clip-rule="evenodd"/></svg>
      </button>
      <div x-show="open" x-transition class="px-5 pb-5 border-t border-slate-100">
        <div class="grid sm:grid-cols-2 gap-3 mt-4">
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Tanggal Mulai Sengketa</label>
            <input name="tanggal_sengketa" type="date" value="{{ old('tanggal_sengketa') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Tanggal Kejadian / Peristiwa</label>
            <input name="tanggal_kejadian" type="date" value="{{ old('tanggal_kejadian') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Nama Pihak Terlapor</label>
            <input name="pihak_terlapor" value="{{ old('pihak_terlapor') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">NIK Pihak Terlapor</label>
            <input name="nik_terlapor" value="{{ old('nik_terlapor') }}" maxlength="16" placeholder="Jika diketahui" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Saksi 1</label>
            <input name="saksi_1" value="{{ old('saksi_1') }}" placeholder="Nama saksi pertama" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Saksi 2</label>
            <input name="saksi_2" value="{{ old('saksi_2') }}" placeholder="Nama saksi kedua" class="{{ $inp }}">
          </div>
          <div class="sm:col-span-2">
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Upaya Penyelesaian yang Sudah Ditempuh</label>
            <textarea name="upaya_sebelumnya" rows="2" placeholder="Contoh: Sudah musyawarah di tingkat RT, sudah lapor ke Kepala Desa, dll" class="{{ $inp }}">{{ old('upaya_sebelumnya') }}</textarea>
          </div>
        </div>
      </div>
    </div>

    {{-- === SEKSI 4: LOKASI TANAH === --}}
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden" x-data="{open:true}">
      <button type="button" @click="open=!open"
        class="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-slate-50 transition">
        <div class="flex items-center gap-3">
          <span class="grid place-items-center w-8 h-8 rounded-xl bg-sky-50 text-sky-600">
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M9.69 18.933l.003.001C9.89 19.02 10 19 10 19s.11.02.308-.066l.002-.001.006-.003.018-.008a5.741 5.741 0 00.281-.14c.186-.096.446-.24.757-.433.62-.384 1.445-.966 2.274-1.765C15.302 14.988 17 12.493 17 9A7 7 0 103 9c0 3.492 1.698 5.988 3.355 7.584a13.731 13.731 0 002.273 1.765 11.842 11.842 0 00.976.544l.062.029.018.008.006.003zM10 11.25a2.25 2.25 0 100-4.5 2.25 2.25 0 000 4.5z" clip-rule="evenodd"/></svg>
          </span>
          <div class="text-left">
            <p class="font-semibold text-slate-800 text-sm">Lokasi Tanah yang Disengketakan</p>
            <p class="text-xs text-slate-400">Alamat, koordinat GPS, batas-batas tanah</p>
          </div>
        </div>
        <svg class="w-4 h-4 text-slate-400 transition-transform" :class="open?'rotate-180':''" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.22 8.22a.75.75 0 011.06 0L10 11.94l3.72-3.72a.75.75 0 111.06 1.06l-4.25 4.25a.75.75 0 01-1.06 0L5.22 9.28a.75.75 0 010-1.06z" clip-rule="evenodd"/></svg>
      </button>
      <div x-show="open" x-transition class="px-5 pb-5 border-t border-slate-100">
        <div class="grid sm:grid-cols-2 gap-3 mt-4">
          <div class="sm:col-span-2">
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Alamat Lokasi Tanah <span class="text-rose-500">*</span></label>
            <textarea name="lokasi" rows="2" required placeholder="Jalan, Dusun, RT/RW, Desa, Kecamatan" class="{{ $inp }}">{{ old('lokasi') }}</textarea>
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Desa / Kelurahan Lokasi Tanah</label>
            <input name="desa_lokasi" value="{{ old('desa_lokasi') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Kecamatan Lokasi Tanah</label>
            <input name="kecamatan" value="{{ old('kecamatan') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Luas Tanah Fisik (m²)</label>
            <input name="luas" type="number" step="0.01" value="{{ old('luas') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Luas Sesuai Dokumen (m²)</label>
            <input name="luas_dokumen" type="number" step="0.01" value="{{ old('luas_dokumen') }}" class="{{ $inp }}">
          </div>
        </div>
        {{-- Batas tanah --}}
        <div class="mt-3">
          <p class="text-xs font-medium text-slate-600 mb-2">Batas-Batas Tanah</p>
          <div class="grid grid-cols-2 gap-2">
            <div>
              <label class="block text-[11px] text-slate-400 mb-1">⬆ Utara</label>
              <input name="batas_utara" value="{{ old('batas_utara') }}" placeholder="Milik/jalan/sungai" class="{{ $inp }} text-xs">
            </div>
            <div>
              <label class="block text-[11px] text-slate-400 mb-1">⬇ Selatan</label>
              <input name="batas_selatan" value="{{ old('batas_selatan') }}" placeholder="Milik/jalan/sungai" class="{{ $inp }} text-xs">
            </div>
            <div>
              <label class="block text-[11px] text-slate-400 mb-1">➡ Timur</label>
              <input name="batas_timur" value="{{ old('batas_timur') }}" placeholder="Milik/jalan/sungai" class="{{ $inp }} text-xs">
            </div>
            <div>
              <label class="block text-[11px] text-slate-400 mb-1">⬅ Barat</label>
              <input name="batas_barat" value="{{ old('batas_barat') }}" placeholder="Milik/jalan/sungai" class="{{ $inp }} text-xs">
            </div>
          </div>
        </div>
        {{-- Koordinat GPS --}}
        <div class="mt-3 grid sm:grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Latitude</label>
            <input name="latitude" x-ref="lat" value="{{ old('latitude') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Longitude</label>
            <input name="longitude" x-ref="lng" value="{{ old('longitude') }}" class="{{ $inp }}">
          </div>
        </div>
        <button type="button" @click="ambilGPS()"
          class="mt-2 inline-flex items-center gap-2 rounded-xl ring-1 ring-emerald-300 text-emerald-700 px-3.5 py-2 text-xs font-medium hover:bg-emerald-50 transition">
          <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M9.69 18.933l.003.001C9.89 19.02 10 19 10 19s.11.02.308-.066l.002-.001.006-.003.018-.008a5.741 5.741 0 00.281-.14c.186-.096.446-.24.757-.433.62-.384 1.445-.966 2.274-1.765C15.302 14.988 17 12.493 17 9A7 7 0 103 9c0 3.492 1.698 5.988 3.355 7.584a13.731 13.731 0 002.273 1.765 11.842 11.842 0 00.976.544l.062.029.018.008.006.003zM10 11.25a2.25 2.25 0 100-4.5 2.25 2.25 0 000 4.5z" clip-rule="evenodd"/></svg>
          <span x-text="gpsLabel">Ambil lokasi GPS</span>
        </button>
      </div>
    </div>

    {{-- === SEKSI 5: DATA KEPEMILIKAN === --}}
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden" x-data="{open:false}">
      <button type="button" @click="open=!open"
        class="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-slate-50 transition">
        <div class="flex items-center gap-3">
          <span class="grid place-items-center w-8 h-8 rounded-xl bg-amber-50 text-amber-600">
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2h-1.528A6 6 0 004 9.528V4z"/><path fill-rule="evenodd" d="M8 10a4 4 0 00-3.446 6.032l-1.261 1.26a.75.75 0 101.06 1.06l1.261-1.26A4 4 0 108 10zm-2.5 4a2.5 2.5 0 115 0 2.5 2.5 0 01-5 0z" clip-rule="evenodd"/></svg>
          </span>
          <div class="text-left">
            <p class="font-semibold text-slate-800 text-sm">Data Kepemilikan Tanah</p>
            <p class="text-xs text-slate-400">Jenis hak, nomor sertifikat, cara perolehan <span class="text-slate-300">(opsional)</span></p>
          </div>
        </div>
        <svg class="w-4 h-4 text-slate-400 transition-transform" :class="open?'rotate-180':''" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.22 8.22a.75.75 0 011.06 0L10 11.94l3.72-3.72a.75.75 0 111.06 1.06l-4.25 4.25a.75.75 0 01-1.06 0L5.22 9.28a.75.75 0 010-1.06z" clip-rule="evenodd"/></svg>
      </button>
      <div x-show="open" x-transition class="px-5 pb-5 border-t border-slate-100">
        <div class="grid sm:grid-cols-2 gap-3 mt-4">
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Jenis Hak Atas Tanah</label>
            <select name="jenis_hak" class="{{ $inp }}">
              <option value="">— Pilih jenis hak —</option>
              @foreach(['SHM (Sertifikat Hak Milik)','SHGB (Hak Guna Bangunan)','SHU (Hak Guna Usaha)','Girik / Petok D','Letter C','Eigendom Verponding','SPORADIK','Tanah Adat','Belum Bersertifikat','Lainnya'] as $h)
                <option value="{{ $h }}" @selected(old('jenis_hak')===$h)>{{ $h }}</option>
              @endforeach
            </select>
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">No. Sertifikat / Girik / Letter C</label>
            <input name="no_sertifikat" value="{{ old('no_sertifikat') }}" class="{{ $inp }}">
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-600 mb-1.5">Cara Perolehan Tanah</label>
            <select name="cara_perolehan" class="{{ $inp }}">
              <option value="">— Pilih cara perolehan —</option>
              @foreach(['Jual beli','Warisan','Hibah','Tukar menukar','Pemberian negara','Konsolidasi tanah','Redistribusi tanah','Lainnya'] as $c)
                <option value="{{ $c }}" @selected(old('cara_perolehan')===$c)>{{ $c }}</option>
              @endforeach
            </select>
          </div>
        </div>
      </div>
    </div>

    {{-- === SEKSI 6: KRONOLOGI === --}}
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden" x-data="{open:true}">
      <button type="button" @click="open=!open"
        class="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-slate-50 transition">
        <div class="flex items-center gap-3">
          <span class="grid place-items-center w-8 h-8 rounded-xl bg-violet-50 text-violet-600">
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M4.5 2A1.5 1.5 0 003 3.5v13A1.5 1.5 0 004.5 18h11a1.5 1.5 0 001.5-1.5V7.621a1.5 1.5 0 00-.44-1.06l-4.12-4.122A1.5 1.5 0 0011.378 2H4.5zm2.25 8.5a.75.75 0 000 1.5h6.5a.75.75 0 000-1.5h-6.5zm0 3a.75.75 0 000 1.5h6.5a.75.75 0 000-1.5h-6.5zM6 7.25a.75.75 0 01.75-.75h.5a.75.75 0 010 1.5h-.5A.75.75 0 016 7.25z" clip-rule="evenodd"/></svg>
          </span>
          <div class="text-left">
            <p class="font-semibold text-slate-800 text-sm">Kronologi Kejadian <span class="text-rose-500">*</span></p>
            <p class="text-xs text-slate-400">Ceritakan urutan peristiwa secara lengkap</p>
          </div>
        </div>
        <svg class="w-4 h-4 text-slate-400 transition-transform" :class="open?'rotate-180':''" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.22 8.22a.75.75 0 011.06 0L10 11.94l3.72-3.72a.75.75 0 111.06 1.06l-4.25 4.25a.75.75 0 01-1.06 0L5.22 9.28a.75.75 0 010-1.06z" clip-rule="evenodd"/></svg>
      </button>
      <div x-show="open" x-transition class="px-5 pb-5 border-t border-slate-100">
        <div class="mt-4">
          <textarea name="kronologi" rows="6" required
            placeholder="Ceritakan secara kronologis: kapan sengketa mulai terjadi, apa yang menjadi pokok permasalahan, tindakan apa yang sudah dilakukan oleh masing-masing pihak, siapa saja yang terlibat, dan apa yang diharapkan dari pelaporan ini."
            class="{{ $inp }}">{{ old('kronologi') }}</textarea>
          <p class="text-[11px] text-slate-400 mt-1">Semakin lengkap kronologi, semakin cepat laporan ditangani.</p>
        </div>
      </div>
    </div>

    {{-- === SEKSI 7: DOKUMEN === --}}
    <div class="bg-white rounded-2xl ring-1 ring-slate-200 shadow-sm overflow-hidden" x-data="{open:true}">
      <button type="button" @click="open=!open"
        class="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-slate-50 transition">
        <div class="flex items-center gap-3">
          <span class="grid place-items-center w-8 h-8 rounded-xl bg-slate-100 text-slate-500">
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path d="M3 3.5A1.5 1.5 0 014.5 2h6.879a1.5 1.5 0 011.06.44l4.122 4.12A1.5 1.5 0 0117 7.622V16.5a1.5 1.5 0 01-1.5 1.5h-11A1.5 1.5 0 013 16.5v-13z"/></svg>
          </span>
          <div class="text-left">
            <p class="font-semibold text-slate-800 text-sm">Dokumen & Foto Bukti</p>
            <p class="text-xs text-slate-400">Maks. 8 file · jpg/png/pdf · ≤ 5MB per file</p>
          </div>
        </div>
        <svg class="w-4 h-4 text-slate-400 transition-transform" :class="open?'rotate-180':''" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.22 8.22a.75.75 0 011.06 0L10 11.94l3.72-3.72a.75.75 0 111.06 1.06l-4.25 4.25a.75.75 0 01-1.06 0L5.22 9.28a.75.75 0 010-1.06z" clip-rule="evenodd"/></svg>
      </button>
      <div x-show="open" x-transition class="px-5 pb-5 border-t border-slate-100">
        <div class="mt-4">
          <div class="rounded-xl border-2 border-dashed border-slate-300 hover:border-emerald-400 transition p-6 text-center cursor-pointer" @click="$refs.fileinput.click()">
            <svg class="w-8 h-8 text-slate-300 mx-auto mb-2" viewBox="0 0 24 24" fill="none"><path d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5" stroke="currentColor" stroke-width="1.5"/></svg>
            <p class="text-sm text-slate-500">Klik untuk pilih file atau seret ke sini</p>
            <p class="text-xs text-slate-400 mt-1">KTP, KK, sertifikat, foto tanah, dll</p>
          </div>
          <input x-ref="fileinput" type="file" name="dokumen[]" multiple accept=".jpg,.jpeg,.png,.pdf"
            @change="pilihFile($event)" class="hidden">
          <ul class="mt-3 space-y-1.5" x-show="files.length">
            <template x-for="f in files" :key="f">
              <li class="flex items-center gap-2 text-xs text-slate-600 bg-slate-50 rounded-lg px-3 py-2">
                <svg class="w-3.5 h-3.5 text-emerald-500 shrink-0" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z" clip-rule="evenodd"/></svg>
                <span x-text="f"></span>
              </li>
            </template>
          </ul>
        </div>
      </div>
    </div>

    {{-- SUBMIT --}}
    <div class="flex items-center gap-3 pt-2">
      <button type="submit"
        class="inline-flex items-center gap-2 rounded-xl bg-emerald-700 text-white px-6 py-3 text-sm font-semibold hover:bg-emerald-800 transition shadow-sm shadow-emerald-200">
        <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor"><path d="M3.105 2.289a.75.75 0 00-.826.95l1.414 4.925A1.5 1.5 0 005.135 9.25h6.115a.75.75 0 010 1.5H5.135a1.5 1.5 0 00-1.442 1.086l-1.414 4.926a.75.75 0 00.826.95 28.896 28.896 0 0015.293-7.154.75.75 0 000-1.115A28.897 28.897 0 003.105 2.289z"/></svg>
        Kirim Laporan
      </button>
      <a href="{{ route('reports.index') }}" class="rounded-xl ring-1 ring-slate-300 text-slate-600 px-5 py-3 text-sm hover:bg-slate-50 transition">Batal</a>
    </div>
  </form>
</div>

<script>
function laporanForm(){
  return {
    files: [],
    gpsLabel: 'Ambil lokasi GPS',
    pilihFile(e){ this.files = Array.from(e.target.files).map(f => f.name+' ('+Math.round(f.size/1024)+' KB)'); },
    ambilGPS(){
      if(!navigator.geolocation){ this.gpsLabel='GPS tidak tersedia'; return; }
      this.gpsLabel = 'Mengambil koordinat...';
      navigator.geolocation.getCurrentPosition(
        p => { this.$refs.lat.value=p.coords.latitude.toFixed(7); this.$refs.lng.value=p.coords.longitude.toFixed(7); this.gpsLabel='✓ Koordinat terisi'; },
        () => { this.gpsLabel='Gagal — isi manual'; }
      );
    },
  }
}
</script>
@endsection
BEOF

# ============================================================
# 11. CSS — tambahan utility
# ============================================================
echo "==> CSS utility"
if ! grep -q 'SIMPATI-V4' resources/css/app.css; then
cat >> resources/css/app.css << 'EOF'

/* === SIMPATI-V4 === */
html{scroll-behavior:smooth}
*{-webkit-tap-highlight-color:transparent}
body{font-feature-settings:"liga"1,"kern"1}

.dark .hero-pattern{filter:brightness(0.7)}

/* Scroll bar tipis */
::-webkit-scrollbar{width:4px;height:4px}
::-webkit-scrollbar-track{background:transparent}
::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:4px}
::-webkit-scrollbar-thumb:hover{background:#94a3b8}
EOF
fi

# ============================================================
# 12. MIGRATE & BUILD & PUSH
# ============================================================
echo "==> Migrate"
php artisan migrate --force

echo "==> Optimize"
php artisan optimize:clear

echo "==> Build"
npm run build

echo "==> Push"
git add .
git commit -m "feat: SIMPATI v4 — dashboard terpisah warga/staff/admin, login elegan, form laporan lengkap (NIK KK KTP batas tanah saksi dll), accordion sections, ikon refined"
git push

echo ""
echo "============================================================"
echo "  SIMPATI v4 SELESAI ✓"
echo ""
echo "  Yang baru:"
echo "  - Login: panel kiri peta tanah + fitur list"
echo "  - Dashboard WARGA  : status laporan, mediasi, panduan"
echo "  - Dashboard PETUGAS: stats operasional, laporan baru, chart"
echo "  - Dashboard ADMIN  : stats lengkap, by jenis, semua data"
echo "  - Form laporan: 7 seksi accordion (NIK, KK, batas tanah,"
echo "    saksi, upaya sebelumnya, koordinat GPS, dokumen)"
echo "  - Scroll mulus + scrollbar tipis"
echo "============================================================"
