import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/providers/registration_provider.dart';
import 'package:aplikasi_kampus/providers/attendance_provider.dart';

class ParticipantsScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const ParticipantsScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();
  String? _statusFilter;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _isMarking = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _statusFilter = [AppStrings.statusRegistered, AppStrings.statusAttended, AppStrings.statusAbsent, null][_tabController.index];
        });
        _loadParticipants();
      }
    });
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadParticipants());
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final regProv = context.read<RegistrationProvider>();
      if (!regProv.participantsLoadingMore && regProv.participantsHasMore) {
        regProv.loadMoreParticipants(widget.eventId, status: _statusFilter);
      }
    }
  }

  void _loadParticipants() {
    context.read<RegistrationProvider>().loadParticipants(
          widget.eventId,
          status: _statusFilter,
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final regProv = context.watch<RegistrationProvider>();
    var participants = regProv.participants;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      participants = participants.where((r) =>
        (r.user?.nama ?? '').toLowerCase().contains(q) ||
        (r.user?.email ?? '').toLowerCase().contains(q)
      ).toList();
    }

    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          AppStrings.titlePeserta,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: AppStrings.labelTerdaftar),
            Tab(text: AppStrings.labelHadir),
            Tab(text: AppStrings.labelTidakHadir),
            Tab(text: AppStrings.labelSemua),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari peserta...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: regProv.isLoading
              ? const ShimmerLoading()
              : participants.isEmpty
                  ? const EmptyStateWidget(title: AppStrings.emptyPeserta, icon: Icons.people_outline)
                  : RefreshIndicator(
                  onRefresh: () async => _loadParticipants(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: participants.length + (regProv.participantsLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == participants.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }
                      final reg = participants[index];
                      final user = reg.user;
                      final nama = user?.nama ?? '';
                      final initial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                initial,
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.nama ?? 'Unknown',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    user?.email ?? '',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            _statusBadge(reg.status),
                            PopupMenuButton<String>(
                              enabled: !_isMarking,
                              tooltip: AppStrings.ubahStatus,
                              onSelected: (status) => _confirmAndMark(reg.user?.id ?? 0, status),
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: AppStrings.statusValid, child: Text(AppStrings.tandaiHadir)),
                                PopupMenuItem(value: AppStrings.statusLate, child: Text(AppStrings.tandaiTerlambat)),
                                PopupMenuItem(value: AppStrings.statusAbsent, child: Text(AppStrings.tandaiTidakHadir)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Future<void> _confirmAndMark(int userId, String newStatus) async {
    if (userId == 0) return;
    final labels = <String, String>{
      AppStrings.statusValid: 'Hadir',
      AppStrings.statusLate: 'Terlambat',
      AppStrings.statusAbsent: 'Tidak Hadir',
    };
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.confirmUbahStatus),
        content: Text('Tandai peserta ini sebagai "${labels[newStatus] ?? newStatus}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.batal)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AppStrings.yaUbah)),
        ],
      ),
    );
    if (confirmed == true) {
      await _markAttendance(userId, newStatus);
    }
  }

  Future<void> _markAttendance(int userId, String status) async {
    if (userId == 0) return;
    setState(() => _isMarking = true);

    final attendance = context.read<AttendanceProvider>();
    final registrations = context.read<RegistrationProvider>();

    final ok = await attendance.markManualAttendance(widget.eventId, userId, status);
    if (mounted) setState(() => _isMarking = false);
    if (!mounted) return;

    if (ok) {
      SnackbarHelper.show(context, AppStrings.successStatusKehadiran);
      await registrations.loadParticipants(widget.eventId, status: _statusFilter);
    } else {
      SnackbarHelper.show(context, attendance.error ?? AppStrings.errorGagalKehadiran, isError: true);
    }
  }

  Widget _statusBadge(String? status) {
    Color color;
    String label;

    switch (status) {
      case AppStrings.statusRegistered:
        color = Colors.blue;
        label = 'Terdaftar';
        break;
      case AppStrings.statusAttended:
        color = Colors.green;
        label = 'Hadir';
        break;
      case AppStrings.statusAbsent:
        color = Colors.red;
        label = 'Tidak Hadir';
        break;
      case AppStrings.statusCancelled:
        color = Colors.orange;
        label = 'Batal';
        break;
      default:
        color = Colors.grey;
        label = status ?? '-';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
