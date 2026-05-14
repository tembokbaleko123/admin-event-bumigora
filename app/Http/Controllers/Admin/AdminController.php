<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\Informasi;
use App\Models\Notifikasi;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
{
    /**
     * Tampilkan dashboard admin
     */
    public function index()
    {
        $totalUsers = User::count();
        $totalMahasiswa = User::where('role', 'mahasiswa')->count();
        $totalDosen = User::where('role', 'dosen')->count();
        $totalEvents = Event::count();
        $totalInformasi = Informasi::count();
        $totalNotifikasi = Notifikasi::count();
        $unreadNotifikasi = Notifikasi::unread()->count();

        // Event terbaru
        $recentEvents = Event::with('creator:id,nama')
            ->orderBy('created_at', 'desc')
            ->take(5)
            ->get();

        // User terdaftar per bulan (6 bulan terakhir)
        $userRegistrations = User::select(
            DB::raw("DATE_FORMAT(created_at, '%Y-%m') as month"),
            DB::raw('COUNT(*) as total')
        )
            ->where('created_at', '>=', now()->subMonths(6))
            ->groupBy('month')
            ->orderBy('month')
            ->get();

        // Event per bulan (6 bulan terakhir)
        $eventsPerMonth = Event::select(
            DB::raw("DATE_FORMAT(tanggal, '%Y-%m') as month"),
            DB::raw('COUNT(*) as total')
        )
            ->where('created_at', '>=', now()->subMonths(6))
            ->groupBy('month')
            ->orderBy('month')
            ->get();

        return view('dashboard.index', compact(
            'totalUsers',
            'totalMahasiswa',
            'totalDosen',
            'totalEvents',
            'totalInformasi',
            'totalNotifikasi',
            'unreadNotifikasi',
            'recentEvents',
            'userRegistrations',
            'eventsPerMonth'
        ));
    }
}
