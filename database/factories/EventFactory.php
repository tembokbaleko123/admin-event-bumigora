<?php

namespace Database\Factories;

use App\Enums\EventStatus;
use App\Models\Event;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class EventFactory extends Factory
{
    protected $model = Event::class;

    public function definition(): array
    {
        return [
            'judul' => fake()->sentence(3),
            'tanggal' => fake()->dateTimeBetween('+1 day', '+1 month'),
            'lokasi' => fake()->address(),
            'deskripsi' => fake()->paragraph(),
            'kategori' => fake()->randomElement(['KULIAH', 'WORKSHOP', 'SEMINAR', 'MEETING', 'UKM']),
            'kapasitas' => fake()->optional(0.7)->numberBetween(10, 200),
            'status' => EventStatus::Published->value,
            'created_by' => User::factory(),
        ];
    }

    public function draft(): static
    {
        return $this->state(fn (array $attributes) => ['status' => EventStatus::Draft->value]);
    }

    public function past(): static
    {
        return $this->state(fn (array $attributes) => [
            'tanggal' => fake()->dateTimeBetween('-1 month', '-1 day'),
        ]);
    }

    public function full(): static
    {
        return $this->state(fn (array $attributes) => ['kapasitas' => 0]);
    }
}
