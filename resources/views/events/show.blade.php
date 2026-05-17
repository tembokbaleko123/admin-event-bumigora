@extends('layouts.admin')
@section('title', $event->judul)
@section('page-title', $event->judul)
@section('page-subtitle', 'Detail event akademik')

@section('content')
<div class="row g-4">
    <div class="col-lg-8">
        <div class="card">
            @if($event->gambar_url)
            <img src="{{ $event->gambar_url }}" alt="{{ $event->judul }}" class="card-img-top" style="max-height:360px;object-fit:cover;">
            @endif
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="bi bi-info-circle me-2 text-primary"></i> Informasi Event</span>
                @if($canManageEvent)
                <div class="d-flex gap-2">
                    <a href="{{ route('admin.events.edit', $event->id) }}" class="btn btn-sm btn-warning"><i class="bi bi-pencil"></i></a>
                    <form action="{{ route('admin.events.destroy', $event->id) }}" method="POST" onsubmit="return confirm('Yakin ingin menghapus event ini?')">
                        @csrf @method('DELETE')
                        <button type="submit" class="btn btn-sm btn-danger"><i class="bi bi-trash"></i></button>
                    </form>
                </div>
                @endif
            </div>
            <div class="card-body">
                <div class="row mb-4">
                    <div class="col-md-6">
                        <div class="d-flex align-items-center gap-3 mb-3">
                            <div style="width:44px;height:44px;border-radius:10px;background:#eef2ff;display:flex;align-items:center;justify-content:center;font-size:20px;color:#4f46e5;"><i class="bi bi-calendar-event"></i></div>
                            <div>
                                <small class="text-muted">Tanggal</small>
                                <div class="fw-semibold">{{ $event->tanggal->format('d M Y') }}</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="d-flex align-items-center gap-3 mb-3">
                            <div style="width:44px;height:44px;border-radius:10px;background:#eef2ff;display:flex;align-items:center;justify-content:center;font-size:20px;color:#4f46e5;"><i class="bi bi-geo-alt"></i></div>
                            <div>
                                <small class="text-muted">Lokasi</small>
                                <div class="fw-semibold">{{ $event->lokasi }}</div>
                            </div>
                        </div>
                    </div>
                    @if($event->kategori)
                    <div class="col-md-6">
                        <div class="d-flex align-items-center gap-3 mb-3">
                            <div style="width:44px;height:44px;border-radius:10px;background:#eef2ff;display:flex;align-items:center;justify-content:center;font-size:20px;color:#4f46e5;"><i class="bi bi-tag"></i></div>
                            <div>
                                <small class="text-muted">Kategori</small>
                                <div><span class="badge" style="background:#eef2ff;color:#4f46e5;font-weight:600;">{{ $event->kategori }}</span></div>
                            </div>
                        </div>
                    </div>
                    @endif
                    <div class="col-md-6">
                        <div class="d-flex align-items-center gap-3 mb-3">
                            <div style="width:44px;height:44px;border-radius:10px;background:#eef2ff;display:flex;align-items:center;justify-content:center;font-size:20px;color:#4f46e5;"><i class="bi bi-person"></i></div>
                            <div>
                                <small class="text-muted">Dibuat Oleh</small>
                                <div class="fw-semibold">{{ $event->creator->nama ?? '-' }}</div>
                            </div>
                        </div>
                    </div>
                </div>
                @if($event->deskripsi)
                <hr>
                <h6 class="fw-bold mb-3">Deskripsi</h6>
                <p class="text-muted">{{ $event->deskripsi }}</p>
                @endif
            </div>
        </div>
    </div>
    <div class="col-lg-4">
        <div class="card">
            <div class="card-header"><i class="bi bi-arrow-left me-2 text-primary"></i> Navigasi</div>
            <div class="card-body">
                <a href="{{ route('admin.events.index') }}" class="btn btn-outline-primary w-100 mb-2"><i class="bi bi-list me-1"></i> Kembali ke Daftar</a>
                @if($canManageEvent)
                <a href="{{ route('admin.events.edit', $event->id) }}" class="btn btn-warning w-100 mb-2"><i class="bi bi-pencil me-1"></i> Edit Event</a>
                @endif
            </div>
        </div>
    </div>
</div>
@endsection
