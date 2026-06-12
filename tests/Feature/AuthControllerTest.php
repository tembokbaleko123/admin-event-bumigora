<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AuthControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_with_valid_credentials(): void
    {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => 'password',
        ]);

        $response = $this->postJson('/api/v1/login', [
            'email' => 'test@example.com',
            'password' => 'password',
        ]);

        $response->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonStructure([
                'data' => ['user' => ['id', 'nama', 'email', 'role'], 'token', 'token_type', 'expires_at'],
            ]);

        $this->assertArrayHasKey('token', $response->json('data'));
    }

    public function test_login_with_invalid_credentials_returns_401(): void
    {
        User::factory()->create([
            'email' => 'test@example.com',
            'password' => 'password',
        ]);

        $response = $this->postJson('/api/v1/login', [
            'email' => 'test@example.com',
            'password' => 'wrong-password',
        ]);

        $response->assertStatus(401)
            ->assertJsonPath('status', false)
            ->assertJsonPath('message', 'Email atau password salah');
    }

    public function test_me_returns_authenticated_user(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/me');

        $response->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.id', $user->id)
            ->assertJsonPath('data.nama', $user->nama)
            ->assertJsonPath('data.email', $user->email);
    }

    public function test_profile_update_can_change_password_with_current_password(): void
    {
        $user = User::factory()->create([
            'password' => 'old-password',
        ]);
        Sanctum::actingAs($user);

        $response = $this->putJson('/api/v1/profile', [
            'nama' => 'Nama Baru',
            'current_password' => 'old-password',
            'password' => 'new-password',
            'password_confirmation' => 'new-password',
        ]);

        $response->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.nama', 'Nama Baru');

        $this->assertTrue(Hash::check('new-password', $user->fresh()->password));
    }
}
