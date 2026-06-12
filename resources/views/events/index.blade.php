@extends('layouts.admin')
@section('title', 'Events')
@section('page-title', 'Events Akademik')
@section('page-subtitle', auth()->user()->isDosen() ? 'Lihat semua event, kelola event yang Anda buat' : 'Kelola semua event akademik')

@section('content')
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span><i class="bi bi-calendar-event me-2 text-primary"></i> Daftar Event</span>
        <div class="d-flex gap-2">
            <a href="{{ route('admin.events.calendar') }}" class="btn btn-outline-primary btn-sm"><i class="bi bi-calendar3 me-1"></i> Kalender</a>
            <a href="{{ route('admin.events.create') }}" class="btn btn-primary btn-sm"><i class="bi bi-plus-lg me-1"></i> Tambah Event</a>
        </div>
    </div>
    <div class="card-body">
        <!-- Search & Filter -->
        <form method="GET" action="{{ route('admin.events.index') }}" class="row g-2 mb-3">
            <div class="col-md-3">
                <div class="input-group">
                    <span class="input-group-text bg-white"><i class="bi bi-search text-muted"></i></span>
                    <input type="text" name="search" class="form-control" placeholder="Cari event..." value="{{ request('search') }}">
                </div>
            </div>
            <div class="col-md-2">
                <select name="kategori" class="form-select">
                    <option value="">Semua Kategori</option>
                    @foreach($kategoriList as $kategori)
                    <option value="{{ $kategori }}" {{ request('kategori') == $kategori ? 'selected' : '' }}>{{ $kategori }}</option>
                    @endforeach
                </select>
            </div>
            <div class="col-md-2">
                <input type="date" name="tanggal_mulai" class="form-control" value="{{ request('tanggal_mulai') }}" title="Tanggal mulai">
            </div>
            <div class="col-md-2">
                <input type="date" name="tanggal_selesai" class="form-control" value="{{ request('tanggal_selesai') }}" title="Tanggal selesai">
            </div>
            <div class="col-md-3 d-flex gap-2">
                <button type="submit" class="btn btn-primary"><i class="bi bi-search me-1"></i> Filter</button>
                @if(request()->anyFilled(['search', 'kategori', 'tanggal_mulai', 'tanggal_selesai']))
                <a href="{{ route('admin.events.index') }}" class="btn btn-outline-secondary"><i class="bi bi-x-lg"></i></a>
                @endif
            </div>
        </form>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table">
                <thead><tr><th>#</th><th>Judul</th><th>Kategori</th><th>Tanggal</th><th>Lokasi</th><th>Dibuat Oleh</th><th class="text-end">Aksi</th></tr></thead>
                <tbody>
                    @forelse($events as $event)
                    @php
                        $canManageEvent = auth()->user()->isAdmin() || $event->created_by === auth()->id();
                    @endphp
                    <tr>
                        <td class="text-muted">{{ ($events->currentPage() - 1) * $events->perPage() + $loop->iteration }}</td>
                        <td class="fw-semibold">
                            @if($event->gambar_url)
                            <img src="{{ $event->gambar_url }}" alt="" style="width:32px;height:32px;border-radius:6px;object-fit:cover;margin-right:8px;">
                            @endif
                            {{ $event->judul }}
                        </td>
                        <td>
                            @if($event->kategori)
                            <span class="badge" style="background:#eef2ff;color:#4f46e5;font-weight:500;">{{ $event->kategori }}</span>
                            @else
                            <span class="text-muted">-</span>
                            @endif
                        </td>
                        <td>{{ $event->tanggal->format('d M Y H:i') }}</td>
                        <td>{{ $event->lokasi }}</td>
                        <td><span class="badge-role {{ $event->creator->role ?? 'admin' }}">{{ $event->creator->nama ?? '-' }}</span></td>
                        <td class="text-end">
                            <a href="{{ route('admin.events.show', $event->id) }}" class="btn btn-sm btn-outline-primary" title="Detail"><i class="bi bi-eye"></i></a>
                            @if($canManageEvent)
                                <a href="{{ route('admin.events.edit', $event->id) }}" class="btn btn-sm btn-outline-warning" title="Edit"><i class="bi bi-pencil"></i></a>
                                <form action="{{ route('admin.events.destroy', $event->id) }}" method="POST" class="d-inline" data-confirm="Yakin ingin menghapus event ini?">
                                    @csrf @method('DELETE')
                                    <button type="submit" class="btn btn-sm btn-outline-danger" title="Hapus"><i class="bi bi-trash"></i></button>
                                </form>
                            @endif
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="7" class="text-center text-muted py-5">
                            <i class="bi bi-inbox fs-3 d-block mb-2"></i>
                            {{ request()->anyFilled(['search', 'kategori', 'tanggal_mulai', 'tanggal_selesai']) ? 'Tidak ada event yang sesuai filter' : 'Belum ada event' }}
                        </td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
    @if($events->hasPages())
    <div class="card-footer d-flex justify-content-center">{{ $events->links() }}</div>
    @endif
</div>
@endsection
