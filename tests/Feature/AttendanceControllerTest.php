<?php

namespace Tests\Feature;

use App\Enums\AttendanceStatus;
use App\Enums\EventStatus;
use App\Enums\RegistrationStatus;
use App\Models\Attendance;
use App\Models\Event;
use App\Models\EventRegistration;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AttendanceControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_dosen_can_mark_manual_attendance_and_absent(): void
    {
        $dosen = User::factory()->dosen()->create();
        $mahasiswa = User::factory()->mahasiswa()->create();
        $event = Event::factory()->create([
            'created_by' => $dosen->id,
            'status' => EventStatus::Published->value,
        ]);
        $registration = EventRegistration::factory()->create([
            'event_id' => $event->id,
            'user_id' => $mahasiswa->id,
            'status' => RegistrationStatus::Registered->value,
        ]);

        Sanctum::actingAs($dosen);

        $this->postJson("/api/v1/events/{$event->id}/attendance/manual", [
            'user_id' => $mahasiswa->id,
            'status' => AttendanceStatus::Valid->value,
        ])->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.registration.status', RegistrationStatus::Attended->value)
            ->assertJsonPath('data.attendance.status', AttendanceStatus::Valid->value);

        $this->assertDatabaseHas('attendances', [
            'event_id' => $event->id,
            'user_id' => $mahasiswa->id,
            'registration_id' => $registration->id,
            'status' => AttendanceStatus::Valid->value,
        ]);

        $this->postJson("/api/v1/events/{$event->id}/attendance/manual", [
            'user_id' => $mahasiswa->id,
            'status' => RegistrationStatus::Absent->value,
        ])->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.registration.status', RegistrationStatus::Absent->value)
            ->assertJsonPath('data.attendance', null);

        $this->assertEquals(0, Attendance::where('event_id', $event->id)->where('user_id', $mahasiswa->id)->count());
        $this->assertDatabaseHas('event_registrations', [
            'id' => $registration->id,
            'status' => RegistrationStatus::Absent->value,
        ]);
    }
}
