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
                <form method="POST" action="{{ route('admin.informasis.update', $informasi->id) }}" enctype="multipart/form-data">
                    @csrf @method('PUT')
                    <div class="mb-3">
                        <label class="form-label">Judul <span class="text-danger">*</span></label>
                        <input type="text" name="judul" class="form-control @error('judul') is-invalid @enderror" value="{{ old('judul', $informasi->judul) }}" required>
                        @error('judul')<div class="invalid-feedback">{{ $message }}</div>@enderror
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Tanggal <span class="text-danger">*</span></label>
                        <input type="date" name="tanggal" class="form-control @error('tanggal') is-invalid @enderror" value="{{ old('tanggal', $informasi->tanggal->format('Y-m-d')) }}" required>
                        @error('tanggal')<div class="invalid-feedback">{{ $message }}</div>@enderror
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Gambar</label>
                        <input type="file" name="gambar" class="form-control @error('gambar') is-invalid @enderror" accept="image/*">
                        <small class="text-muted">Format: jpeg, png, jpg, gif, svg, webp. Maks: 2MB</small>
                        @error('gambar')<div class="invalid-feedback">{{ $message }}</div>@enderror
                    </div>
                    @if($informasi->gambar_url)
                    <div class="mb-3">
                        <div class="d-flex align-items-center gap-3 p-3 bg-soft-primary rounded-3">
                            <img src="{{ $informasi->gambar_url }}" alt="Preview" style="width:80px;height:80px;border-radius:8px;object-fit:cover;">
                            <div>
                                <p class="mb-1 fw-semibold">Gambar Saat Ini</p>
                                <div class="form-check">
                                    <input type="checkbox" name="hapus_gambar" value="1" class="form-check-input" id="hapusGambar">
                                    <label class="form-check-label text-danger" for="hapusGambar">Hapus gambar ini</label>
                                </div>
                            </div>
                        </div>
                    </div>
                    @endif
                    <div class="mb-4">
                        <label class="form-label">Isi Informasi <span class="text-danger">*</span></label>
                        <textarea name="isi" class="form-control @error('isi') is-invalid @enderror" rows="8" required>{{ old('isi', $informasi->isi) }}</textarea>
                        @error('isi')<div class="invalid-feedback">{{ $message }}</div>@enderror
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
