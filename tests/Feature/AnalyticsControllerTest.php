<?php

namespace Tests\Feature;

use App\Enums\EventStatus;
use App\Models\Event;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AnalyticsControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_dashboard_overview_returns_admin_pending_event_count(): void
    {
        $admin = User::factory()->admin()->create();
        $dosen = User::factory()->dosen()->create();

        Event::factory()->create(['created_by' => $dosen->id, 'status' => EventStatus::Pending->value]);
        Event::factory()->create(['created_by' => $dosen->id, 'status' => EventStatus::Published->value]);

        Sanctum::actingAs($admin);

        $this->getJson('/api/v1/dashboard/overview')
            ->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.admin.pending_events', 1);
    }

    public function test_dashboard_overview_returns_lecturer_own_pending_event_count(): void
    {
        $dosen = User::factory()->dosen()->create();
        $otherDosen = User::factory()->dosen()->create();

        Event::factory()->create(['created_by' => $dosen->id, 'status' => EventStatus::Pending->value]);
        Event::factory()->create(['created_by' => $dosen->id, 'status' => EventStatus::Published->value]);
        Event::factory()->create(['created_by' => $otherDosen->id, 'status' => EventStatus::Pending->value]);

        Sanctum::actingAs($dosen);

        $this->getJson('/api/v1/dashboard/overview')
            ->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.lecturer.pending_events', 1);
    }
}
