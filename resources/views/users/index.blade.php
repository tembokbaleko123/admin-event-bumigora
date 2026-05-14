@extends('layouts.admin')
@section('title', 'Users')
@section('page-title', 'Manajemen Users')
@section('page-subtitle', 'Kelola semua pengguna sistem')

@section('content')
<div class="card">
    <div class="card-header"><span><i class="bi bi-people me-2 text-primary"></i> Daftar User</span></div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table">
                <thead><tr><th>#</th><th>Nama</th><th>Email</th><th>Role</th><th>Terdaftar</th><th class="text-end">Aksi</th></tr></thead>
                <tbody>
                    @forelse($users as $user)
                    <tr>
                        <td class="text-muted">{{ $loop->iteration }}</td>
                        <td class="fw-semibold">{{ $user->nama }}</td>
                        <td>{{ $user->email }}</td>
                        <td><span class="badge-role {{ $user->role }}">{{ $user->role }}</span></td>
                        <td>{{ $user->created_at->format('d M Y') }}</td>
                        <td class="text-end">
                            <a href="{{ route('admin.users.show', $user->id) }}" class="btn btn-sm btn-outline-primary" title="Detail"><i class="bi bi-eye"></i></a>
                            <a href="{{ route('admin.users.edit', $user->id) }}" class="btn btn-sm btn-outline-warning" title="Edit"><i class="bi bi-pencil"></i></a>
                            @if($user->id !== auth()->id())
                            <form action="{{ route('admin.users.destroy', $user->id) }}" method="POST" class="d-inline" onsubmit="return confirm('Yakin ingin menghapus user {{ $user->nama }}?')">
                                @csrf @method('DELETE')
                                <button type="submit" class="btn btn-sm btn-outline-danger" title="Hapus"><i class="bi bi-trash"></i></button>
                            </form>
                            @endif
                        </td>
                    </tr>
                    @empty
                    <tr><td colspan="6" class="text-center text-muted py-5"><i class="bi bi-inbox fs-3 d-block mb-2"></i>Belum ada user</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
    @if($users->hasPages())
    <div class="card-footer d-flex justify-content-center">{{ $users->links() }}</div>
    @endif
</div>
@endsection
