<?php

namespace Database\Factories;

use App\Models\Notifikasi;
use App\Models\Event;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class NotifikasiFactory extends Factory
{
    protected $model = Notifikasi::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'event_id' => Event::factory(),
            'pesan' => fake()->paragraph(),
            'status' => 'unread',
        ];
    }

    public function read(): static
    {
        return $this->state(fn (array $attributes) => ['status' => 'read']);
    }
}
