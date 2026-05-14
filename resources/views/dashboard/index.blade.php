@extends('layouts.admin')
@section('title', 'Dashboard')
@section('page-title', 'Dashboard')
@section('page-subtitle', 'Overview sistem informasi akademik')

@section('content')
<!-- Stat Cards Row -->
<div class="row g-4 mb-4">
    <div class="col-xl-3 col-md-6">
        <div class="stat-card">
            <div class="stat-icon bg-soft-primary"><i class="bi bi-people-fill text-primary"></i></div>
            <div class="stat-value">{{ $totalUsers }}</div>
            <div class="stat-label">Total Users</div>
            <div class="stat-change up"><i class="bi bi-arrow-up-short"></i> {{ $totalMahasiswa }} Mahasiswa</div>
            <div class="stat-bg-icon"><i class="bi bi-people-fill"></i></div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="stat-card">
            <div class="stat-icon bg-soft-success"><i class="bi bi-mortarboard-fill text-success"></i></div>
            <div class="stat-value">{{ $totalDosen }}</div>
            <div class="stat-label">Total Dosen</div>
            <div class="stat-change up"><i class="bi bi-arrow-up-short"></i> Aktif</div>
            <div class="stat-bg-icon"><i class="bi bi-mortarboard-fill"></i></div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="stat-card">
            <div class="stat-icon bg-soft-warning"><i class="bi bi-calendar-event-fill text-warning"></i></div>
            <div class="stat-value">{{ $totalEvents }}</div>
            <div class="stat-label">Total Events</div>
            <div class="stat-change up"><i class="bi bi-arrow-up-short"></i> Akademik</div>
            <div class="stat-bg-icon"><i class="bi bi-calendar-event-fill"></i></div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="stat-card">
            <div class="stat-icon bg-soft-info"><i class="bi bi-megaphone-fill text-info"></i></div>
            <div class="stat-value">{{ $totalInformasi }}</div>
            <div class="stat-label">Total Informasi</div>
            <div class="stat-change up"><i class="bi bi-arrow-up-short"></i> Publikasi</div>
            <div class="stat-bg-icon"><i class="bi bi-megaphone-fill"></i></div>
        </div>
    </div>
</div>

<!-- Charts Row -->
<div class="row g-4 mb-4">
    <div class="col-xl-8">
        <div class="card"><div class="card-header"><i class="bi bi-graph-up me-2 text-primary"></i> Event per Bulan (6 Bulan Terakhir)</div>
        <div class="card-body"><canvas id="eventsChart" height="90"></canvas></div></div>
    </div>
    <div class="col-xl-4">
        <div class="card"><div class="card-header"><i class="bi bi-pie-chart-fill me-2 text-primary"></i> Komposisi User</div>
        <div class="card-body"><canvas id="usersChart" height="180"></canvas></div></div>
    </div>
</div>

<!-- Recent Events & Stats Row -->
<div class="row g-4">
    <div class="col-xl-8">
        <div class="card"><div class="card-header d-flex justify-content-between align-items-center">
            <span><i class="bi bi-clock-history me-2 text-primary"></i> Event Terbaru</span>
            <a href="{{ route('admin.events.index') }}" class="btn btn-sm btn-outline-primary">Lihat Semua</a>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table">
                    <thead><tr><th>Judul</th><th>Tanggal</th><th>Lokasi</th><th>Dibuat oleh</th></tr></thead>
                    <tbody>
                        @forelse($recentEvents as $event)
                        <tr>
                            <td class="fw-semibold">{{ $event->judul }}</td>
                            <td>{{ $event->tanggal->format('d M Y') }}</td>
                            <td>{{ $event->lokasi }}</td>
                            <td>{{ $event->creator->nama ?? '-' }}</td>
                        </tr>
                        @empty
                        <tr><td colspan="4" class="text-center text-muted py-4">Belum ada event</td></tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div></div>
    </div>
    <div class="col-xl-4">
        <div class="card"><div class="card-header"><i class="bi bi-bell-fill me-2 text-primary"></i> Notifikasi</div>
        <div class="card-body">
            <div class="d-flex align-items-center gap-3 mb-3 p-3 bg-soft-primary rounded-3">
                <div><i class="bi bi-envelope-open-fill fs-3 text-primary"></i></div>
                <div>
                    <div class="fw-bold fs-4">{{ $totalNotifikasi }}</div>
                    <div class="text-muted" style="font-size:13px">Total Notifikasi</div>
                </div>
            </div>
            <div class="d-flex align-items-center gap-3 p-3 bg-soft-danger rounded-3">
                <div><i class="bi bi-exclamation-circle-fill fs-3 text-danger"></i></div>
                <div>
                    <div class="fw-bold fs-4">{{ $unreadNotifikasi }}</div>
                    <div class="text-muted" style="font-size:13px">Belum Dibaca</div>
                </div>
            </div>
        </div></div>
    </div>
</div>
@endsection

@push('scripts')
<script>
const months = @json($eventsPerMonth->pluck('month'));
const totals = @json($eventsPerMonth->pluck('total'));

new Chart(document.getElementById('eventsChart'), {
    type: 'line',
    data: {
        labels: months,
        datasets: [{
            label: 'Event',
            data: totals,
            borderColor: '#4f46e5',
            backgroundColor: 'rgba(79,70,229,.08)',
            fill: true,
            tension: .4,
            pointBackgroundColor: '#4f46e5',
            pointBorderColor: '#fff',
            pointBorderWidth: 2,
            pointRadius: 5,
            borderWidth: 3
        }]
    },
    options: {
        responsive: true,
        plugins: { legend: { display: false } },
        scales: {
            y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,.04)' } },
            x: { grid: { display: false } }
        }
    }
});

new Chart(document.getElementById('usersChart'), {
    type: 'doughnut',
    data: {
        labels: ['Mahasiswa', 'Dosen', 'Admin'],
        datasets: [{
            data: [{{ $totalMahasiswa }}, {{ $totalDosen }}, {{ $totalUsers - $totalMahasiswa - $totalDosen }}],
            backgroundColor: ['#10b981', '#3b82f6', '#4f46e5'],
            borderWidth: 3,
            borderColor: '#fff'
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: { position: 'bottom', labels: { padding: 16, usePointStyle: true, font: { size: 12 } } }
        },
        cutout: '70%'
    }
});
</script>
@endpush
