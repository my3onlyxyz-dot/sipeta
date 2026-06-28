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
