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
