<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ApiErrorContractTest extends TestCase
{
    use RefreshDatabase;

    public function test_api_returns_standard_401_when_unauthenticated(): void
    {
        $response = $this->getJson('/api/v1/me');

        $response->assertStatus(401)
            ->assertJson([
                'status' => false,
                'message' => 'Unauthorized - Silakan login terlebih dahulu',
            ]);
    }

    public function test_api_returns_standard_403_when_role_forbidden(): void
    {
        $dosen = User::factory()->dosen()->create();
        Sanctum::actingAs($dosen);

        $response = $this->getJson('/api/v1/users');

        $response->assertStatus(403)
            ->assertJson([
                'status' => false,
                'message' => 'Forbidden - Anda tidak memiliki akses untuk fitur ini',
            ]);
    }

    public function test_api_returns_standard_404_for_unknown_route(): void
    {
        $response = $this->getJson('/api/v1/route-tidak-ada');

        $response->assertStatus(404)
            ->assertJson([
                'status' => false,
                'message' => 'Resource tidak ditemukan',
            ]);
    }
}
