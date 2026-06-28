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
