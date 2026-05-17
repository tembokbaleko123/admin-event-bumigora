@extends('layouts.admin')
@section('title', 'Kalender Event')
@section('page-title', 'Kalender Event')
@section('page-subtitle', 'Lihat event dalam tampilan kalender')

@push('styles')
<link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.css" rel="stylesheet">
<style>
    #calendar { padding: 20px; }
    .fc-toolbar-title { font-size: 18px !important; font-weight: 700; color: #1e293b; }
    .fc-button-primary { background: #4f46e5 !important; border-color: #4f46e5 !important; }
    .fc-button-primary:hover { background: #4338ca !important; }
    .fc-daygrid-event { border-radius: 8px !important; padding: 3px 8px !important; font-size: 13px !important; }
    .fc-event-title { font-weight: 500 !important; }
</style>
@endpush

@section('content')
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <span><i class="bi bi-calendar3 me-2 text-primary"></i> Kalender Event Akademik</span>
        <a href="{{ route('admin.events.create') }}" class="btn btn-primary btn-sm"><i class="bi bi-plus-lg me-1"></i> Tambah Event</a>
    </div>
    <div class="card-body" id="calendar"></div>
</div>
@endsection

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    var calendarEl = document.getElementById('calendar');
    var calendar = new FullCalendar.Calendar(calendarEl, {
        initialView: 'dayGridMonth',
        headerToolbar: {
            left: 'prev,next today',
            center: 'title',
            right: 'dayGridMonth,listWeek'
        },
        locale: 'id',
        height: 'auto',
        events: @json($events ?? []),
        eventClick: function(info) {
            if (info.event.url) {
                window.location.href = info.event.url;
            }
        }
    });
    calendar.render();
});
</script>
@endpush
