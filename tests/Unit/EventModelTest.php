<?php

namespace Tests\Unit;

use App\Enums\EventStatus;
use App\Enums\RegistrationStatus;
use App\Models\Event;
use App\Models\EventRegistration;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class EventModelTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_register_returns_true_when_event_is_published_and_in_future_and_has_quota(): void
    {
        $event = Event::factory()->create([
            'status' => EventStatus::Published->value,
            'tanggal' => now()->addDays(3),
            'kapasitas' => 100,
        ]);

        $this->assertTrue($event->canRegister());
    }

    public function test_can_register_returns_false_when_event_is_not_published(): void
    {
        $event = Event::factory()->create([
            'status' => EventStatus::Draft->value,
            'tanggal' => now()->addDays(3),
            'kapasitas' => 100,
        ]);

        $this->assertFalse($event->canRegister());
    }

    public function test_can_register_returns_false_when_event_date_is_in_the_past(): void
    {
        $event = Event::factory()->create([
            'status' => EventStatus::Published->value,
            'tanggal' => now()->subDay(),
            'kapasitas' => 100,
        ]);

        $this->assertFalse($event->canRegister());
    }

    public function test_can_register_returns_false_when_quota_is_full(): void
    {
        $event = Event::factory()->create([
            'status' => EventStatus::Published->value,
            'tanggal' => now()->addDays(3),
            'kapasitas' => 2,
        ]);

        EventRegistration::factory()->count(2)->create([
            'event_id' => $event->id,
            'status' => RegistrationStatus::Registered->value,
        ]);

        $this->assertFalse($event->canRegister());
    }

    public function test_get_sisa_kuota_attribute_returns_null_when_no_kapasitas(): void
    {
        $event = Event::factory()->create([
            'kapasitas' => null,
        ]);

        $this->assertNull($event->sisa_kuota);
    }

    public function test_get_sisa_kuota_attribute_returns_remaining_quota(): void
    {
        $event = Event::factory()->create([
            'kapasitas' => 10,
        ]);

        EventRegistration::factory()->count(3)->create([
            'event_id' => $event->id,
            'status' => RegistrationStatus::Registered->value,
        ]);

        $this->assertEquals(7, $event->sisa_kuota);
    }

    public function test_get_sisa_kuota_attribute_returns_zero_when_over_quota(): void
    {
        $event = Event::factory()->create([
            'kapasitas' => 5,
        ]);

        EventRegistration::factory()->count(7)->create([
            'event_id' => $event->id,
            'status' => RegistrationStatus::Registered->value,
        ]);

        $this->assertEquals(0, $event->sisa_kuota);
    }

    public function test_active_registrations_relationship_only_returns_registered_status(): void
    {
        $event = Event::factory()->create();

        EventRegistration::factory()->create([
            'event_id' => $event->id,
            'status' => RegistrationStatus::Registered->value,
        ]);

        EventRegistration::factory()->create([
            'event_id' => $event->id,
            'status' => RegistrationStatus::Cancelled->value,
        ]);

        EventRegistration::factory()->create([
            'event_id' => $event->id,
            'status' => RegistrationStatus::Attended->value,
        ]);

        $this->assertCount(1, $event->activeRegistrations);
    }
}
