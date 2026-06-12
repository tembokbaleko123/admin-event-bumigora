<?php

namespace App\Models;

use App\Enums\RegistrationStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EventRegistration extends Model
{
    use HasFactory;

    protected $fillable = [
        'event_id',
        'user_id',
        'status',
        'registered_at',
        'cancelled_at',
    ];

    protected function casts(): array
    {
        return [
            'registered_at' => 'datetime',
            'cancelled_at' => 'datetime',
        ];
    }

    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function scopeRegistered($query)
    {
        return $query->where('status', RegistrationStatus::Registered->value);
    }

    public function isRegistered(): bool
    {
        return $this->status === RegistrationStatus::Registered->value;
    }

    public function isCancelled(): bool
    {
        return $this->status === RegistrationStatus::Cancelled->value;
    }

    public function isAttended(): bool
    {
        return $this->status === RegistrationStatus::Attended->value;
    }

    public function isAbsent(): bool
    {
        return $this->status === RegistrationStatus::Absent->value;
    }
}