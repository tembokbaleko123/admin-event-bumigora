@extends('layouts.admin')
@section('title', 'Users')
@section('page-title', 'Manajemen Users')
@section('page-subtitle', 'Kelola semua pengguna sistem')

@section('content')
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span><i class="bi bi-people me-2 text-primary"></i> Daftar User</span>
    </div>
    <div class="card-body p-0">
        @livewire('user-table')
    </div>
</div>
@endsection
