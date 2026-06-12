<?php

namespace App\Models;

use App\Enums\UserRole;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\Hash;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'nama',
        'email',
        'password',
        'role',
    ];

    protected $hidden = [
        'password',
    ];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
        ];
    }

    /**
     * Get token expiration in minutes from config
     */
    public function getTokenExpiryMinutes(): int
    {
        return config('sanctum.expiration', 10080); // Default 7 days
    }

    /**
     * Create token with expiration
     */
    public function createTokenWithExpiry(string $name, array $abilities = ['*']): array
    {
        $token = $this->createToken($name, $abilities);

        return [
            'token' => $token->plainTextToken,
            'expires_at' => now()->addMinutes($this->getTokenExpiryMinutes())->toIso8601String(),
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
        return $this->role === UserRole::Admin->value;
    }

    /**
     * Cek apakah user adalah dosen
     */
    public function isDosen(): bool
    {
        return $this->role === UserRole::Dosen->value;
    }

    /**
     * Cek apakah user adalah mahasiswa
     */
    public function isMahasiswa(): bool
    {
        return $this->role === UserRole::Mahasiswa->value;
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
     * Relasi: User memiliki banyak pendaftaran event
     */
    public function registrations()
    {
        return $this->hasMany(EventRegistration::class);
    }

    /**
     * Register user baru
     */
    public static function register(array $data): User
    {
        return self::create([
            'nama' => $data['nama'],
            'email' => $data['email'],
            'password' => $data['password'],
            'role' => $data['role'] ?? UserRole::Mahasiswa->value,
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
     * Update password user
     */
    public function updatePassword(string $password): bool
    {
        $this->update([
            'password' => $password,
        ]);

        return true;
    }
}
