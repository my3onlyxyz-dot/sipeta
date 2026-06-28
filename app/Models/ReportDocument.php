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
