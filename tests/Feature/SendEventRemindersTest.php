<?php

namespace Tests\Feature;

use App\Enums\EventStatus;
use App\Enums\RegistrationStatus;
use App\Models\Event;
use App\Models\EventRegistration;
use App\Models\Notifikasi;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SendEventRemindersTest extends TestCase
{
    use RefreshDatabase;

    public function test_reminders_are_sent_for_tomorrows_events(): void
    {
        $user = User::factory()->create();
        $event = Event::factory()->create([
            'tanggal' => now()->addDay()->setHour(10)->setMinute(0)->setSecond(0),
            'status' => EventStatus::Published->value,
        ]);

        EventRegistration::factory()->create([
            'event_id' => $event->id,
            'user_id' => $user->id,
            'status' => RegistrationStatus::Registered->value,
        ]);

        $this->artisan('notifications:send-reminders')
            ->assertSuccessful()
            ->expectsOutputToContain('Sent 1 reminder notifications');

        $this->assertDatabaseHas('notifikasis', [
            'user_id' => $user->id,
            'event_id' => $event->id,
            'status' => 'unread',
        ]);
    }

    public function test_duplicate_reminders_are_not_sent(): void
    {
        $user = User::factory()->create();
        $event = Event::factory()->create([
            'tanggal' => now()->addDay()->setHour(10)->setMinute(0)->setSecond(0),
            'status' => EventStatus::Published->value,
        ]);

        EventRegistration::factory()->create([
            'event_id' => $event->id,
            'user_id' => $user->id,
            'status' => RegistrationStatus::Registered->value,
        ]);

        Notifikasi::factory()->create([
            'user_id' => $user->id,
            'event_id' => $event->id,
            'pesan' => 'H-1 Event',
            'created_at' => now(),
        ]);

        $this->artisan('notifications:send-reminders')
            ->assertSuccessful()
            ->expectsOutputToContain('Sent 0 reminder notifications');

        $this->assertDatabaseCount('notifikasis', 1);
    }
}
