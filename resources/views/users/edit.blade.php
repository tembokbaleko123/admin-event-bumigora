@extends('layouts.admin')
@section('title', 'Edit User')
@section('page-title', 'Edit User')
@section('page-subtitle', $user->nama)

@section('content')
@php
    $isEditingSelf = $user->id === auth()->id();
@endphp
<div class="row justify-content-center">
    <div class="col-lg-8">
        <div class="card">
            <div class="card-header"><i class="bi bi-pencil-square me-2 text-primary"></i> Form Edit User</div>
            <div class="card-body">
                <form method="POST" action="{{ route('admin.users.update', $user->id) }}">
                    @csrf @method('PUT')
                    <div class="mb-3">
                        <label class="form-label">Nama <span class="text-danger">*</span></label>
                        <input type="text" name="nama" class="form-control @error('nama') is-invalid @enderror" value="{{ old('nama', $user->nama) }}" required>
                        @error('nama')<div class="invalid-feedback">{{ $message }}</div>@enderror
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email <span class="text-danger">*</span></label>
                        <input type="email" name="email" class="form-control @error('email') is-invalid @enderror" value="{{ old('email', $user->email) }}" required>
                        @error('email')<div class="invalid-feedback">{{ $message }}</div>@enderror
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Password <small class="text-muted">(kosongkan jika tidak ingin mengubah)</small></label>
                        <input type="password" name="password" class="form-control @error('password') is-invalid @enderror" minlength="6">
                        @error('password')<div class="invalid-feedback">{{ $message }}</div>@enderror
                    </div>
                    <div class="mb-4">
                        <label class="form-label">Role <span class="text-danger">*</span></label>
                        @if($isEditingSelf)
                            <input type="hidden" name="role" value="{{ $user->role }}">
                        @endif
                        <select name="role" class="form-select @error('role') is-invalid @enderror" required @disabled($isEditingSelf)>
                            <option value="mahasiswa" {{ old('role', $user->role) === 'mahasiswa' ? 'selected' : '' }}>Mahasiswa</option>
                            <option value="dosen" {{ old('role', $user->role) === 'dosen' ? 'selected' : '' }}>Dosen</option>
                            <option value="admin" {{ old('role', $user->role) === 'admin' ? 'selected' : '' }}>Admin</option>
                        </select>
                        @error('role')<div class="invalid-feedback">{{ $message }}</div>@enderror
                        @if($isEditingSelf)
                            <small class="text-muted d-block mt-1">Role akun yang sedang digunakan dikunci untuk menjaga akses panel.</small>
                        @endif
                    </div>
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary"><i class="bi bi-save me-1"></i> Update</button>
                        <a href="{{ route('admin.users.index') }}" class="btn btn-outline-secondary">Batal</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
