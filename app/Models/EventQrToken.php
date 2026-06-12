<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class EventQrToken extends Model
{
    use HasFactory;

    protected $fillable = [
        'event_id',
        'token',
        'expired_at',
        'is_active',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'expired_at' => 'datetime',
            'is_active' => 'boolean',
        ];
    }

    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public static function generateToken(Event $event, int $durationMinutes = 120, User $creator): self
    {
        self::where('event_id', $event->id)->where('is_active', true)
            ->update(['is_active' => false]);

        return self::create([
            'event_id' => $event->id,
            'token' => Str::random(48),
            'expired_at' => now()->addMinutes($durationMinutes),
            'is_active' => true,
            'created_by' => $creator->id,
        ]);
    }

    public function isValid(): bool
    {
        return $this->is_active && $this->expired_at->isFuture();
    }

    public function isExpired(): bool
    {
        return $this->expired_at->isPast();
    }

    public function scopeActive($query, int $eventId)
    {
        return $query->where('event_id', $eventId)->where('is_active', true)
            ->where('expired_at', '>', now());
    }

    public function scopeForEvent($query, int $eventId)
    {
        return $query->where('event_id', $eventId);
    }
}
