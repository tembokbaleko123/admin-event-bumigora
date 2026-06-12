<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $request->validate([
            'search' => 'nullable|string|max:255',
            'role' => 'nullable|in:mahasiswa,dosen,admin',
        ]);

        $query = User::select('id', 'nama', 'email', 'role', 'created_at');

        // Search using scope
        $query->search($request->search);

        // Filter by role using scope
        $query->role($request->role);

        $users = $query->orderBy('created_at', 'desc')->paginate(10)->withQueryString();
        return view('users.index', compact('users'));
    }

    public function show($id)
    {
        $user = User::select('id', 'nama', 'email', 'role', 'created_at', 'updated_at')
            ->findOrFail($id);
        return view('users.show', compact('user'));
    }

    public function edit($id)
    {
        $user = User::withCount(['events', 'informasis'])->findOrFail($id);
        return view('users.edit', compact('user'));
    }

    public function update(Request $request, $id)
    {
        $user = User::withCount(['events', 'informasis'])->findOrFail($id);

        $validated = $request->validate([
            'nama' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|email|unique:users,email,' . $id,
            'password' => 'nullable|string|min:8',
            'role' => 'sometimes|required|in:mahasiswa,dosen,admin',
        ]);

        if ($user->id === auth()->id() && isset($validated['role']) && $validated['role'] !== $user->role) {
            return back()
                ->withInput()
                ->with('error', 'Role akun yang sedang digunakan tidak dapat diubah.');
        }

        if (empty($validated['password'])) {
            unset($validated['password']);
        }

        $user->update($validated);

        return redirect()->route('admin.users.index')
            ->with('success', 'User "' . $user->nama . '" berhasil diperbarui!');
    }

    public function destroy($id)
    {
        $user = User::findOrFail($id);

        if ($user->id === auth()->id()) {
            return redirect()->route('admin.users.index')
                ->with('error', 'Tidak dapat menghapus akun sendiri!');
        }

        if ($user->events_count > 0 || $user->informasis_count > 0) {
            return redirect()->route('admin.users.index')
                ->with('error', 'User masih memiliki event atau informasi. Pindahkan atau hapus konten terlebih dahulu.');
        }

        $nama = $user->nama;
        $user->tokens()->delete();
        $user->delete();

        return redirect()->route('admin.users.index')
            ->with('success', 'User "' . $nama . '" berhasil dihapus!');
    }
}
