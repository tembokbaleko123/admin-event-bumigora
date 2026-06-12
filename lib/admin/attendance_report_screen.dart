import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/theme/theme_extensions.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/models/attendance.dart';
import 'package:aplikasi_kampus/providers/attendance_provider.dart';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';

class AttendanceReportScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const AttendanceReportScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _statusFilter;
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  int? _selectedPeriod; // null = all, 7, 30, 90

  static const _periods = <int?>[null, 7, 30, 90];
  static const _periodLabels = [AppStrings.labelSemua, '7 Hari', '30 Hari', '90 Hari'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _statusFilter = [null, AppStrings.statusValid, AppStrings.statusLate][_tabController.index];
        });
        _loadReport();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReport());
  }

  void _loadReport() {
    context.read<AttendanceProvider>().loadReport(
          widget.eventId,
          status: _statusFilter,
          tanggalMulai: _tanggalMulai,
          tanggalSelesai: _tanggalSelesai,
        );
  }

  void _setPeriod(int? days) {
    setState(() {
      _selectedPeriod = days;
      if (days == null) {
        _tanggalMulai = null;
        _tanggalSelesai = null;
      } else {
        _tanggalSelesai = DateTime.now();
        _tanggalMulai = DateTime.now().subtract(Duration(days: days));
      }
    });
    _loadReport();
  }

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _tanggalMulai != null && _tanggalSelesai != null
          ? DateTimeRange(start: _tanggalMulai!, end: _tanggalSelesai!)
          : null,
    );
    if (range != null) {
      setState(() {
        _tanggalMulai = range.start;
        _tanggalSelesai = range.end;
        _selectedPeriod = null;
      });
      _loadReport();
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    final prov = context.read<AttendanceProvider>();
    final csvBytes = await prov.exportCsv(widget.eventId, tanggalMulai: _tanggalMulai, tanggalSelesai: _tanggalSelesai);
    if (csvBytes == null) {
      if (!context.mounted) return;
      SnackbarHelper.show(context, AppStrings.errorGagalEkspor, isError: true);
      return;
    }
    try {
      final filename = 'absensi_${widget.eventTitle.replaceAll(RegExp(r'[^\w]'), '_')}.csv';
      final xfile = XFile.fromData(Uint8List.fromList(csvBytes), name: filename, mimeType: 'text/csv');
      await Share.shareXFiles([xfile], text: 'Laporan Absensi: ${widget.eventTitle}');
    } catch (e) {
      if (!context.mounted) return;
      SnackbarHelper.show(context, 'Gagal membagikan: $e', isError: true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attProv = context.watch<AttendanceProvider>();
    final attendances = attProv.attendances;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: context.surfaceColor,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 18, color: context.onSurfaceColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(AppStrings.titleLaporan,
            style: TextStyle(color: context.onSurfaceColor, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.download_outlined, color: context.onSurfaceColor.withValues(alpha: 0.6)),
            tooltip: AppStrings.labelExportCSV,
            onPressed: () => _exportCsv(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: AppStrings.labelSemua),
            Tab(text: AppStrings.labelTepatWaktu),
            Tab(text: AppStrings.labelTerlambat),
          ],
        ),
      ),
      body: Column(
        children: [
          _periodFilter(),
          _summaryCards(),
          Expanded(
            child: attProv.isLoading
                ? const ShimmerLoading()
                : attendances.isEmpty
                    ? const EmptyStateWidget(title: AppStrings.emptyDataAbsensi, icon: Icons.receipt_long)
                    : RefreshIndicator(
                        onRefresh: () async => _loadReport(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: attendances.length,
                          itemBuilder: (context, index) {
                            final att = attendances[index];
                            return _attendanceCard(att);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _periodFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...List.generate(_periods.length, (i) {
              final isSelected = _selectedPeriod == _periods[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_periodLabels[i], style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  onSelected: (_) => _setPeriod(_periods[i]),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: const Icon(Icons.date_range, size: 16),
                label: Text(
                  _tanggalMulai != null && _selectedPeriod == null
                      ? '${_tanggalMulai!.day}/${_tanggalMulai!.month} - ${_tanggalSelesai!.day}/${_tanggalSelesai!.month}'
                      : AppStrings.labelCustom,
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed: _pickCustomRange,
              ),
            ),
            if (_tanggalMulai != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  avatar: const Icon(Icons.close, size: 16),
                  label: const Text(AppStrings.labelReset, style: TextStyle(fontSize: 12)),
                  onPressed: () => _setPeriod(null),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCards() {
    final attProv = context.watch<AttendanceProvider>();
    final attendances = attProv.attendances;
    final total = attendances.length;
    final valid = attendances.where((a) => a.status == AppStrings.statusValid).length;
    final late = attendances.where((a) => a.status == AppStrings.statusLate).length;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _summaryCard(AppStrings.labelTotalHadir, "$total", Colors.green, Icons.check_circle),
          const SizedBox(width: 8),
          _summaryCard(AppStrings.labelTepatWaktu, "$valid", Colors.blue, Icons.access_time),
          const SizedBox(width: 8),
          _summaryCard(AppStrings.labelTerlambat, "$late", Colors.orange, Icons.warning_amber),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _attendanceCard(Attendance att) {
    final nama = att.user?.nama ?? 'Unknown';
    final email = att.user?.email ?? '';

    Color statusColor;
    String statusLabel;
    switch (att.status) {
      case AppStrings.statusValid:
        statusColor = Colors.green;
        statusLabel = 'Tepat Waktu';
        break;
      case AppStrings.statusLate:
        statusColor = Colors.orange;
        statusLabel = 'Terlambat';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = att.status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.1),
            child: Text(
              nama.isNotEmpty ? nama[0].toUpperCase() : '?',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (email.isNotEmpty)
                  Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  _formatScanTime(att.scannedAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatScanTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB";
    } catch (_) {
      return iso;
    }
  }
}
