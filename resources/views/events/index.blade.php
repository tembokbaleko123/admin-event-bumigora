@extends('layouts.admin')
@section('title', 'Events')
@section('page-title', 'Events Akademik')
@section('page-subtitle', 'Kelola semua event akademik')

@section('content')
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span><i class="bi bi-calendar-event me-2 text-primary"></i> Daftar Event</span>
        <a href="{{ route('admin.events.create') }}" class="btn btn-primary btn-sm"><i class="bi bi-plus-lg me-1"></i> Tambah Event</a>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table">
                <thead><tr><th>#</th><th>Judul</th><th>Tanggal</th><th>Lokasi</th><th>Dibuat Oleh</th><th class="text-end">Aksi</th></tr></thead>
                <tbody>
                    @forelse($events as $event)
                    <tr>
                        <td class="text-muted">{{ $loop->iteration }}</td>
                        <td class="fw-semibold">{{ $event->judul }}</td>
                        <td>{{ $event->tanggal->format('d M Y') }}</td>
                        <td>{{ $event->lokasi }}</td>
                        <td><span class="badge-role {{ $event->creator->role ?? 'admin' }}">{{ $event->creator->nama ?? '-' }}</span></td>
                        <td class="text-end">
                            <a href="{{ route('admin.events.show', $event->id) }}" class="btn btn-sm btn-outline-primary" title="Detail"><i class="bi bi-eye"></i></a>
                            <a href="{{ route('admin.events.edit', $event->id) }}" class="btn btn-sm btn-outline-warning" title="Edit"><i class="bi bi-pencil"></i></a>
                            <form action="{{ route('admin.events.destroy', $event->id) }}" method="POST" class="d-inline" onsubmit="return confirm('Yakin ingin menghapus event ini?')">
                                @csrf @method('DELETE')
                                <button type="submit" class="btn btn-sm btn-outline-danger" title="Hapus"><i class="bi bi-trash"></i></button>
                            </form>
                        </td>
                    </tr>
                    @empty
                    <tr><td colspan="6" class="text-center text-muted py-5"><i class="bi bi-inbox fs-3 d-block mb-2"></i>Belum ada event</td></tr>
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
