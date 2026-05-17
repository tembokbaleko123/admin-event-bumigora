<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = [
        'nama',
        'email',
        'password',
        'role',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Scope: Filter berdasarkan pencarian
     */
    public function scopeSearch($query, ?string $search)
    {
        if ($search) {
            return $query->where(function ($q) use ($search) {
                $q->where('nama', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('role', 'like', "%{$search}%");
            });
        }
        return $query;
    }

    /**
     * Scope: Filter berdasarkan role
     */
    public function scopeRole($query, ?string $role)
    {
        if ($role) {
            return $query->where('role', $role);
        }
        return $query;
    }

    /**
     * Cek apakah user adalah admin
     */
    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    /**
     * Cek apakah user adalah dosen
     */
    public function isDosen(): bool
    {
        return $this->role === 'dosen';
    }

    /**
     * Cek apakah user adalah mahasiswa
     */
    public function isMahasiswa(): bool
    {
        return $this->role === 'mahasiswa';
    }

    /**
     * Relasi: User memiliki banyak Event (sebagai creator)
     */
    public function events()
    {
        return $this->hasMany(Event::class, 'created_by');
    }

    /**
     * Relasi: User memiliki banyak Informasi
     */
    public function informasis()
    {
        return $this->hasMany(Informasi::class, 'dibuat_oleh');
    }

    /**
     * Relasi: User memiliki banyak Notifikasi
     */
    public function notifikasis()
    {
        return $this->hasMany(Notifikasi::class);
    }

    /**
     * Register user baru
     */
    public static function register(array $data): User
    {
        return self::create([
            'nama' => $data['nama'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'role' => $data['role'] ?? 'mahasiswa',
        ]);
    }

    /**
     * Login user
     */
    public static function login(string $email, string $password): ?User
    {
        $user = self::where('email', $email)->first();

        if (!$user || !Hash::check($password, $user->password)) {
            return null;
        }

        return $user;
    }

    /**
     * Update profil user
     */
    public function updateProfil(array $data): bool
    {
        $updateData = [];

        if (array_key_exists('nama', $data)) {
            $updateData['nama'] = $data['nama'];
        }
        if (array_key_exists('email', $data)) {
            $updateData['email'] = $data['email'];
        }

        if (!empty($updateData)) {
            $this->update($updateData);
        }

        return true;
    }

    /**
     * Update password user
     */
    public function updatePassword(string $password): bool
    {
        $this->update([
            'password' => Hash::make($password),
        ]);

        return true;
    }
}
