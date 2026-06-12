<div>
    <div class="row g-2 mb-3">
        <div class="col-md-4">
            <div class="input-group">
                <span class="input-group-text bg-white"><i class="bi bi-search text-muted"></i></span>
                <input type="text" class="form-control" placeholder="Cari nama/email..." wire:model.live.debounce.300ms="search">
            </div>
        </div>
        <div class="col-md-2">
            <select class="form-select" wire:model.live="roleFilter">
                <option value="">Semua Role</option>
                <option value="{{ \App\Enums\UserRole::Mahasiswa->value }}">Mahasiswa</option>
                <option value="{{ \App\Enums\UserRole::Dosen->value }}">Dosen</option>
                <option value="{{ \App\Enums\UserRole::Admin->value }}">Admin</option>
            </select>
        </div>
        <div class="col-md-2 d-flex gap-2">
            <a href="{{ route('admin.users.index') }}" class="btn btn-outline-secondary"><i class="bi bi-x-lg"></i></a>
        </div>
    </div>

    <div wire:loading class="mb-3">
        <x-skeleton-table :rows="5" :cols="4" />
    </div>

    <div wire:loading.remove>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>
                            <a href="#" wire:click.prevent="sortBy('nama')" class="text-decoration-none text-reset">
                                Nama @if($sortField === 'nama') <i class="bi bi-arrow-{{ $sortDirection === 'asc' ? 'up' : 'down' }}"></i> @endif
                            </a>
                        </th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>
                            <a href="#" wire:click.prevent="sortBy('created_at')" class="text-decoration-none text-reset">
                                Terdaftar @if($sortField === 'created_at') <i class="bi bi-arrow-{{ $sortDirection === 'asc' ? 'up' : 'down' }}"></i> @endif
                            </a>
                        </th>
                        <th class="text-end">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($users as $user)
                    <tr wire:key="user-{{ $user->id }}">
                        <td class="text-muted">{{ ($users->currentPage() - 1) * $users->perPage() + $loop->iteration }}</td>
                        <td class="fw-semibold">{{ $user->nama }}</td>
                        <td>{{ $user->email }}</td>
                        <td><span class="badge-role {{ $user->role }}">{{ $user->role }}</span></td>
                        <td>{{ $user->created_at->format('d M Y') }}</td>
                        <td class="text-end">
                            <a href="{{ route('admin.users.edit', $user->id) }}" class="btn btn-sm btn-outline-warning" title="Edit"><i class="bi bi-pencil"></i></a>
                            @if($user->id !== auth()->id())
                            <form action="{{ route('admin.users.destroy', $user->id) }}" method="POST" class="d-inline" data-confirm="Yakin ingin menghapus user {{ $user->nama }}?">
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
        @if($users->hasPages())
        <div class="d-flex justify-content-center">
            {{ $users->onEachSide(1)->links() }}
        </div>
        @endif
    </div>
</div>
