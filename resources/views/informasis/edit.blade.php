@extends('layouts.admin')
@section('title', 'Edit Informasi')
@section('page-title', 'Edit Informasi')
@section('page-subtitle', 'Update informasi pendidikan')

@section('content')
<div class="row justify-content-center">
    <div class="col-lg-8">
        <div class="card">
            <div class="card-header"><i class="bi bi-pencil-square me-2 text-primary"></i> Form Edit Informasi</div>
            <div class="card-body">
                <form method="POST" action="{{ route('admin.informasis.update', $informasi->id) }}">
                    @csrf @method('PUT')
                    <div class="mb-3">
                        <label class="form-label">Judul <span class="text-danger">*</span></label>
                        <input type="text" name="judul" class="form-control" value="{{ old('judul', $informasi->judul) }}" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Tanggal <span class="text-danger">*</span></label>
                        <input type="date" name="tanggal" class="form-control" value="{{ old('tanggal', $informasi->tanggal->format('Y-m-d')) }}" required>
                    </div>
                    <div class="mb-4">
                        <label class="form-label">Isi Informasi <span class="text-danger">*</span></label>
                        <textarea name="isi" class="form-control" rows="8" required>{{ old('isi', $informasi->isi) }}</textarea>
                    </div>
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary"><i class="bi bi-save me-1"></i> Update</button>
                        <a href="{{ route('admin.informasis.index') }}" class="btn btn-outline-secondary">Batal</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
