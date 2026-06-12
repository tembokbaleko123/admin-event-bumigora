<?php

namespace Database\Factories;

use App\Enums\RegistrationStatus;
use App\Models\EventRegistration;
use App\Models\Event;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class EventRegistrationFactory extends Factory
{
    protected $model = EventRegistration::class;

    public function definition(): array
    {
        return [
            'event_id' => Event::factory(),
            'user_id' => User::factory(),
            'status' => RegistrationStatus::Registered->value,
            'registered_at' => now(),
        ];
    }

    public function attended(): static
    {
        return $this->state(fn (array $attributes) => ['status' => RegistrationStatus::Attended->value]);
    }

    public function cancelled(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => RegistrationStatus::Cancelled->value,
            'cancelled_at' => now(),
        ]);
    }
}
