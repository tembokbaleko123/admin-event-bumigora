<?php

namespace Tests\Feature\Api;

use App\Models\Event;
use App\Models\Informasi;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MediaUploadFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_event_api_can_upload_image(): void
    {
        Storage::persistentFake('public');
        $dosen = User::factory()->dosen()->create();
        Sanctum::actingAs($dosen);

        $createResponse = $this->post('/api/events', [
            'judul' => 'Event Gambar',
            'tanggal' => now()->addDay()->toDateString(),
            'lokasi' => 'Lab A',
            'deskripsi' => 'Deskripsi event',
            'gambar' => $this->fakePng('event.png'),
        ], [
            'Accept' => 'application/json',
        ]);

        $createResponse->assertCreated()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.gambar_url', fn ($url) => is_string($url) && $url !== '');

        /** @var Event $event */
        $event = Event::query()->latest('id')->firstOrFail();
        $this->assertNotNull($event->gambar);
        Storage::disk('public')->assertExists($event->gambar);
    }

    public function test_event_api_can_remove_existing_image(): void
    {
        Storage::persistentFake('public');
        $dosen = User::factory()->dosen()->create();
        Sanctum::actingAs($dosen);

        $existingPath = 'events/existing-event.png';
        Storage::disk('public')->put($existingPath, 'dummy-image-content');

        $event = Event::create([
            'judul' => 'Event Lama',
            'tanggal' => now()->addDays(2)->toDateString(),
            'lokasi' => 'Lab B',
            'deskripsi' => 'Deskripsi lama',
            'gambar' => $existingPath,
            'created_by' => $dosen->id,
        ]);

        $removeResponse = $this->put("/api/events/{$event->id}", [
            'hapus_gambar' => 1,
        ], [
            'Accept' => 'application/json',
        ]);

        $removeResponse->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.gambar', null)
            ->assertJsonPath('data.gambar_url', null);

        $this->assertDatabaseHas('events', [
            'id' => $event->id,
            'gambar' => null,
        ]);
    }

    public function test_informasi_api_can_upload_image(): void
    {
        Storage::persistentFake('public');
        $admin = User::factory()->admin()->create();
        Sanctum::actingAs($admin);

        $createResponse = $this->post('/api/informasis', [
            'judul' => 'Info Gambar',
            'isi' => 'Isi informasi',
            'tanggal' => now()->toDateString(),
            'gambar' => $this->fakePng('informasi.png'),
        ], [
            'Accept' => 'application/json',
        ]);

        $createResponse->assertCreated()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.gambar_url', fn ($url) => is_string($url) && $url !== '');

        /** @var Informasi $informasi */
        $informasi = Informasi::query()->latest('id')->firstOrFail();
        $this->assertNotNull($informasi->gambar);
        Storage::disk('public')->assertExists($informasi->gambar);
    }

    public function test_informasi_api_can_remove_existing_image(): void
    {
        Storage::persistentFake('public');
        $admin = User::factory()->admin()->create();
        Sanctum::actingAs($admin);

        $existingPath = 'informasis/existing-informasi.png';
        Storage::disk('public')->put($existingPath, 'dummy-image-content');

        $informasi = Informasi::create([
            'judul' => 'Informasi Lama',
            'isi' => 'Isi lama',
            'tanggal' => now()->toDateString(),
            'gambar' => $existingPath,
            'dibuat_oleh' => $admin->id,
        ]);

        $removeResponse = $this->put("/api/informasis/{$informasi->id}", [
            'hapus_gambar' => 1,
        ], [
            'Accept' => 'application/json',
        ]);

        $removeResponse->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.gambar', null)
            ->assertJsonPath('data.gambar_url', null);

        $this->assertDatabaseHas('informasis', [
            'id' => $informasi->id,
            'gambar' => null,
        ]);
    }

    private function fakePng(string $filename): UploadedFile
    {
        // 1x1 transparent PNG
        $pngContent = base64_decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO6p8ocAAAAASUVORK5CYII='
        );

        return UploadedFile::fake()->createWithContent($filename, $pngContent);
    }
}
