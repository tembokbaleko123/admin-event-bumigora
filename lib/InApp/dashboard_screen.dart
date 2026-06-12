import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/theme/theme_extensions.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/core/utils/date_formatter.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/utils/route_transitions.dart';
import 'package:aplikasi_kampus/InApp/event_detail.dart';
import 'package:aplikasi_kampus/Navigation/calendar.dart';
import 'package:aplikasi_kampus/func/notification.dart';
import 'package:aplikasi_kampus/func/informasi_list.dart';
import 'package:aplikasi_kampus/func/show_qr_screen.dart';
import 'package:aplikasi_kampus/admin/participants_screen.dart';
import 'package:aplikasi_kampus/providers/event_provider.dart';
import 'package:aplikasi_kampus/providers/auth_provider.dart';
import 'package:aplikasi_kampus/providers/analytics_provider.dart';
import 'package:aplikasi_kampus/providers/notifikasi_provider.dart';
import 'package:aplikasi_kampus/models/analytics.dart';
import 'package:aplikasi_kampus/models/event_model.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents(sortBy: 'tanggal', sortOrder: 'desc');
      context.read<AnalyticsProvider>().loadDashboardOverview();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  final _kategoriList = <String?>[null, ...AppStrings.allCategories];
  String? _selectedKategori;
  DateTime? _filterTanggalMulai;
  DateTime? _filterTanggalSelesai;
  String? _sortBy;
  String? _sortOrder;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekDays = DateFormatter.weekFromToday();
    final eventProv = context.watch<EventProvider>();
    final auth = context.watch<AuthProvider>();
    final overview = context.watch<AnalyticsProvider>().overview;
    final unreadCount = context.watch<NotifikasiProvider>().unreadCount;
    final user = auth.user;
    final userName = user?.nama ?? 'Pengguna';
    final lecturerEvents = user?.isDosen == true
        ? _ownUpcomingEvents(eventProv.events, user!.id)
        : const <EventModel>[];

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          eventProv.loadEvents(kategori: _selectedKategori, sortBy: _sortBy, sortOrder: _sortOrder, force: true),
          context.read<AnalyticsProvider>().loadDashboardOverview(),
        ]);
      },
      child: Material(
        color: context.scaffoldBgColor,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: Responsive.screenPadding(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Selamat Pagi", style: TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text("Hi, $userName 👋", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          context.read<NotifikasiProvider>().load();
                          Navigator.push(context, RouteTransitions.slideFromRight(const NotificationScreen(isLecturer: true)));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                          child: _notificationIcon(unreadCount),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (v) {
                    eventProv.setSearchQuery(v);
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      eventProv.loadEvents(search: v.isEmpty ? null : v, kategori: _selectedKategori, sortBy: _sortBy, sortOrder: _sortOrder);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search events...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: eventProv.state == LoadState.loading
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                        : null,
                    filled: true,
                    fillColor: context.surfaceColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _kategoriList.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final label = _kategoriList[i] ?? AppStrings.labelSemua;
                      final selected = _selectedKategori == _kategoriList[i];
                      return FilterChip(
                        label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.grey.shade700, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _selectedKategori = _kategoriList[i]);
                          eventProv.loadEvents(kategori: _kategoriList[i], tanggalMulai: _filterTanggalMulai != null ? DateFormatter.apiDate(_filterTanggalMulai!) : null, tanggalSelesai: _filterTanggalSelesai != null ? DateFormatter.apiDate(_filterTanggalSelesai!) : null, sortBy: _sortBy, sortOrder: _sortOrder);
                        },
                        backgroundColor: context.surfaceColor,
                        selectedColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: selected ? AppColors.primary : Colors.grey.shade200)),
                        side: BorderSide.none,
                        visualDensity: VisualDensity.compact,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _filterChip(
                        icon: Icons.date_range,
                        label: _filterTanggalMulai != null && _filterTanggalSelesai != null
                            ? '${DateFormatter.apiDate(_filterTanggalMulai!)} - ${DateFormatter.apiDate(_filterTanggalSelesai!)}'
                            : 'Filter Tanggal',
                        onTap: _pickDateRange,
                        onClear: _filterTanggalMulai != null ? () {
                          setState(() { _filterTanggalMulai = null; _filterTanggalSelesai = null; });
                          eventProv.loadEvents(kategori: _selectedKategori, sortBy: _sortBy, sortOrder: _sortOrder);
                        } : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _sortDropdown(),
                  ],
                ),
                if (user?.isDosen == true) ...[
                  const SizedBox(height: 16),
                  if (overview != null && overview.role == 'dosen') ...[
                    _lecturerOverviewCard(overview),
                    const SizedBox(height: 16),
                  ],
                  _lecturerUpcomingSection(lecturerEvents),
                ],
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.push(context, RouteTransitions.slideFromRight(const InformasiListScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.article_outlined, size: 18, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: Text("Lihat Informasi & Pengumuman", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                        const Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormatter.dayName(now), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormatter.fullDate(now), style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, RouteTransitions.slideFromRight(const CalendarViewAllScreen())),
                          child: const Text(AppStrings.lihatSemua, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 95,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weekDays.length,
                    itemBuilder: (_, i) {
                      final d = weekDays[i];
                      final isToday = d.day == now.day && d.month == now.month;
                      return DateBadge(
                        day: DateFormatter.shortDayName(d),
                        date: d.day.toString(),
                        isSelected: isToday,
                        hasEvent: eventProv.eventsForDate(d).isNotEmpty,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: "Jadwal Hari Ini", actionLabel: "${eventProv.eventsForDate(now).length} Event"),
                const SizedBox(height: 14),
                if (eventProv.state == LoadState.loading)
                  const ShimmerLoading(itemCount: 3, itemHeight: 90, padding: EdgeInsets.zero)
                else if (eventProv.state == LoadState.error)
                  ErrorDisplayWidget(message: eventProv.error ?? 'Gagal memuat', onRetry: () => eventProv.loadEvents(kategori: _selectedKategori, sortBy: _sortBy, sortOrder: _sortOrder))
                else if (eventProv.eventsForDate(now).isNotEmpty)
                  EventTimeline(
                    events: eventProv.eventsForDate(now).toList(),
                    onTap: (ev) {
                      Navigator.push(
                        context,
                        RouteTransitions.slideUp(EventDetailScreen(
                          eventId: ev.id, title: ev.judul, location: ev.lokasi,
                          time: DateFormatter.formatTime(ev.tanggal), type: ev.kategori,
                        )),
                      ).then((changed) {
                        if (changed == true && context.mounted) {
                          context.read<EventProvider>().loadEvents(force: true);
                        }
                      });
                    },
                  ),
                if (eventProv.eventsForDate(now).isEmpty && eventProv.state == LoadState.loaded)
                  const EmptyStateWidget(title: AppStrings.emptyJadwalHariIni, icon: Icons.calendar_month),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lecturerOverviewCard(DashboardOverview overview) {
    final nextEvent = overview.lecturerNextEvent;
    final nextTitle = nextEvent?['judul']?.toString();
    final nextDate = nextEvent?['tanggal']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.95), AppColors.primaryDark.withValues(alpha: 0.95)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Dosen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 14),
          Row(
            children: [
              _miniStat('Event', '${overview.lecturerEvents}', Icons.event_note_rounded),
              _miniStat('Pending', '${overview.lecturerPendingEvents}', Icons.pending_actions_rounded),
              _miniStat('Peserta', '${overview.lecturerParticipants}', Icons.groups_rounded),
            ],
          ),
          if (nextTitle != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text('$nextTitle • ${DateFormatter.formatTime(nextDate)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _lecturerUpcomingSection(List<EventModel> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Event Mendatang Saya', actionLabel: '${events.length} Event'),
        const SizedBox(height: 12),
        if (events.isEmpty)
          const EmptyStateWidget(icon: Icons.event_busy, title: 'Belum ada event mendatang milik Anda.')
        else
          ...events.asMap().entries.map((entry) => _lecturerEventTile(entry.value, entry.key)),
      ],
    );
  }

  Widget _lecturerEventTile(EventModel event, int index) {
    return AnimatedListItem(
      index: index,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: context.onSurfaceColor.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: _statusColor(event.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.event_available_rounded, color: _statusColor(event.status), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.judul, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Text('${DateFormatter.formatTime(event.tanggal)} - ${event.lokasi}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                _statusBadge(event.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, RouteTransitions.slideFromRight(EventDetailScreen(eventId: event.id, title: event.judul))),
                    icon: const Icon(Icons.visibility_outlined, size: 17),
                    label: const Text('Detail'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: 'QR Absensi',
                  onPressed: () => Navigator.push(context, RouteTransitions.slideFromRight(ShowQrScreen(eventId: event.id, eventTitle: event.judul))),
                  icon: const Icon(Icons.qr_code_2, size: 19),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: 'Peserta',
                  onPressed: () => Navigator.push(context, RouteTransitions.slideFromRight(ParticipantsScreen(eventId: event.id, eventTitle: event.judul))),
                  icon: const Icon(Icons.groups_outlined, size: 19),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<EventModel> _ownUpcomingEvents(List<EventModel> events, int userId) {
    final now = DateTime.now();
    final upcoming = events.where((event) {
      final date = DateTime.tryParse(event.tanggal);
      return event.createdBy == userId && date != null && !date.isBefore(now);
    }).toList();
    upcoming.sort((a, b) {
      final da = DateTime.tryParse(a.tanggal);
      final db = DateTime.tryParse(b.tanggal);
      if (da == null || db == null) return 0;
      return da.compareTo(db);
    });
    return upcoming.take(3).toList();
  }

  Widget _notificationIcon(int unreadCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_outlined, size: 22),
        if (unreadCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
              child: Text(unreadCount > 99 ? '99+' : '$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget _statusBadge(String? status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(_statusLabel(status), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case AppStrings.statusPending:
        return Colors.orange;
      case AppStrings.statusPublished:
        return Colors.green;
      case AppStrings.statusRejected:
        return Colors.red;
      case AppStrings.statusCompleted:
        return Colors.blueGrey;
      case AppStrings.statusCancelled:
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case AppStrings.statusPending:
        return 'Pending';
      case AppStrings.statusPublished:
        return 'Published';
      case AppStrings.statusRejected:
        return 'Ditolak';
      case AppStrings.statusCompleted:
        return 'Selesai';
      case AppStrings.statusCancelled:
        return 'Batal';
      default:
        return status ?? '-';
    }
  }

  Widget _miniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _filterTanggalMulai != null && _filterTanggalSelesai != null
          ? DateTimeRange(start: _filterTanggalMulai!, end: _filterTanggalSelesai!)
          : null,
    );
    if (picked != null && mounted) {
      setState(() {
        _filterTanggalMulai = picked.start;
        _filterTanggalSelesai = picked.end;
      });
      final eventProv = context.read<EventProvider>();
      eventProv.loadEvents(
        kategori: _selectedKategori,
        tanggalMulai: DateFormatter.apiDate(picked.start),
        tanggalSelesai: DateFormatter.apiDate(picked.end),
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );
    }
  }

  Widget _filterChip({required IconData icon, required String label, required VoidCallback onTap, VoidCallback? onClear}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: _filterTanggalMulai != null ? AppColors.primary.withValues(alpha: 0.1) : context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _filterTanggalMulai != null ? AppColors.primary : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: _filterTanggalMulai != null ? AppColors.primary : Colors.grey),
            const SizedBox(width: 4),
            Flexible(child: Text(label, style: TextStyle(fontSize: 11, color: _filterTanggalMulai != null ? AppColors.primary : Colors.grey.shade700), overflow: TextOverflow.ellipsis)),
            if (onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(onTap: onClear, child: Icon(Icons.close, size: 14, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sortDropdown() {
    final sortOptions = [
      ('Tanggal Terbaru', 'tanggal', 'desc'),
      ('Tanggal Terlama', 'tanggal', 'asc'),
      ('A-Z', 'judul', 'asc'),
      ('Z-A', 'judul', 'desc'),
    ];
    final currentLabel = sortOptions.firstWhere(
      (o) => o.$2 == _sortBy && o.$3 == _sortOrder,
      orElse: () => sortOptions[0],
    ).$1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLabel,
          icon: const Icon(Icons.swap_vert, size: 16),
          style: const TextStyle(fontSize: 11, color: Colors.black87),
          items: sortOptions.map((o) => DropdownMenuItem(value: o.$1, child: Text(o.$1, style: const TextStyle(fontSize: 11)))).toList(),
          onChanged: (v) {
            if (v == null) return;
            final selected = sortOptions.firstWhere((o) => o.$1 == v);
            setState(() {
              _sortBy = selected.$2;
              _sortOrder = selected.$3;
            });
            context.read<EventProvider>().loadEvents(
              kategori: _selectedKategori,
              tanggalMulai: _filterTanggalMulai != null ? DateFormatter.apiDate(_filterTanggalMulai!) : null,
              tanggalSelesai: _filterTanggalSelesai != null ? DateFormatter.apiDate(_filterTanggalSelesai!) : null,
              sortBy: selected.$2,
              sortOrder: selected.$3,
            );
          },
        ),
      ),
    );
  }
}
