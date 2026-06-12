<?php

namespace Tests\Feature\Api;

use App\Models\Event;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class UserDeleteProtectionTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_cannot_delete_user_that_owns_event(): void
    {
        $admin = User::factory()->admin()->create();
        $dosen = User::factory()->dosen()->create();

        Event::create([
            'judul' => 'Event Milik Dosen',
            'tanggal' => now()->addDay()->toDateTimeString(),
            'lokasi' => 'Aula',
            'created_by' => $dosen->id,
        ]);

        Sanctum::actingAs($admin);

        $this->deleteJson("/api/v1/users/{$dosen->id}")
            ->assertStatus(403)
            ->assertJson([
                'status' => false,
            ]);

        $this->assertDatabaseHas('users', ['id' => $dosen->id]);
        $this->assertDatabaseHas('events', ['created_by' => $dosen->id]);
    }
}
