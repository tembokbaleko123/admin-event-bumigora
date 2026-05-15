<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\Notifikasi;
use Illuminate\Http\Request;

class EventController extends Controller
{
    /**
     * Tampilkan daftar semua event
     */
    public function index(Request $request)
    {
        $query = Event::with('creator:id,nama');

        // Search by judul
        if ($request->has('search')) {
            $query->where('judul', 'like', '%' . $request->search . '%');
        }

        // Filter by date range
        if ($request->has('tanggal_mulai')) {
            $query->where('tanggal', '>=', $request->tanggal_mulai);
        }
        if ($request->has('tanggal_selesai')) {
            $query->where('tanggal', '<=', $request->tanggal_selesai);
        }

        $events = $query->orderBy('created_at', 'desc')->paginate(10)->withQueryString();
        return view('events.index', compact('events'));
    }

    /**
     * Tampilkan form tambah event
     */
    public function create()
    {
        return view('events.create');
    }

    /**
     * Simpan event baru
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'judul' => 'required|string|max:255',
            'tanggal' => 'required|date',
            'lokasi' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
        ]);

        $event = Event::tambahEvent($validated, $request->user());

        return redirect()->route('admin.events.index')
            ->with('success', 'Event "' . $event->judul . '" berhasil ditambahkan!');
    }

    /**
     * Tampilkan detail event
     */
    public function show($id)
    {
        $event = Event::with('creator:id,nama')->findOrFail($id);
        return view('events.show', compact('event'));
    }

    /**
     * Tampilkan form edit event
     */
    public function edit($id)
    {
        $event = Event::findOrFail($id);
        return view('events.edit', compact('event'));
    }

    /**
     * Update event
     */
    public function update(Request $request, $id)
    {
        $event = Event::findOrFail($id);

        $validated = $request->validate([
            'judul' => 'sometimes|required|string|max:255',
            'tanggal' => 'sometimes|required|date',
            'lokasi' => 'sometimes|required|string|max:255',
            'deskripsi' => 'nullable|string',
        ]);

        $event->updateEvent($validated);

        return redirect()->route('admin.events.index')
            ->with('success', 'Event "' . $event->judul . '" berhasil diperbarui!');
    }

    /**
     * Hapus event
     */
    public function destroy($id)
    {
        $event = Event::findOrFail($id);
        $judul = $event->judul;
        $event->hapusEvent();

        return redirect()->route('admin.events.index')
            ->with('success', 'Event "' . $judul . '" berhasil dihapus!');
    }
}
