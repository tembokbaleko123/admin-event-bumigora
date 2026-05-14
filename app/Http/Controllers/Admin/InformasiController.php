<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Informasi;
use Illuminate\Http\Request;

class InformasiController extends Controller
{
    public function index()
    {
        $informasis = Informasi::with('creator:id,nama')
            ->orderBy('created_at', 'desc')
            ->paginate(10);
        return view('informasis.index', compact('informasis'));
    }

    public function create()
    {
        return view('informasis.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'judul' => 'required|string|max:255',
            'isi' => 'required|string',
            'tanggal' => 'required|date',
        ]);

        $informasi = Informasi::tambahInformasi($validated, $request->user());

        return redirect()->route('admin.informasis.index')
            ->with('success', 'Informasi "' . $informasi->judul . '" berhasil ditambahkan!');
    }

    public function show($id)
    {
        $informasi = Informasi::with('creator:id,nama')->findOrFail($id);
        return view('informasis.show', compact('informasi'));
    }

    public function edit($id)
    {
        $informasi = Informasi::findOrFail($id);
        return view('informasis.edit', compact('informasi'));
    }

    public function update(Request $request, $id)
    {
        $informasi = Informasi::findOrFail($id);

        $validated = $request->validate([
            'judul' => 'sometimes|required|string|max:255',
            'isi' => 'sometimes|required|string',
            'tanggal' => 'sometimes|required|date',
        ]);

        $informasi->updateInformasi($validated);

        return redirect()->route('admin.informasis.index')
            ->with('success', 'Informasi "' . $informasi->judul . '" berhasil diperbarui!');
    }

    public function destroy($id)
    {
        $informasi = Informasi::findOrFail($id);
        $judul = $informasi->judul;
        $informasi->hapusInformasi();

        return redirect()->route('admin.informasis.index')
            ->with('success', 'Informasi "' . $judul . '" berhasil dihapus!');
    }
}
