<?php

namespace Tests\Feature;

use App\Enums\EventStatus;
use App\Enums\RegistrationStatus;
use App\Models\Event;
use App\Models\EventRegistration;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class EventControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_index_returns_paginated_events(): void
    {
        $user = User::factory()->dosen()->create();
        Event::factory()->count(15)->create(['created_by' => $user->id]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/events?per_page=5');

        $response->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonStructure([
                'data',
                'meta' => ['current_page', 'last_page', 'per_page', 'total', 'has_more'],
            ]);

        $this->assertCount(5, $response->json('data'));
        $this->assertEquals(15, $response->json('meta.total'));
    }

    public function test_store_creates_event(): void
    {
        $user = User::factory()->dosen()->create();
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/events', [
            'judul' => 'Event Baru',
            'tanggal' => now()->addDays(3)->toDateString(),
            'lokasi' => 'Lab Komputer',
            'deskripsi' => 'Deskripsi event baru',
            'kategori' => 'WORKSHOP',
            'kapasitas' => 50,
        ]);

        $response->assertCreated()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.judul', 'Event Baru')
            ->assertJsonPath('data.lokasi', 'Lab Komputer')
            ->assertJsonPath('data.status', EventStatus::Pending->value);

        $this->assertDatabaseHas('events', [
            'judul' => 'Event Baru',
            'created_by' => $user->id,
            'status' => EventStatus::Pending->value,
        ]);
    }

    public function test_update_updates_event(): void
    {
        $user = User::factory()->dosen()->create();
        $event = Event::factory()->create([
            'judul' => 'Judul Lama',
            'tanggal' => now()->addDays(5),
            'lokasi' => 'Ruang A',
            'created_by' => $user->id,
        ]);

        Sanctum::actingAs($user);

        $response = $this->putJson("/api/v1/events/{$event->id}", [
            'judul' => 'Judul Baru',
            'lokasi' => 'Ruang B',
        ]);

        $response->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.judul', 'Judul Baru')
            ->assertJsonPath('data.lokasi', 'Ruang B');

        $this->assertDatabaseHas('events', [
            'id' => $event->id,
            'judul' => 'Judul Baru',
            'lokasi' => 'Ruang B',
        ]);
    }

    public function test_destroy_deletes_event(): void
    {
        $user = User::factory()->dosen()->create();
        $event = Event::factory()->create([
            'judul' => 'Event Akan Dihapus',
            'tanggal' => now()->addDays(7),
            'created_by' => $user->id,
        ]);

        Sanctum::actingAs($user);

        $response = $this->deleteJson("/api/v1/events/{$event->id}");

        $response->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('message', 'Event "Event Akan Dihapus" berhasil dihapus');

        $this->assertSoftDeleted($event);
    }

    public function test_admin_can_approve_and_reject_pending_events(): void
    {
        $admin = User::factory()->admin()->create();
        $dosen = User::factory()->dosen()->create();

        $eventToApprove = Event::factory()->create([
            'created_by' => $dosen->id,
            'status' => EventStatus::Pending->value,
        ]);
        $eventToReject = Event::factory()->create([
            'created_by' => $dosen->id,
            'status' => EventStatus::Pending->value,
        ]);

        Sanctum::actingAs($admin);

        $this->putJson("/api/v1/events/{$eventToApprove->id}/approve")
            ->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.status', EventStatus::Published->value);

        $this->putJson("/api/v1/events/{$eventToReject->id}/reject")
            ->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.status', EventStatus::Rejected->value);

        $this->assertDatabaseHas('events', ['id' => $eventToApprove->id, 'status' => EventStatus::Published->value]);
        $this->assertDatabaseHas('events', ['id' => $eventToReject->id, 'status' => EventStatus::Rejected->value]);
    }

    public function test_mahasiswa_only_sees_published_events(): void
    {
        $mahasiswa = User::factory()->mahasiswa()->create();
        $dosen = User::factory()->dosen()->create();

        Event::factory()->create([
            'judul' => 'Published Event',
            'created_by' => $dosen->id,
            'status' => EventStatus::Published->value,
        ]);
        Event::factory()->create([
            'judul' => 'Pending Event',
            'created_by' => $dosen->id,
            'status' => EventStatus::Pending->value,
        ]);

        Sanctum::actingAs($mahasiswa);

        $response = $this->getJson('/api/v1/events?per_page=10');

        $response->assertOk()->assertJsonPath('status', true);

        $titles = collect($response->json('data'))->pluck('judul');
        $this->assertTrue($titles->contains('Published Event'));
        $this->assertFalse($titles->contains('Pending Event'));
    }

    public function test_mahasiswa_can_load_my_registered_events(): void
    {
        $mahasiswa = User::factory()->mahasiswa()->create();
        $event = Event::factory()->create(['status' => EventStatus::Published->value]);

        EventRegistration::factory()->create([
            'event_id' => $event->id,
            'user_id' => $mahasiswa->id,
            'status' => RegistrationStatus::Registered->value,
        ]);

        Sanctum::actingAs($mahasiswa);

        $this->getJson('/api/v1/users/me/events')
            ->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.0.event.id', $event->id)
            ->assertJsonPath('data.0.status', RegistrationStatus::Registered->value);
    }
}
