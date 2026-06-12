<?php

namespace Database\Factories;

use App\Enums\AttendanceStatus;
use App\Models\Attendance;
use App\Models\Event;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class AttendanceFactory extends Factory
{
    protected $model = Attendance::class;

    public function definition(): array
    {
        return [
            'event_id' => Event::factory(),
            'user_id' => User::factory(),
            'status' => AttendanceStatus::Valid->value,
            'scanned_at' => now(),
        ];
    }

    public function late(): static
    {
        return $this->state(fn (array $attributes) => ['status' => AttendanceStatus::Late->value]);
    }
}
