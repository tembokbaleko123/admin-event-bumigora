<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    use HasFactory;

    protected $fillable = [
        'judul',
        'tanggal',
        'lokasi',
        'deskripsi',
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
     * Tambah event baru
     */
    public static function tambahEvent(array $data, User $creator): Event
    {
        $event = self::create([
            'judul' => $data['judul'],
            'tanggal' => $data['tanggal'],
            'lokasi' => $data['lokasi'],
            'deskripsi' => $data['deskripsi'] ?? null,
            'created_by' => $creator->id,
        ]);

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
        $this->update([
            'judul' => $data['judul'] ?? $this->judul,
            'tanggal' => $data['tanggal'] ?? $this->tanggal,
            'lokasi' => $data['lokasi'] ?? $this->lokasi,
            'deskripsi' => $data['deskripsi'] ?? $this->deskripsi,
        ]);

        // Kirim notifikasi update ke mahasiswa
        Notifikasi::kirimNotifikasiKeRole(
            'mahasiswa',
            "Event diupdate: {$this->judul}",
            $this
        );

        return true;
    }

    /**
     * Hapus event
     */
    public function hapusEvent(): bool
    {
        $judul = $this->judul;
        
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
