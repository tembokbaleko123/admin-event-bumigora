<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;

class EventController extends Controller
{
    /**
     * Tampilkan daftar semua event
     */
    public function index(Request $request)
    {
        $request->validate([
            'search' => 'nullable|string|max:255',
            'kategori' => 'nullable|in:KULIAH,WORKSHOP,SEMINAR,MEETING,UKM',
            'tanggal_mulai' => 'nullable|date',
            'tanggal_selesai' => 'nullable|date|after_or_equal:tanggal_mulai',
        ]);

        $query = Event::with('creator:id,nama,role');

        // Search using scope
        $query->search($request->search);

        // Filter by kategori using scope
        $query->kategori($request->kategori);

        // Filter by date range
        if ($request->filled('tanggal_mulai')) {
            $query->whereDate('tanggal', '>=', $request->tanggal_mulai);
        }
        if ($request->filled('tanggal_selesai')) {
            $query->whereDate('tanggal', '<=', $request->tanggal_selesai);
        }

        $events = $query->orderBy('created_at', 'desc')->paginate(10)->withQueryString();

        // Daftar kategori untuk dropdown filter
        $kategoriList = collect(['KULIAH', 'WORKSHOP', 'SEMINAR', 'MEETING', 'UKM']);

        return view('events.index', compact('events', 'kategoriList'));
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
            'tanggal' => 'required|date|after_or_equal:now',
            'lokasi' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
            'kategori' => 'nullable|in:KULIAH,WORKSHOP,SEMINAR,MEETING,UKM',
            'gambar' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
        ]);

        $event = Event::tambahEvent($validated, $request->user());

        return redirect()->route('admin.events.index')
            ->with('success', 'Event "' . $event->judul . '" berhasil ditambahkan!');
    }

    /**
     * Tampilkan detail event
     */
    public function show($id, Request $request)
    {
        $event = Event::with('creator:id,nama,role')->findOrFail($id);
        $canManageEvent = $this->canManage($event, $request);

        return view('events.show', compact('event', 'canManageEvent'));
    }

    /**
     * Tampilkan form edit event
     */
    public function edit($id, Request $request)
    {
        $event = Event::findOrFail($id);

        if (!$this->canManage($event, $request)) {
            return $this->denyEventAccess();
        }

        return view('events.edit', compact('event'));
    }

    /**
     * Update event
     */
    public function update(Request $request, $id)
    {
        $event = Event::findOrFail($id);

        if (!$this->canManage($event, $request)) {
            return $this->denyEventAccess();
        }

        $validated = $request->validate([
            'judul' => 'sometimes|required|string|max:255',
            'tanggal' => 'sometimes|required|date|after_or_equal:now',
            'lokasi' => 'sometimes|required|string|max:255',
            'deskripsi' => 'nullable|string',
            'kategori' => 'nullable|in:KULIAH,WORKSHOP,SEMINAR,MEETING,UKM',
            'gambar' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'hapus_gambar' => 'nullable|boolean',
        ]);

        $event->updateEvent($validated);

        return redirect()->route('admin.events.index')
            ->with('success', 'Event "' . $event->judul . '" berhasil diperbarui!');
    }

    /**
     * Hapus event
     */
    public function destroy($id, Request $request)
    {
        $event = Event::findOrFail($id);

        if (!$this->canManage($event, $request)) {
            return $this->denyEventAccess();
        }

        $judul = $event->judul;
        $event->hapusEvent();

        return redirect()->route('admin.events.index')
            ->with('success', 'Event "' . $judul . '" berhasil dihapus!');
    }

    /**
     * Export events to calendar data (JSON API for calendar view)
     */
    public function calendar(Request $request)
    {
        $query = Event::query();

        if ($request->user()->isDosen()) {
            $query->where('created_by', $request->user()->id);
        }

        $events = $query->get()->map(function ($event) {
            return [
                'id' => $event->id,
                'title' => $event->judul,
                'start' => $event->tanggal->toIso8601String(),
                'url' => route('admin.events.show', $event->id),
                'backgroundColor' => $event->kategori ? '#4f46e5' : '#6366f1',
                'borderColor' => '#fff',
                'textColor' => '#fff',
                'extendedProps' => [
                    'lokasi' => $event->lokasi,
                    'kategori' => $event->kategori,
                ],
            ];
        });

        if ($request->wantsJson() || $request->ajax()) {
            return response()->json($events);
        }

        return view('events.calendar', compact('events'));
    }

    private function canManage(Event $event, Request $request): bool
    {
        $user = $request->user();
        return $user->isAdmin() || $event->created_by === $user->id;
    }

    private function denyEventAccess()
    {
        return redirect()->route('admin.events.index')
            ->with('error', 'Dosen hanya dapat mengubah atau menghapus event yang dibuat sendiri.');
    }
}
