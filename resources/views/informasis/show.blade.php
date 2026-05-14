@extends('layouts.admin')
@section('title', 'Detail Informasi')
@section('page-title', 'Detail Informasi')
@section('page-subtitle', $informasi->judul)

@section('content')
<div class="row">
    <div class="col-lg-8 mx-auto">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="bi bi-info-circle me-2 text-primary"></i> Informasi</span>
                <div class="d-flex gap-2">
                    <a href="{{ route('admin.informasis.edit', $informasi->id) }}" class="btn btn-warning btn-sm"><i class="bi bi-pencil"></i> Edit</a>
                    <a href="{{ route('admin.informasis.index') }}" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-left"></i> Kembali</a>
                </div>
            </div>
            <div class="card-body">
                <div class="mb-3"><h5 class="text-muted mb-1" style="font-size:13px">JUDUL</h5><h4 class="fw-bold">{{ $informasi->judul }}</h4></div>
                <div class="row mb-3">
                    <div class="col-md-6"><h5 class="text-muted mb-1" style="font-size:13px">TANGGAL</h5><p class="fw-semibold"><i class="bi bi-calendar me-1"></i> {{ $informasi->tanggal->format('d F Y') }}</p></div>
                    <div class="col-md-6"><h5 class="text-muted mb-1" style="font-size:13px">DIBUAT OLEH</h5><p class="fw-semibold"><i class="bi bi-person me-1"></i> {{ $informasi->creator->nama ?? '-' }}</p></div>
                </div>
                <hr>
                <div style="white-space:pre-wrap;line-height:1.7">{{ $informasi->isi }}</div>
            </div>
            <div class="card-footer text-muted">
                <small>Dibuat: {{ $informasi->created_at->format('d M Y H:i') }} | Diupdate: {{ $informasi->updated_at->format('d M Y H:i') }}</small>
            </div>
        </div>
    </div>
</div>
@endsection
