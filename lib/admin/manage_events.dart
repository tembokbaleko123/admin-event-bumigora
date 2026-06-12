import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/utils/route_transitions.dart';
import 'package:aplikasi_kampus/models/event_model.dart';
import 'package:aplikasi_kampus/providers/event_provider.dart';
import 'package:aplikasi_kampus/InApp/event_detail.dart';

class ManageEventsScreen extends StatefulWidget {
  final String? initialStatusFilter;

  const ManageEventsScreen({super.key, this.initialStatusFilter});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  String? _statusFilter;
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'tanggal';
  String _sortOrder = 'desc';
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  final _filters = <String?>[
    null,
    AppStrings.statusPending,
    AppStrings.statusPublished,
    AppStrings.statusRejected,
    AppStrings.statusCancelled,
    AppStrings.statusCompleted,
  ];

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.initialStatusFilter;
    _scrollCtrl.addListener(() {
      if (!_scrollCtrl.hasClients) return;
      final position = _scrollCtrl.position;
      if (position.pixels > position.maxScrollExtent - 260) {
        context.read<EventProvider>().loadMoreEvents();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _loadEvents({bool force = false}) {
    context.read<EventProvider>().loadEvents(
      status: _statusFilter,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      tanggalMulai: _tanggalMulai != null
          ? '${_tanggalMulai!.year}-${_tanggalMulai!.month.toString().padLeft(2, '0')}-${_tanggalMulai!.day.toString().padLeft(2, '0')}'
          : null,
      tanggalSelesai: _tanggalSelesai != null
          ? '${_tanggalSelesai!.year}-${_tanggalSelesai!.month.toString().padLeft(2, '0')}-${_tanggalSelesai!.day.toString().padLeft(2, '0')}'
          : null,
      force: force,
    );
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _tanggalMulai != null && _tanggalSelesai != null
          ? DateTimeRange(start: _tanggalMulai!, end: _tanggalSelesai!)
          : null,
    );
    if (range != null) {
      setState(() {
        _tanggalMulai = range.start;
        _tanggalSelesai = range.end;
      });
      _loadEvents(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<EventProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.titleKelolaEvent)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(Responsive.padding(context), 8, Responsive.padding(context), 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Cari event...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); _loadEvents(force: true); })
                          : null,
                    ),
                    onChanged: (v) { setState(() => _searchQuery = v); _loadEvents(force: true); },
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  tooltip: 'Urutkan',
                  onSelected: (v) {
                    final parts = v.split(':');
                    setState(() { _sortBy = parts[0]; _sortOrder = parts[1]; });
                    _loadEvents(force: true);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'tanggal:desc', child: Text('Terbaru')),
                    const PopupMenuItem(value: 'tanggal:asc', child: Text('Terlama')),
                    const PopupMenuItem(value: 'judul:asc', child: Text('A-Z')),
                    const PopupMenuItem(value: 'judul:desc', child: Text('Z-A')),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.date_range, color: _tanggalMulai != null ? AppColors.primary : null),
                  tooltip: 'Filter tanggal',
                  onPressed: _pickDateRange,
                ),
                if (_tanggalMulai != null || _searchQuery.isNotEmpty || _sortBy != 'tanggal' || _sortOrder != 'desc')
                  IconButton(
                    icon: const Icon(Icons.filter_alt_off, size: 20),
                    tooltip: 'Reset filter',
                    onPressed: () {
                      setState(() {
                        _searchCtrl.clear();
                        _searchQuery = '';
                        _sortBy = 'tanggal';
                        _sortOrder = 'desc';
                        _tanggalMulai = null;
                        _tanggalSelesai = null;
                      });
                      _loadEvents(force: true);
                    },
                  ),
              ],
            ),
          ),
          _filterChips(),
          Expanded(
            child: prov.state == LoadState.loading
                ? const ShimmerLoading(itemCount: 4, itemHeight: 118)
                : prov.state == LoadState.error
                    ? ErrorDisplayWidget(
                        message: prov.error ?? 'Gagal memuat',
                        onRetry: () => _loadEvents(force: true),
                      )
                    : prov.events.isEmpty
                        ? const EmptyStateWidget(icon: Icons.event_busy, title: AppStrings.emptyEvent)
                        : RefreshIndicator(
                            onRefresh: () async => _loadEvents(force: true),
                            child: ListView.builder(
                              controller: _scrollCtrl,
                              padding: Responsive.screenPadding(context),
                              itemCount: prov.events.length + 1,
                              itemBuilder: (_, i) {
                                if (i == prov.events.length) return _loadMoreFooter(prov);
                                return _eventCard(prov.events[i], i);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _loadMoreFooter(EventProvider prov) {
    if (!prov.hasMore) return const SizedBox(height: 24);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Center(
        child: prov.isLoadingMore
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: () => prov.loadMoreEvents(),
                child: const Text(AppStrings.muatLagi),
              ),
      ),
    );
  }

  Widget _filterChips() {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final status = _filters[index];
          final selected = _statusFilter == status;
          return FilterChip(
            label: Text(_statusLabel(status)),
            selected: selected,
            selectedColor: AppColors.primary,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.grey.shade700,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            onSelected: (_) {
              setState(() => _statusFilter = status);
              _loadEvents(force: true);
            },
          );
        },
      ),
    );
  }

  Widget _eventCard(EventModel event, int index) {
    return AnimatedListItem(
      index: index,
      child: Dismissible(
        key: ValueKey('event_${event.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmDelete(event),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.delete_outline, color: Colors.red),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _statusColor(event.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.event, color: _statusColor(event.status), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.judul,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _statusBadge(event.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${event.tanggal} - ${event.lokasi}",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (event.creator != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            "Dibuat oleh ${event.creator!.nama}",
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 20, color: AppColors.primary),
                    onPressed: () => Navigator.push(
                      context,
                      RouteTransitions.slideFromRight(EventDetailScreen(eventId: event.id, title: event.judul)),
                    ).then((_) {
                      if (mounted) _loadEvents(force: true);
                    }),
                  ),
                ],
              ),
              if (event.status == AppStrings.statusPending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleApproval(event, approve: false),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Tolak'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleApproval(event, approve: true),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Setujui'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(EventModel event) async {
    final provider = context.read<EventProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.confirmHapusEvent),
        content: Text('${AppStrings.msgYakinHapus} ${event.judul}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.batal)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AppStrings.hapus, style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return false;
    final ok = await provider.deleteEvent(event.id);
    if (mounted) {
      SnackbarHelper.show(context, ok ? AppStrings.successEventDihapusSingkat : provider.error ?? AppStrings.errorGagalEventDihapus, isError: !ok);
    }
    return ok;
  }

  Future<void> _handleApproval(EventModel event, {required bool approve}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(approve ? AppStrings.confirmSetujuiEvent : AppStrings.confirmTolakEvent),
        content: Text(approve
            ? 'Setujui ${event.judul} dan publikasikan ke mahasiswa?'
            : 'Tolak ${event.judul}? Event tidak akan tampil untuk mahasiswa.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.batal)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(approve ? 'Setujui' : 'Tolak')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<EventProvider>();
    final ok = approve ? await provider.approveEvent(event.id) : await provider.rejectEvent(event.id);

    if (!mounted) return;
    SnackbarHelper.show(context, ok ? (approve ? AppStrings.successEventDisetujui : AppStrings.successEventDitolak) : provider.error ?? AppStrings.errorGagalMemprosesEvent, isError: !ok);
  }

  Widget _statusBadge(String? status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(
        _statusLabel(status),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
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
      case AppStrings.statusCancelled:
        return Colors.grey;
      case AppStrings.statusCompleted:
        return Colors.blueGrey;
      default:
        return AppColors.primary;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case null:
        return AppStrings.labelSemua;
      case AppStrings.statusPending:
        return AppStrings.labelPending;
      case AppStrings.statusPublished:
        return AppStrings.labelPublished;
      case AppStrings.statusRejected:
        return AppStrings.labelDitolak;
      case AppStrings.statusCancelled:
        return AppStrings.labelDibatalkan;
      case AppStrings.statusCompleted:
        return AppStrings.labelSelesai;
      default:
        return status;
    }
  }
}
