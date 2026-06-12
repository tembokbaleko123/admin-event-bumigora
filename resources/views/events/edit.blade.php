@extends('layouts.admin')
@section('title', 'Edit Event')
@section('page-title', 'Edit Event')
@section('page-subtitle', 'Ubah data event akademik')

@section('content')
<div class="row justify-content-center">
    <div class="col-lg-8">
        <div class="card">
            <div class="card-header"><i class="bi bi-pencil me-2 text-primary"></i> Form Edit Event</div>
            <div class="card-body">
                <form method="POST" action="{{ route('admin.events.update', $event->id) }}" enctype="multipart/form-data">
                    @csrf @method('PUT')
                    <div class="mb-3">
                        <label class="form-label">Judul Event <span class="text-danger">*</span></label>
                        <input type="text" name="judul" class="form-control @error('judul') is-invalid @enderror" value="{{ old('judul', $event->judul) }}" required>
                        @error('judul')<div class="invalid-feedback">{{ $message }}</div>@enderror
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Tanggal & Waktu <span class="text-danger">*</span></label>
                            <input type="datetime-local" name="tanggal" class="form-control @error('tanggal') is-invalid @enderror" value="{{ old('tanggal', $event->tanggal->format('Y-m-d\\TH:i')) }}" required>
                            @error('tanggal')<div class="invalid-feedback">{{ $message }}</div>@enderror
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Kategori</label>
                            <select name="kategori" class="form-select @error('kategori') is-invalid @enderror">
                                <option value="">Pilih Kategori</option>
                                <option value="KULIAH" {{ old('kategori', $event->kategori) == 'KULIAH' ? 'selected' : '' }}>Kuliah</option>
                                <option value="WORKSHOP" {{ old('kategori', $event->kategori) == 'WORKSHOP' ? 'selected' : '' }}>Workshop</option>
                                <option value="SEMINAR" {{ old('kategori', $event->kategori) == 'SEMINAR' ? 'selected' : '' }}>Seminar</option>
                                <option value="MEETING" {{ old('kategori', $event->kategori) == 'MEETING' ? 'selected' : '' }}>Meeting</option>
                                <option value="UKM" {{ old('kategori', $event->kategori) == 'UKM' ? 'selected' : '' }}>UKM</option>
                            </select>
                            @error('kategori')<div class="invalid-feedback">{{ $message }}</div>@enderror
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Lokasi <span class="text-danger">*</span></label>
                            <input type="text" name="lokasi" class="form-control @error('lokasi') is-invalid @enderror" value="{{ old('lokasi', $event->lokasi) }}" required>
                            @error('lokasi')<div class="invalid-feedback">{{ $message }}</div>@enderror
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Gambar / Poster</label>
                            <input type="file" name="gambar" class="form-control @error('gambar') is-invalid @enderror" accept="image/*">
                            <small class="text-muted">Format: jpeg, png, jpg, gif, svg, webp. Maks: 2MB</small>
                            @error('gambar')<div class="invalid-feedback">{{ $message }}</div>@enderror
                        </div>
                    </div>
                    @if($event->gambar_url)
                    <div class="mb-3">
                        <div class="d-flex align-items-center gap-3 p-3 bg-soft-primary rounded-3">
                            <img src="{{ $event->gambar_url }}" alt="Preview" style="width:80px;height:80px;border-radius:8px;object-fit:cover;">
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
                        <label class="form-label">Deskripsi</label>
                        <textarea name="deskripsi" class="form-control @error('deskripsi') is-invalid @enderror" rows="4">{{ old('deskripsi', $event->deskripsi) }}</textarea>
                        @error('deskripsi')<div class="invalid-feedback">{{ $message }}</div>@enderror
                    </div>
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary"><i class="bi bi-save me-1"></i> Simpan</button>
                        <a href="{{ route('admin.events.index') }}" class="btn btn-outline-secondary">Batal</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
