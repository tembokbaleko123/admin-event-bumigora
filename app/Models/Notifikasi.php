<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notifikasi extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'event_id',
        'pesan',
        'status',
    ];

    /**
     * Relasi: Notifikasi dimiliki oleh satu User
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Relasi: Notifikasi terkait dengan satu Event (nullable)
     */
    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    /**
     * Tandai notifikasi sebagai sudah dibaca
     */
    public function markAsRead()
    {
        $this->update(['status' => 'read']);
    }

    /**
     * Kirim notifikasi ke user
     * Static method untuk membuat notifikasi baru
     */
    public static function kirimNotifikasi(User $user, string $pesan, ?Event $event = null): Notifikasi
    {
        return self::create([
            'user_id' => $user->id,
            'event_id' => $event?->id,
            'pesan' => $pesan,
            'status' => 'unread',
        ]);
    }

    /**
     * Kirim notifikasi ke semua user dengan role tertentu
     */
    public static function kirimNotifikasiKeRole(string $role, string $pesan, ?Event $event = null): void
    {
        $users = User::where('role', $role)->get();
        
        foreach ($users as $user) {
            self::kirimNotifikasi($user, $pesan, $event);
        }
    }

    /**
     * Scope untuk notifikasi yang belum dibaca
     */
    public function scopeUnread($query)
    {
        return $query->where('status', 'unread');
    }

    /**
     * Scope untuk notifikasi yang sudah dibaca
     */
    public function scopeRead($query)
    {
        return $query->where('status', 'read');
    }
}
