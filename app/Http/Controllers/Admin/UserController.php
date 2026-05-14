<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function index()
    {
        $users = User::select('id', 'nama', 'email', 'role', 'created_at')
            ->orderBy('created_at', 'desc')
            ->paginate(10);
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
        $user = User::findOrFail($id);
        return view('users.edit', compact('user'));
    }

    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $validated = $request->validate([
            'nama' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|email|unique:users,email,' . $id,
            'password' => 'nullable|string|min:6',
            'role' => 'sometimes|required|in:mahasiswa,dosen,admin',
        ]);

        if (empty($validated['password'])) {
            unset($validated['password']);
        }
        // Password akan di-hash otomatis oleh 'hashed' cast di model User

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

        $nama = $user->nama;
        $user->delete();

        return redirect()->route('admin.users.index')
            ->with('success', 'User "' . $nama . '" berhasil dihapus!');
    }
}
