@extends('layouts.admin')
@section('title', 'Profil')
@section('page-title', 'Profil')
@section('page-subtitle', 'Kelola informasi akun Anda')

@section('content')
<div class="row g-4">
    <div class="col-xl-4">
        <div class="card text-center">
            <div class="card-body py-5">
                <div style="width:100px;height:100px;margin:0 auto 16px;border-radius:50%;background:linear-gradient(135deg,#4f46e5,#818cf8);display:flex;align-items:center;justify-content:center;color:white;font-size:40px;font-weight:700;">
                    {{ strtoupper(substr($user->nama, 0, 1)) }}
                </div>
                <h5 class="fw-bold">{{ $user->nama }}</h5>
                <p class="text-muted mb-2">{{ $user->email }}</p>
                <span class="badge-role {{ $user->role }}">{{ $user->role }}</span>
                <p class="text-muted mt-3 mb-0" style="font-size:12px">Terdaftar sejak {{ $user->created_at->format('d M Y') }}</p>
            </div>
        </div>
    </div>
    <div class="col-xl-8">
        <div class="card">
            <div class="card-header"><i class="bi bi-person me-2 text-primary"></i>Edit Profil</div>
            <div class="card-body">
                <form method="POST" action="{{ route('admin.profile.update') }}">
                    @csrf @method('PUT')
                    <div class="mb-3">
                        <label class="form-label">Nama Lengkap</label>
                        <input type="text" name="nama" class="form-control" value="{{ old('nama', $user->nama) }}" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <input type="email" name="email" class="form-control" value="{{ old('email', $user->email) }}" required>
                    </div>
                    <button type="submit" class="btn btn-primary">Simpan Profil</button>
                </form>
            </div>
        </div>

        <div class="card mt-4">
            <div class="card-header"><i class="bi bi-lock me-2 text-primary"></i>Ubah Password</div>
            <div class="card-body">
                <form method="POST" action="{{ route('admin.profile.password') }}">
                    @csrf @method('PUT')
                    <div class="mb-3">
                        <label class="form-label">Password Saat Ini</label>
                        <input type="password" name="current_password" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Password Baru</label>
                        <input type="password" name="new_password" class="form-control" required minlength="8">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Konfirmasi Password Baru</label>
                        <input type="password" name="new_password_confirmation" class="form-control" required minlength="8">
                    </div>
                    <button type="submit" class="btn btn-primary">Ubah Password</button>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
