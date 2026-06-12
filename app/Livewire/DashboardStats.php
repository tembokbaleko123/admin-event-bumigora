<?php

namespace App\Livewire;

use App\Enums\EventStatus;
use App\Models\Event;
use App\Models\User;
use Livewire\Component;

class DashboardStats extends Component
{
    public array $stats = [];
    public bool $loaded = false;

    public function loadStats()
    {
        $user = auth()->user();

        if ($user->isAdmin()) {
            $this->stats = [
                'total_users' => User::count(),
                'total_mahasiswa' => User::where('role', 'mahasiswa')->count(),
                'total_dosen' => User::where('role', 'dosen')->count(),
                'total_events' => Event::count(),
                'pending_events' => Event::where('status', EventStatus::Pending->value)->count(),
            ];
        } elseif ($user->isDosen()) {
            $this->stats = [
                'my_events' => Event::where('created_by', $user->id)->count(),
                'pending_events' => Event::where('created_by', $user->id)->where('status', EventStatus::Pending->value)->count(),
            ];
        }

        $this->loaded = true;
    }

    public function render()
    {
        return view('livewire.dashboard-stats');
    }
}
