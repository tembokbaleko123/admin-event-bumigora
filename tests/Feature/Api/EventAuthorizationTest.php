<?php

namespace Tests\Feature\Api;

use App\Models\Event;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class EventAuthorizationTest extends TestCase
{
    use RefreshDatabase;

    public function test_dosen_cannot_update_event_created_by_other_user(): void
    {
        $owner = User::factory()->dosen()->create();
        $otherDosen = User::factory()->dosen()->create();

        $event = Event::create([
            'judul' => 'Event Awal',
            'tanggal' => now()->addDay()->toDateString(),
            'lokasi' => 'Ruang A',
            'deskripsi' => 'Deskripsi awal',
            'created_by' => $owner->id,
        ]);

        Sanctum::actingAs($otherDosen);

        $response = $this->putJson("/api/v1/events/{$event->id}", [
            'judul' => 'Diubah',
        ]);

        $response->assertStatus(403)
            ->assertJson([
                'status' => false,
            ]);

        $this->assertDatabaseHas('events', [
            'id' => $event->id,
            'judul' => 'Event Awal',
        ]);
    }

    public function test_dosen_can_update_own_event(): void
    {
        $dosen = User::factory()->dosen()->create();

        $event = Event::create([
            'judul' => 'Event Milik Saya',
            'tanggal' => now()->addDays(2)->toDateString(),
            'lokasi' => 'Ruang B',
            'deskripsi' => 'Deskripsi',
            'created_by' => $dosen->id,
        ]);

        Sanctum::actingAs($dosen);

        $response = $this->putJson("/api/v1/events/{$event->id}", [
            'judul' => 'Event Sudah Diupdate',
            'kategori' => 'WORKSHOP',
        ]);

        $response->assertOk()
            ->assertJson([
                'status' => true,
            ]);

        $this->assertDatabaseHas('events', [
            'id' => $event->id,
            'judul' => 'Event Sudah Diupdate',
            'kategori' => 'WORKSHOP',
        ]);
    }

    public function test_event_update_rejects_unknown_category(): void
    {
        $dosen = User::factory()->dosen()->create();

        $event = Event::create([
            'judul' => 'Event Kategori',
            'tanggal' => now()->addDays(2)->toDateTimeString(),
            'lokasi' => 'Ruang C',
            'deskripsi' => 'Deskripsi',
            'created_by' => $dosen->id,
        ]);

        Sanctum::actingAs($dosen);

        $this->putJson("/api/v1/events/{$event->id}", [
            'kategori' => 'LAINNYA',
        ])->assertStatus(422)
            ->assertJson([
                'status' => false,
            ]);
    }
}
