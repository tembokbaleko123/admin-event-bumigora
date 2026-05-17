<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class Informasi extends Model
{
    use HasFactory;

    protected $appends = ['gambar_url'];

    protected $fillable = [
        'judul',
        'isi',
        'gambar',
        'tanggal',
        'dibuat_oleh',
    ];

    protected function casts(): array
    {
        return [
            'tanggal' => 'date',
        ];
    }

    /**
     * Relasi: Informasi dibuat oleh satu User
     */
    public function creator()
    {
        return $this->belongsTo(User::class, 'dibuat_oleh');
    }

    /**
     * Scope: Filter berdasarkan pencarian
     */
    public function scopeSearch($query, ?string $search)
    {
        if ($search) {
            return $query->where(function ($q) use ($search) {
                $q->where('judul', 'like', "%{$search}%")
                  ->orWhere('isi', 'like', "%{$search}%");
            });
        }
        return $query;
    }

    /**
     * Upload gambar informasi
     */
    public static function uploadGambar($file): string
    {
        return $file->store('informasis', 'public');
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
     * Tambah informasi baru
     */
    public static function tambahInformasi(array $data, User $creator): Informasi
    {
        $infoData = [
            'judul' => $data['judul'],
            'isi' => $data['isi'],
            'tanggal' => $data['tanggal'],
            'dibuat_oleh' => $creator->id,
        ];

        if (isset($data['gambar']) && $data['gambar']) {
            $infoData['gambar'] = self::uploadGambar($data['gambar']);
        }

        return self::create($infoData);
    }

    /**
     * Update informasi
     */
    public function updateInformasi(array $data): bool
    {
        $updateData = [];

        if (array_key_exists('judul', $data)) {
            $updateData['judul'] = $data['judul'];
        }
        if (array_key_exists('isi', $data)) {
            $updateData['isi'] = $data['isi'];
        }
        if (array_key_exists('tanggal', $data)) {
            $updateData['tanggal'] = $data['tanggal'];
        }

        // Handle gambar upload
        if (isset($data['gambar']) && $data['gambar']) {
            $this->hapusGambar();
            $updateData['gambar'] = self::uploadGambar($data['gambar']);
        }

        // Handle hapus gambar
        if (array_key_exists('hapus_gambar', $data) && $data['hapus_gambar']) {
            $this->hapusGambar();
            $updateData['gambar'] = null;
        }

        $this->update($updateData);

        return true;
    }

    /**
     * Hapus informasi termasuk gambar
     */
    public function hapusInformasi(): bool
    {
        $this->hapusGambar();
        $this->delete();
        return true;
    }
}
