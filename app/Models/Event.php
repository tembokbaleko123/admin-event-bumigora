<?php

namespace App\Models;

use App\Enums\EventStatus;
use App\Enums\RegistrationStatus;
use App\Enums\UserRole;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use App\Traits\Auditable;

class Event extends Model
{
    use HasFactory, SoftDeletes, Auditable;

    protected $appends = ['gambar_url'];

    protected $fillable = [
        'judul',
        'tanggal',
        'tanggal_selesai',
        'batas_daftar',
        'lokasi',
        'deskripsi',
        'gambar',
        'kategori',
        'kapasitas',
        'status',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'tanggal' => 'datetime',
            'tanggal_selesai' => 'datetime',
            'batas_daftar' => 'datetime',
            'kapasitas' => 'integer',
        ];
    }

    /**
     * Relasi: Event dibuat oleh satu User
     */
    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    /**
     * Relasi: Event memiliki banyak Notifikasi
     */
    public function notifikasis()
    {
        return $this->hasMany(Notifikasi::class);
    }

    /**
     * Relasi: Event memiliki banyak Pendaftaran
     */
    public function registrations()
    {
        return $this->hasMany(EventRegistration::class);
    }

    /**
     * Relasi: Event memiliki banyak QR Token
     */
    public function qrTokens()
    {
        return $this->hasMany(EventQrToken::class);
    }

    /**
     * Relasi: Event memiliki banyak Absensi
     */
    public function attendances()
    {
        return $this->hasMany(Attendance::class);
    }

    /**
     * Relasi: Event memiliki pendaftar aktif (registered)
     */
    public function activeRegistrations()
    {
        return $this->hasMany(EventRegistration::class)->where('status', RegistrationStatus::Registered->value);
    }

    /**
     * Cek apakah event masih bisa didaftar
     */
    public function canRegister(): bool
    {
        if ($this->status !== EventStatus::Published->value) return false;
        if ($this->tanggal->isPast()) return false;
        if ($this->batas_daftar && $this->batas_daftar->isPast()) return false;
        if ($this->kapasitas) {
            $count = $this->confirmed_registrations_count ?? $this->confirmedRegistrations()->count();
            if ($count >= $this->kapasitas) return false;
        }
        return true;
    }

    public function confirmedRegistrations()
    {
        return $this->hasMany(EventRegistration::class)->whereIn('status', [RegistrationStatus::Registered->value, RegistrationStatus::Attended->value]);
    }

    /**
     * Hitung sisa kuota
     */
    public function getSisaKuotaAttribute(): ?int
    {
        if (!$this->kapasitas) return null;
        $count = $this->confirmed_registrations_count ?? $this->confirmedRegistrations()->count();
        return max(0, $this->kapasitas - $count);
    }

    /**
     * Scope: Filter berdasarkan pencarian
     */
    public function scopeSearch($query, ?string $search)
    {
        if ($search) {
            $escaped = str_replace(['\\', '%', '_'], ['\\\\', '\\%', '\\_'], $search);
            return $query->where(function ($q) use ($escaped) {
                $q->where('judul', 'like', "%{$escaped}%")
                  ->orWhere('lokasi', 'like', "%{$escaped}%")
                  ->orWhere('deskripsi', 'like', "%{$escaped}%")
                  ->orWhere('kategori', 'like', "%{$escaped}%");
            });
        }
        return $query;
    }

    /**
     * Scope: Filter berdasarkan kategori
     */
    public function scopeKategori($query, ?string $kategori)
    {
        if ($kategori) {
            return $query->whereRaw('UPPER(kategori) = ?', [strtoupper($kategori)]);
        }
        return $query;
    }

    public static function normalizeKategori(?string $kategori): ?string
    {
        if ($kategori === null || trim($kategori) === '') {
            return null;
        }

        return strtoupper(trim($kategori));
    }

    /**
     * Upload gambar event
     */
    public static function uploadGambar($file): string
    {
        return $file->store('events', 'public');
    }

    /**
     * Hapus gambar lama jika ada
     */
    public function hapusGambar(): void
    {
        if ($this->gambar) {
            Storage::disk('public')->delete($this->gambar);
        }
    }

    /**
     * Get URL gambar
     */
    public function getGambarUrlAttribute(): ?string
    {
        return $this->gambar ? Storage::url($this->gambar) : null;
    }

    /**
     * Tambah event baru
     */
    public static function tambahEvent(array $data, User $creator): Event
    {
        $eventData = [
            'judul' => $data['judul'],
            'tanggal' => $data['tanggal'],
            'tanggal_selesai' => $data['tanggal_selesai'] ?? null,
            'batas_daftar' => $data['batas_daftar'] ?? null,
            'lokasi' => $data['lokasi'],
            'deskripsi' => $data['deskripsi'] ?? null,
            'kategori' => self::normalizeKategori($data['kategori'] ?? null),
            'kapasitas' => $data['kapasitas'] ?? null,
            'status' => $creator->isAdmin() ? ($data['status'] ?? EventStatus::Published->value) : EventStatus::Pending->value,
            'created_by' => $creator->id,
        ];

        if (isset($data['gambar']) && $data['gambar']) {
            $eventData['gambar'] = self::uploadGambar($data['gambar']);
        }

        return DB::transaction(function () use ($eventData) {
            $event = self::create($eventData);

            if ($event->status === EventStatus::Published->value) {
                Notifikasi::kirimNotifikasiKeRole(
                    UserRole::Mahasiswa->value,
                    "Event baru: {$event->judul} pada {$event->tanggal->format('d M Y')} di {$event->lokasi}",
                    $event
                );
            } else {
                Notifikasi::kirimNotifikasiKeRole(
                    UserRole::Admin->value,
                    "Event menunggu persetujuan: {$event->judul}",
                    $event
                );
            }

            return $event;
        });
    }

    /**
     * Update event
     */
    public function updateEvent(array $data): bool
    {
        $updateData = [];

        if (array_key_exists('judul', $data)) {
            $updateData['judul'] = $data['judul'];
        }
        if (array_key_exists('tanggal', $data)) {
            $updateData['tanggal'] = $data['tanggal'];
        }
        if (array_key_exists('tanggal_selesai', $data)) {
            $updateData['tanggal_selesai'] = $data['tanggal_selesai'];
        }
        if (array_key_exists('batas_daftar', $data)) {
            $updateData['batas_daftar'] = $data['batas_daftar'];
        }
        if (array_key_exists('lokasi', $data)) {
            $updateData['lokasi'] = $data['lokasi'];
        }
        if (array_key_exists('deskripsi', $data)) {
            $updateData['deskripsi'] = $data['deskripsi'];
        }
        if (array_key_exists('kategori', $data)) {
            $updateData['kategori'] = self::normalizeKategori($data['kategori']);
        }
        if (array_key_exists('kapasitas', $data)) {
            $updateData['kapasitas'] = $data['kapasitas'];
        }
        if (array_key_exists('status', $data)) {
            $updateData['status'] = $data['status'];
        }

        // Handle gambar upload
        if (isset($data['gambar']) && $data['gambar']) {
            $this->hapusGambar();
            $updateData['gambar'] = self::uploadGambar($data['gambar']);
        }

        // Handle hapus gambar (jika dikirim nilai null explicit)
        if (array_key_exists('hapus_gambar', $data) && $data['hapus_gambar']) {
            $this->hapusGambar();
            $updateData['gambar'] = null;
        }

        if (!empty($updateData)) {
            DB::transaction(function () use ($updateData) {
                $this->update($updateData);

                if ($this->status === EventStatus::Published->value) {
                    Notifikasi::kirimNotifikasiKeRole(
                        UserRole::Mahasiswa->value,
                        "Event diupdate: {$this->judul}",
                        $this
                    );
                }
            });
        }

        return true;
    }

    /**
     * Hapus event termasuk gambar
     */
    public function hapusEvent(): bool
    {
        $judul = $this->judul;

        DB::transaction(function () use ($judul) {
            $this->hapusGambar();
            $this->delete();

            // Kirim notifikasi pembatalan
            Notifikasi::kirimNotifikasiKeRole(
                UserRole::Mahasiswa->value,
                "Event dibatalkan: {$judul}",
                null
            );
        });

        return true;
    }
}
