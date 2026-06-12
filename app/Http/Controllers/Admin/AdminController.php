<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\Informasi;
use App\Models\Notifikasi;
use App\Models\User;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    /**
     * Tampilkan dashboard admin
     */
    public function index()
    {
        $user = auth()->user();
        $isAdmin = $user->isAdmin();
        $managedEvents = Event::query();

        if ($user->isDosen()) {
            $managedEvents->where('created_by', $user->id);
        }

        $totalUsers = $isAdmin ? User::count() : 0;
        $totalMahasiswa = $isAdmin ? User::where('role', UserRole::Mahasiswa->value)->count() : 0;
        $totalDosen = $isAdmin ? User::where('role', UserRole::Dosen->value)->count() : 0;
        $totalEvents = (clone $managedEvents)->count();
        $upcomingEvents = (clone $managedEvents)
            ->whereDate('tanggal', '>=', now()->toDateString())
            ->count();
        $totalInformasi = $isAdmin ? Informasi::count() : 0;

        $notifikasiQuery = Notifikasi::query();
        if ($user->isDosen()) {
            $notifikasiQuery->whereIn('event_id', function ($q) use ($managedEvents, $user) {
                $q->select('id')->from('events')->where('created_by', $user->id);
            });
        }

        $totalNotifikasi = (clone $notifikasiQuery)->count();
        $unreadNotifikasi = (clone $notifikasiQuery)->unread()->count();

        // Event terbaru
        $recentEvents = (clone $managedEvents)
            ->with('creator:id,nama')
            ->orderBy('created_at', 'desc')
            ->take(5)
            ->get();

        // Event per bulan (6 bulan terakhir)
        $eventsPerMonth = (clone $managedEvents)
            ->where('tanggal', '>=', now()->subMonths(6)->startOfMonth()->toDateString())
            ->get()
            ->groupBy(fn($e) => $e->tanggal->format('Y-m'))
            ->map(fn($items, $month) => [
                'month' => $month,
                'total' => $items->count(),
            ])
            ->values();

        return view('dashboard.index', compact(
            'isAdmin',
            'totalUsers',
            'totalMahasiswa',
            'totalDosen',
            'totalEvents',
            'upcomingEvents',
            'totalInformasi',
            'totalNotifikasi',
            'unreadNotifikasi',
            'recentEvents',
            'eventsPerMonth'
        ));
    }
}
