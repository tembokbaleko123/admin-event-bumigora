@extends('layouts.admin')
@section('title', 'Detail Event')
@section('page-title', 'Detail Event')
@section('page-subtitle', $event->judul)

@section('content')
<div class="row">
    <div class="col-lg-8 mx-auto">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="bi bi-info-circle me-2 text-primary"></i> Informasi Event</span>
                <div class="d-flex gap-2">
                    <a href="{{ route('admin.events.edit', $event->id) }}" class="btn btn-warning btn-sm"><i class="bi bi-pencil"></i> Edit</a>
                    <a href="{{ route('admin.events.index') }}" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-left"></i> Kembali</a>
                </div>
            </div>
            <div class="card-body">
                <div class="mb-4"><h5 class="text-muted mb-1" style="font-size:13px">JUDUL</h5><h4 class="fw-bold">{{ $event->judul }}</h4></div>
                <div class="row mb-4">
                    <div class="col-md-4"><h5 class="text-muted mb-1" style="font-size:13px">TANGGAL</h5><p class="fw-semibold"><i class="bi bi-calendar me-1"></i> {{ $event->tanggal->format('d F Y') }}</p></div>
                    <div class="col-md-4"><h5 class="text-muted mb-1" style="font-size:13px">LOKASI</h5><p class="fw-semibold"><i class="bi bi-geo-alt me-1"></i> {{ $event->lokasi }}</p></div>
                    <div class="col-md-4"><h5 class="text-muted mb-1" style="font-size:13px">DIBUAT OLEH</h5><p class="fw-semibold"><i class="bi bi-person me-1"></i> {{ $event->creator->nama ?? '-' }}</p></div>
                </div>
                @if($event->deskripsi)
                <div><h5 class="text-muted mb-1" style="font-size:13px">DESKRIPSI</h5><p style="white-space:pre-wrap">{{ $event->deskripsi }}</p></div>
                @endif
            </div>
            <div class="card-footer text-muted">
                <small>Dibuat: {{ $event->created_at->format('d M Y H:i') }} | Diupdate: {{ $event->updated_at->format('d M Y H:i') }}</small>
            </div>
        </div>
    </div>
</div>
@endsection
