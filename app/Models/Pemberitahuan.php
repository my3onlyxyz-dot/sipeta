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
