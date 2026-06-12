import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/theme/theme_extensions.dart';
import 'package:aplikasi_kampus/InApp/event_detail.dart';
import 'package:aplikasi_kampus/func/notification.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/utils/date_formatter.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/utils/route_transitions.dart';
import 'package:aplikasi_kampus/providers/event_provider.dart';
import 'package:aplikasi_kampus/providers/auth_provider.dart';
import 'package:aplikasi_kampus/providers/analytics_provider.dart';
import 'package:aplikasi_kampus/providers/recommendation_provider.dart';
import 'package:aplikasi_kampus/providers/notifikasi_provider.dart';
import 'package:aplikasi_kampus/func/informasi_list.dart';
import 'package:aplikasi_kampus/func/interest_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  Timer? _debounce;
  final _kategoriList = <String?>[null, ...AppStrings.allCategories];
  String? _selectedKategori;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load events after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _isInitialized = true;
        _loadEvents();
      }
    });
  }

  void _loadEvents() {
    if (!mounted) return;
    try {
      context.read<EventProvider>().loadEvents();
      context.read<AnalyticsProvider>().loadDashboardOverview();
    } catch (e) {
      debugPrint('Failed to load events: $e');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekDays = DateFormatter.weekFromToday();
    final eventProv = context.watch<EventProvider>();
    final auth = context.watch<AuthProvider>();
    final overview = context.watch<AnalyticsProvider>().overview;
    final unreadCount = context.watch<NotifikasiProvider>().unreadCount;
    final userName = auth.user?.nama ?? 'Pengguna';

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          eventProv.loadEvents(kategori: _selectedKategori, force: true),
          context.read<AnalyticsProvider>().loadDashboardOverview(),
        ]);
      },
      child: Scaffold(
        body: SafeArea(
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
                          Text("Hai, $userName 👋", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(DateFormatter.fullDate(now), style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          if (context.mounted) {
                            context.read<NotifikasiProvider>().load();
                            Navigator.push(context, RouteTransitions.slideFromRight(const NotificationScreen(isLecturer: false)));
                          }
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: _notificationIcon(unreadCount),
                          ),
                        ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 8))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StatItem(icon: Icons.analytics_outlined, value: "${(overview?.studentAttendanceRate ?? 0).toStringAsFixed(0)}%", label: "Kehadiran"),
                      _divider(),
                      StatItem(icon: Icons.bookmark_border_rounded, value: "${overview?.bookmarks ?? 0}", label: "Tersimpan"),
                      _divider(),
                      StatItem(icon: Icons.event_available_outlined, value: "${overview?.upcomingEvents ?? eventProv.events.length}", label: "Upcoming"),
                    ],
                  ),
                ),
                if (overview?.nextRegisteredEvent != null) ...[
                  const SizedBox(height: 14),
                  _nextEventCard(overview!.nextRegisteredEvent!),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _kategoriList.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final label = _kategoriList[i] ?? 'Semua';
                      final selected = _selectedKategori == _kategoriList[i];
                      return FilterChip(
                        label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.grey.shade700, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _selectedKategori = _kategoriList[i]);
                          if (context.mounted) {
                            context.read<EventProvider>().loadEvents(kategori: _kategoriList[i]);
                          }
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
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    if (context.mounted) {
                      Navigator.push(context, RouteTransitions.slideFromRight(const InformasiListScreen()));
                    }
                  },
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
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    if (context.mounted) {
                      final prov = context.read<RecommendationProvider>();
                      prov.loadRecommendedEvents();
                      prov.loadInterests();
                      Navigator.push(context, RouteTransitions.slideFromRight(const InterestScreen()));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.auto_awesome, size: 18, color: Colors.orange),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: Text("Atur Minat & Rekomendasi Event", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                        const Icon(Icons.chevron_right, size: 18, color: Colors.orange),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Jadwal Minggu Ini", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text(DateFormatter.monthName(now.month), style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 95,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Jadwal Kuliah Hari Ini", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Lihat Semua", style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (eventProv.state == LoadState.loading)
                  const ShimmerLoading(itemCount: 2, itemHeight: 90, padding: EdgeInsets.zero)
                else if (eventProv.state == LoadState.error)
                  ErrorDisplayWidget(message: eventProv.error ?? 'Gagal memuat', onRetry: () {
                    if (context.mounted) {
                      context.read<EventProvider>().loadEvents();
                    }
                  })
                else if (eventProv.eventsForDate(now).isEmpty)
                  const EmptyStateWidget(icon: Icons.event_busy, title: "Tidak ada jadwal", subtitle: "Tidak ada jadwal kuliah hari ini")
                else
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 45, color: Colors.white.withValues(alpha: 0.2));

  Widget _notificationIcon(int unreadCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.notifications_none_rounded, size: 26, color: Colors.grey.shade700),
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

  Widget _nextEventCard(Map<String, dynamic> event) {
    final title = event['judul']?.toString() ?? 'Event terdaftar';
    final location = event['lokasi']?.toString() ?? '-';
    final date = event['tanggal']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.event_available_rounded, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Event terdaftar berikutnya', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('$location • ${DateFormatter.formatTime(date)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
