@extends('layouts.admin')
@section('title', 'Detail Informasi')
@section('page-title', 'Detail Informasi')
@section('page-subtitle', $informasi->judul)
@section('breadcrumb')
<a href="{{ route('admin.dashboard') }}">Dashboard</a>
<span class="separator">›</span>
<a href="{{ route('admin.informasis.index') }}">Informasi</a>
<span class="separator">›</span>
<span>{{ Str::limit($informasi->judul, 30) }}</span>
@endsection

@section('content')
<div class="row">
    <div class="col-lg-8 mx-auto">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="bi bi-megaphone me-2 text-primary"></i> Informasi Pendidikan</span>
                <div class="d-flex gap-2">
                    <a href="{{ route('admin.informasis.edit', $informasi->id) }}" class="btn btn-warning btn-sm"><i class="bi bi-pencil"></i> Edit</a>
                    <a href="{{ route('admin.informasis.index') }}" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-left"></i> Kembali</a>
                </div>
            </div>
            <div class="card-body">
                <div class="mb-4">
                    <h5 class="text-muted mb-1" style="font-size:13px;text-transform:uppercase;letter-spacing:.5px;font-weight:600">JUDUL</h5>
                    <h4 class="fw-bold" style="color:var(--gray-900)">{{ $informasi->judul }}</h4>
                </div>
                <div class="row mb-4 g-3">
                    <div class="col-md-6">
                        <div class="p-3 rounded-3" style="background:var(--gray-50)">
                            <h5 class="text-muted mb-1" style="font-size:11px;text-transform:uppercase;letter-spacing:.5px;font-weight:600">TANGGAL</h5>
                            <p class="fw-semibold mb-0"><i class="bi bi-calendar me-1 text-primary"></i> {{ $informasi->tanggal->format('d F Y') }}</p>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="p-3 rounded-3" style="background:var(--gray-50)">
                            <h5 class="text-muted mb-1" style="font-size:11px;text-transform:uppercase;letter-spacing:.5px;font-weight:600">DIBUAT OLEH</h5>
                            <p class="fw-semibold mb-0"><i class="bi bi-person me-1 text-primary"></i> {{ $informasi->creator->nama ?? '-' }}</p>
                        </div>
                    </div>
                </div>
                <hr class="my-4">
                <div class="p-4 rounded-3" style="background:var(--gray-50);white-space:pre-wrap;line-height:1.8;font-size:15px">{{ $informasi->isi }}</div>
            </div>
            <div class="card-footer text-muted d-flex justify-content-between align-items-center">
                <small><i class="bi bi-clock me-1"></i> Dibuat: {{ $informasi->created_at->format('d M Y H:i') }}</small>
                <small><i class="bi bi-clock-history me-1"></i> Diupdate: {{ $informasi->updated_at->format('d M Y H:i') }}</small>
            </div>
        </div>
    </div>
</div>
@endsection
