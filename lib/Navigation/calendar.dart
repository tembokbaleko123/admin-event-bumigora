import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:aplikasi_kampus/InApp/event_detail.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/utils/date_formatter.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/utils/route_transitions.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/providers/event_provider.dart';
import 'package:aplikasi_kampus/models/event_model.dart';

class CalendarViewAllScreen extends StatefulWidget {
  const CalendarViewAllScreen({super.key});
  @override
  State<CalendarViewAllScreen> createState() => _CalendarViewAllScreenState();
}

class _CalendarViewAllScreenState extends State<CalendarViewAllScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  final CalendarFormat _format = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  Map<DateTime, List<EventModel>> _groupEvents(List<EventModel> events) {
    final map = <DateTime, List<EventModel>>{};
    for (final ev in events) {
      final dt = DateTime.tryParse(ev.tanggal);
      if (dt == null) continue;
      final key = DateTime(dt.year, dt.month, dt.day);
      map.putIfAbsent(key, () => []).add(ev);
    }
    return map;
  }

  List<EventModel> _eventsForDay(EventProvider prov, DateTime day) {
    return prov.eventsForDate(day);
  }

  @override
  Widget build(BuildContext context) {
    final eventProv = context.watch<EventProvider>();
    final eventsForSelected = _eventsForDay(eventProv, _selectedDate);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text(AppStrings.titleCalendar, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<EventProvider>().loadEvents(force: true),
        child: ListView(
          padding: Responsive.screenPadding(context),
          children: [
            _buildCalendar(eventProv),
            const SizedBox(height: 16),
            _buildEventList(eventsForSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(EventProvider eventProv) {
    final allEvents = _groupEvents(eventProv.events);

    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 30)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDate,
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      calendarFormat: _format,
      availableCalendarFormats: const {CalendarFormat.month: 'Bulan'},
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDate = selected;
          _focusedDate = focused;
        });
      },
      onPageChanged: (focused) {
        _focusedDate = focused;
      },
      eventLoader: (day) {
        final key = DateTime(day.year, day.month, day.day);
        return allEvents[key] ?? [];
      },
      calendarStyle: CalendarStyle(
        selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        todayDecoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), shape: BoxShape.circle),
        todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        markerDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        cellMargin: const EdgeInsets.all(4),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
        rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
        weekendStyle: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildEventList(List<EventModel> events) {
    if (events.isEmpty) {
      return const EmptyStateWidget(title: AppStrings.emptyCalendar, icon: Icons.event_busy);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Event pada ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ...events.asMap().entries.map((entry) {
          final ev = entry.value;
          return AnimatedListItem(
            index: entry.key,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ev.judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text("${DateFormatter.formatTime(ev.tanggal)} · ${ev.kategori ?? 'EVENT'}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                    onPressed: () {
                      Navigator.push(
                        context,
                        RouteTransitions.slideFromRight(
                          EventDetailScreen(eventId: ev.id, title: ev.judul, location: ev.lokasi, time: DateFormatter.formatTime(ev.tanggal), type: ev.kategori),
                        ),
                      ).then((_) {
                        if (mounted) context.read<EventProvider>().loadEvents();
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
