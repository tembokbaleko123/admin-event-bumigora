<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ApiValidationResponseTest extends TestCase
{
    use RefreshDatabase;

    public function test_event_create_validation_uses_consistent_api_error_format(): void
    {
        $dosen = User::factory()->dosen()->create();
        Sanctum::actingAs($dosen);

        $response = $this->postJson('/api/events', []);

        $response->assertStatus(422)
            ->assertJson([
                'status' => false,
                'message' => 'Validation Error',
            ])
            ->assertJsonStructure([
                'status',
                'message',
                'errors' => ['judul', 'tanggal', 'lokasi'],
            ]);
    }
}
