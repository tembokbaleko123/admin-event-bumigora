@extends('layouts.admin')
@section('title', 'Detail User')
@section('page-title', 'Detail User')
@section('page-subtitle', $user->nama)

@section('content')
<div class="row">
    <div class="col-lg-8 mx-auto">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span><i class="bi bi-person-circle me-2 text-primary"></i> Informasi User</span>
                <div class="d-flex gap-2">
                    <a href="{{ route('admin.users.edit', $user->id) }}" class="btn btn-warning btn-sm"><i class="bi bi-pencil"></i> Edit</a>
                    <a href="{{ route('admin.users.index') }}" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-left"></i> Kembali</a>
                </div>
            </div>
            <div class="card-body">
                <div class="text-center mb-4">
                    <div class="mx-auto mb-3" style="width:80px;height:80px;border-radius:50%;background:linear-gradient(135deg,#4f46e5,#818cf8);display:flex;align-items:center;justify-content:center;font-size:32px;color:#fff;font-weight:700">{{ strtoupper(substr($user->nama, 0, 1)) }}</div>
                    <h4 class="fw-bold">{{ $user->nama }}</h4>
                    <span class="badge-role {{ $user->role }}" style="font-size:13px;padding:6px 16px">{{ $user->role }}</span>
                </div>
                <hr>
                <div class="row">
                    <div class="col-md-6 mb-3"><h5 class="text-muted mb-1" style="font-size:13px">EMAIL</h5><p class="fw-semibold"><i class="bi bi-envelope me-1"></i> {{ $user->email }}</p></div>
                    <div class="col-md-6 mb-3"><h5 class="text-muted mb-1" style="font-size:13px">ROLE</h5><p class="fw-semibold"><i class="bi bi-shield me-1"></i> {{ ucfirst($user->role) }}</p></div>
                    <div class="col-md-6"><h5 class="text-muted mb-1" style="font-size:13px">TERDAFTAR</h5><p class="fw-semibold"><i class="bi bi-clock me-1"></i> {{ $user->created_at->format('d M Y H:i') }}</p></div>
                    <div class="col-md-6"><h5 class="text-muted mb-1" style="font-size:13px">DIPERBARUI</h5><p class="fw-semibold"><i class="bi bi-clock-history me-1"></i> {{ $user->updated_at->format('d M Y H:i') }}</p></div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
