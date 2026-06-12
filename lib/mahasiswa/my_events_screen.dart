import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/InApp/event_detail.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/utils/date_formatter.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/utils/route_transitions.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/models/event_registration.dart';
import 'package:aplikasi_kampus/providers/registration_provider.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  int _tab = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() => _tab = _tabController.index);
      }
    });
    _scrollCtrl.addListener(() {
      if (!_scrollCtrl.hasClients) return;
      final position = _scrollCtrl.position;
      if (position.pixels > position.maxScrollExtent - 240) {
        context.read<RegistrationProvider>().loadMoreMyEvents();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RegistrationProvider>().loadMyEvents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();
    final events = _filterEvents(_eventsForTab(provider.myEvents));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Saya'),
        actions: [
          IconButton(
            onPressed: provider.isLoading
                ? null
                : () => context.read<RegistrationProvider>().loadMyEvents(),
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Mendatang'),
            Tab(text: 'Riwayat'),
            Tab(text: 'Batal'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari event saya...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const ShimmerLoading(itemCount: 4, itemHeight: 108)
                : provider.error != null
                    ? ErrorDisplayWidget(
                        message: provider.error ?? 'Gagal memuat event saya',
                        onRetry: () => context.read<RegistrationProvider>().loadMyEvents(),
                      )
                    : events.isEmpty
                        ? _emptyState()
                        : RefreshIndicator(
                            onRefresh: () => context.read<RegistrationProvider>().loadMyEvents(),
                            child: ListView.builder(
                              controller: _scrollCtrl,
                              padding: Responsive.screenPadding(context),
                              itemCount: events.length + 1,
                              itemBuilder: (context, index) {
                                if (index == events.length) return _loadMoreFooter(provider);
                                return _eventTile(events[index], index);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    final title = _tab == 0
        ? 'Belum ada event mendatang'
        : _tab == 1
            ? 'Belum ada riwayat event'
            : 'Tidak ada pendaftaran batal';
    final subtitle = _tab == 0
        ? 'Event yang kamu daftarkan akan tampil di sini.'
        : 'Data akan muncul setelah status pendaftaran berubah.';

    return EmptyStateWidget(
      icon: _tab == 2 ? Icons.event_busy : Icons.event_available_outlined,
      title: title,
      subtitle: subtitle,
    );
  }

  Widget _eventTile(EventRegistration registration, int index) {
    final event = registration.event;
    final title = event?.judul ?? 'Event #${registration.eventId}';
    final location = event?.lokasi ?? '-';
    final date = event?.tanggal ?? registration.registeredAt ?? '';
    final category = event?.kategori ?? 'EVENT';

    return AnimatedListItem(
      index: index,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openDetail(registration),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _statusColor(registration.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.event_available_rounded,
                      color: _statusColor(registration.status)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _statusBadge(registration.status),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              category,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${DateFormatter.formatTime(date)} - $location',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadMoreFooter(RegistrationProvider provider) {
    if (!provider.myEventsHasMore) return const SizedBox(height: 24);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Center(
        child: provider.myEventsLoadingMore
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: () => provider.loadMoreMyEvents(),
                child: const Text('Muat lagi'),
              ),
      ),
    );
  }

  Future<void> _openDetail(EventRegistration registration) async {
    final event = registration.event;
    final changed = await Navigator.push<bool>(
      context,
      RouteTransitions.slideFromRight(
        EventDetailScreen(
          eventId: registration.eventId,
          title: event?.judul,
          location: event?.lokasi,
          time: event == null ? null : DateFormatter.formatTime(event.tanggal),
          type: event?.kategori,
        ),
      ),
    );

    if (changed == true && mounted) {
      context.read<RegistrationProvider>().loadMyEvents();
    }
  }

  List<EventRegistration> _eventsForTab(List<EventRegistration> registrations) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool isPast(EventRegistration registration) {
      final eventDate = DateTime.tryParse(registration.event?.tanggal ?? '');
      if (eventDate == null) return false;
      return eventDate.isBefore(today);
    }

    if (_tab == 0) {
      return registrations
          .where((registration) => registration.isRegistered && !isPast(registration))
          .toList();
    }
    if (_tab == 1) {
      return registrations
          .where((registration) =>
              !registration.isCancelled &&
              (registration.isAttended || registration.isAbsent || isPast(registration)))
          .toList();
    }
    return registrations.where((registration) => registration.isCancelled).toList();
  }

  List<EventRegistration> _filterEvents(List<EventRegistration> registrations) {
    if (_query.isEmpty) return registrations;
    return registrations.where((registration) {
      final event = registration.event;
      final haystack = [
        event?.judul,
        event?.lokasi,
        event?.kategori,
        registration.status,
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(_query);
    }).toList();
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case AppStrings.statusRegistered:
        return AppColors.primary;
      case AppStrings.statusAttended:
        return Colors.green;
      case AppStrings.statusAbsent:
        return Colors.red;
      case AppStrings.statusCancelled:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case AppStrings.statusRegistered:
        return 'Terdaftar';
      case AppStrings.statusAttended:
        return 'Hadir';
      case AppStrings.statusAbsent:
        return 'Tidak Hadir';
      case AppStrings.statusCancelled:
        return 'Batal';
      default:
        return status;
    }
  }
}
