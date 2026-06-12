<?php

namespace Tests\Feature\Api;

use App\Models\Notifikasi;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class NotifikasiApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_mahasiswa_can_get_unread_count_and_mark_all_as_read(): void
    {
        $mahasiswa = User::factory()->mahasiswa()->create();
        $otherMahasiswa = User::factory()->mahasiswa()->create();

        Notifikasi::create([
            'user_id' => $mahasiswa->id,
            'event_id' => null,
            'pesan' => 'Notif 1',
            'status' => 'unread',
        ]);
        Notifikasi::create([
            'user_id' => $mahasiswa->id,
            'event_id' => null,
            'pesan' => 'Notif 2',
            'status' => 'unread',
        ]);
        Notifikasi::create([
            'user_id' => $mahasiswa->id,
            'event_id' => null,
            'pesan' => 'Notif 3',
            'status' => 'read',
        ]);
        Notifikasi::create([
            'user_id' => $otherMahasiswa->id,
            'event_id' => null,
            'pesan' => 'Notif user lain',
            'status' => 'unread',
        ]);

        Sanctum::actingAs($mahasiswa);

        $countResponse = $this->getJson('/api/v1/notifikasis/unread/count');
        $countResponse->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.count', 2);

        $unreadResponse = $this->getJson('/api/v1/notifikasis/unread');
        $unreadResponse->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonCount(2, 'data');

        $markAllResponse = $this->putJson('/api/v1/notifikasis/read-all');
        $markAllResponse->assertOk()
            ->assertJsonPath('status', true);

        $this->assertEquals(0, Notifikasi::where('user_id', $mahasiswa->id)->where('status', 'unread')->count());
        $this->assertEquals(1, Notifikasi::where('user_id', $otherMahasiswa->id)->where('status', 'unread')->count());
    }
}
