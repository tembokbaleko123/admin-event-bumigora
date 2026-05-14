@extends('layouts.admin')
@section('title', 'Edit Event')
@section('page-title', 'Edit Event')
@section('page-subtitle', 'Update data event akademik')

@section('content')
<div class="row justify-content-center">
    <div class="col-lg-8">
        <div class="card">
            <div class="card-header"><i class="bi bi-pencil-square me-2 text-primary"></i> Form Edit Event</div>
            <div class="card-body">
                <form method="POST" action="{{ route('admin.events.update', $event->id) }}">
                    @csrf @method('PUT')
                    <div class="mb-3">
                        <label class="form-label">Judul Event <span class="text-danger">*</span></label>
                        <input type="text" name="judul" class="form-control" value="{{ old('judul', $event->judul) }}" required>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Tanggal <span class="text-danger">*</span></label>
                            <input type="date" name="tanggal" class="form-control" value="{{ old('tanggal', $event->tanggal->format('Y-m-d')) }}" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Lokasi <span class="text-danger">*</span></label>
                            <input type="text" name="lokasi" class="form-control" value="{{ old('lokasi', $event->lokasi) }}" required>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label class="form-label">Deskripsi</label>
                        <textarea name="deskripsi" class="form-control" rows="4">{{ old('deskripsi', $event->deskripsi) }}</textarea>
                    </div>
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary"><i class="bi bi-save me-1"></i> Update</button>
                        <a href="{{ route('admin.events.index') }}" class="btn btn-outline-secondary">Batal</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
