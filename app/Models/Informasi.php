<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Informasi extends Model
{
    use HasFactory;

    protected $fillable = [
        'judul',
        'isi',
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
     * Tambah informasi baru
     */
    public static function tambahInformasi(array $data, User $creator): Informasi
    {
        return self::create([
            'judul' => $data['judul'],
            'isi' => $data['isi'],
            'tanggal' => $data['tanggal'],
            'dibuat_oleh' => $creator->id,
        ]);
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

        $this->update($updateData);

        return true;
    }

    /**
     * Hapus informasi
     */
    public function hapusInformasi(): bool
    {
        $this->delete();
        return true;
    }
}
