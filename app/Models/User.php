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
