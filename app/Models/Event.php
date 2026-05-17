<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class Event extends Model
{
    use HasFactory;

    protected $fillable = [
        'judul',
        'tanggal',
        'lokasi',
        'deskripsi',
        'gambar',
        'kategori',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'tanggal' => 'date',
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
     * Scope: Filter berdasarkan pencarian
     */
    public function scopeSearch($query, ?string $search)
    {
        if ($search) {
            return $query->where(function ($q) use ($search) {
                $q->where('judul', 'like', "%{$search}%")
                  ->orWhere('lokasi', 'like', "%{$search}%")
                  ->orWhere('deskripsi', 'like', "%{$search}%")
                  ->orWhere('kategori', 'like', "%{$search}%");
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
            return $query->where('kategori', $kategori);
        }
        return $query;
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
        if ($this->gambar && Storage::disk('public')->exists($this->gambar)) {
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
            'lokasi' => $data['lokasi'],
            'deskripsi' => $data['deskripsi'] ?? null,
            'kategori' => $data['kategori'] ?? null,
            'created_by' => $creator->id,
        ];

        if (isset($data['gambar']) && $data['gambar']) {
            $eventData['gambar'] = self::uploadGambar($data['gambar']);
        }

        $event = self::create($eventData);

        // Kirim notifikasi ke mahasiswa tentang event baru
        Notifikasi::kirimNotifikasiKeRole(
            'mahasiswa',
            "Event baru: {$event->judul} pada {$event->tanggal->format('d M Y')} di {$event->lokasi}",
            $event
        );

        return $event;
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
        if (array_key_exists('lokasi', $data)) {
            $updateData['lokasi'] = $data['lokasi'];
        }
        if (array_key_exists('deskripsi', $data)) {
            $updateData['deskripsi'] = $data['deskripsi'];
        }
        if (array_key_exists('kategori', $data)) {
            $updateData['kategori'] = $data['kategori'];
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

        $this->update($updateData);

        // Kirim notifikasi update ke mahasiswa
        Notifikasi::kirimNotifikasiKeRole(
            'mahasiswa',
            "Event diupdate: {$this->judul}",
            $this
        );

        return true;
    }

    /**
     * Hapus event termasuk gambar
     */
    public function hapusEvent(): bool
    {
        $judul = $this->judul;

        $this->hapusGambar();
        $this->delete();

        // Kirim notifikasi pembatalan
        Notifikasi::kirimNotifikasiKeRole(
            'mahasiswa',
            "Event dibatalkan: {$judul}",
            null
        );

        return true;
    }
}
