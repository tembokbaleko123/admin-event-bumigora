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

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    public function markAsRead()
    {
        $this->update(['status' => 'read']);
    }

    public static function kirimNotifikasi(User $user, string $pesan, ?Event $event = null): Notifikasi
    {
        return self::create([
            'user_id' => $user->id,
            'event_id' => $event?->id,
            'pesan' => $pesan,
            'status' => 'unread',
        ]);
    }

    public static function kirimNotifikasiKeRole(string $role, string $pesan, ?Event $event = null): void
    {
        $now = now();
        $chunkSize = 500;

        User::where('role', $role)->chunk($chunkSize, function ($users) use ($pesan, $event, $now) {
            $data = $users->map(fn($user) => [
                'user_id' => $user->id,
                'event_id' => $event?->id,
                'pesan' => $pesan,
                'status' => 'unread',
                'created_at' => $now,
                'updated_at' => $now,
            ])->toArray();

            if (!empty($data)) {
                self::insert($data);
            }
        });
    }

    public function scopeUnread($query)
    {
        return $query->where('status', 'unread');
    }

    public function scopeRead($query)
    {
        return $query->where('status', 'read');
    }
}
