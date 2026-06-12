@extends('layouts.admin')
@section('title', 'Informasi')
@section('page-title', 'Informasi Pendidikan')
@section('page-subtitle', 'Kelola informasi pendidikan')

@section('content')
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span><i class="bi bi-megaphone me-2 text-primary"></i> Daftar Informasi</span>
        <a href="{{ route('admin.informasis.create') }}" class="btn btn-primary btn-sm"><i class="bi bi-plus-lg me-1"></i> Tambah Informasi</a>
    </div>
    <div class="card-body">
        <form method="GET" action="{{ route('admin.informasis.index') }}" class="row g-2 mb-3">
            <div class="col-md-6">
                <div class="input-group">
                    <span class="input-group-text bg-white"><i class="bi bi-search text-muted"></i></span>
                    <input type="text" name="search" class="form-control" placeholder="Cari judul informasi..." value="{{ request('search') }}">
                </div>
            </div>
            <div class="col-md-2 d-flex gap-2">
                <button type="submit" class="btn btn-primary"><i class="bi bi-search me-1"></i> Cari</button>
                @if(request('search'))
                <a href="{{ route('admin.informasis.index') }}" class="btn btn-outline-secondary"><i class="bi bi-x-lg"></i></a>
                @endif
            </div>
        </form>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table">
                <thead><tr><th>#</th><th>Judul</th><th>Tanggal</th><th>Dibuat Oleh</th><th class="text-end">Aksi</th></tr></thead>
                <tbody>
                    @forelse($informasis as $info)
                    <tr>
                        <td class="text-muted">{{ ($informasis->currentPage() - 1) * $informasis->perPage() + $loop->iteration }}</td>
                        <td class="fw-semibold">
                            @if($info->gambar_url)
                            <img src="{{ $info->gambar_url }}" alt="" style="width:32px;height:32px;border-radius:6px;object-fit:cover;margin-right:8px;">
                            @endif
                            {{ $info->judul }}
                        </td>
                        <td>{{ $info->tanggal->format('d M Y') }}</td>
                        <td><span class="badge-role {{ $info->creator->role ?? 'admin' }}">{{ $info->creator->nama ?? '-' }}</span></td>
                        <td class="text-end">
                            <a href="{{ route('admin.informasis.show', $info->id) }}" class="btn btn-sm btn-outline-primary" title="Detail"><i class="bi bi-eye"></i></a>
                            <a href="{{ route('admin.informasis.edit', $info->id) }}" class="btn btn-sm btn-outline-warning" title="Edit"><i class="bi bi-pencil"></i></a>
                            <form action="{{ route('admin.informasis.destroy', $info->id) }}" method="POST" class="d-inline" data-confirm="Yakin ingin menghapus informasi ini?">
                                @csrf @method('DELETE')
                                <button type="submit" class="btn btn-sm btn-outline-danger" title="Hapus"><i class="bi bi-trash"></i></button>
                            </form>
                        </td>
                    </tr>
                    @empty
                    <tr><td colspan="5" class="text-center text-muted py-5"><i class="bi bi-inbox fs-3 d-block mb-2"></i>Belum ada informasi</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
    @if($informasis->hasPages())
    <div class="card-footer d-flex justify-content-center">{{ $informasis->links() }}</div>
    @endif
</div>
@endsection
