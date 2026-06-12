import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/theme/theme_extensions.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/models/analytics.dart';
import 'package:aplikasi_kampus/providers/analytics_provider.dart';

class EventAnalyticsScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const EventAnalyticsScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<EventAnalyticsScreen> createState() => _EventAnalyticsScreenState();
}

class _EventAnalyticsScreenState extends State<EventAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadEventAnalytics(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AnalyticsProvider>();
    final analytics = ap.eventAnalytics;

    return Scaffold(
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
        title: Text(
          'Analytics Event',
          style: TextStyle(color: context.onSurfaceColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ap.eventAnalyticsLoading
          ? const ShimmerLoading()
          : ap.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error.withValues(alpha: 0.6)),
                        const SizedBox(height: 16),
                        Text(ap.error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => ap.loadEventAnalytics(widget.eventId),
                          icon: const Icon(Icons.refresh),
                          label: const Text(AppStrings.cobaLagi),
                        ),
                      ],
                    ),
                  ),
                )
              : analytics == null
                  ? const Center(child: Text('Tidak ada data'))
                  : RefreshIndicator(
                      onRefresh: () => ap.loadEventAnalytics(widget.eventId),
                      child: ListView(
                        padding: EdgeInsets.all(Responsive.screenPadding(context).left),
                        children: [
                          _headerCard(analytics),
                          const SizedBox(height: 16),
                          _statsGrid(analytics),
                          const SizedBox(height: 16),
                          _attendanceCard(analytics),
                        ],
                      ),
                    ),
    );
  }

  Widget _headerCard(EventAnalytics analytics) {
    final judul = analytics.event['judul'] ?? widget.eventTitle;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF8C8EF1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _headerStat(Icons.people_outline, 'Tingkat Kehadiran', '${analytics.attendanceRate}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _statsGrid(EventAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Statistik Pendaftaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _statCard(Icons.people, 'Total Daftar', analytics.totalPendaftar.toString(), AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _statCard(Icons.person_pin, 'Aktif', analytics.pendaftarAktif.toString(), Colors.teal)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statCard(Icons.group, 'Kuota', analytics.kapasitas?.toString() ?? '-', Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _statCard(Icons.flight_takeoff, 'Sisa', analytics.sisaKuota?.toString() ?? '-', Colors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _attendanceCard(EventAnalytics analytics) {
    final total = analytics.totalHadir;
    final tepat = analytics.totalTepat;
    final terlambat = analytics.totalTerlambat;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rincian Kehadiran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _attendanceRow(Icons.check_circle, 'Hadir', total.toString(), Colors.green),
          const SizedBox(height: 8),
          _attendanceRow(Icons.access_time, 'Tepat Waktu', tepat.toString(), Colors.blue),
          const SizedBox(height: 8),
          _attendanceRow(Icons.warning_amber, 'Terlambat', terlambat.toString(), Colors.orange),
          if (analytics.totalPendaftar > 0) ...[
            const Divider(height: 24),
            _attendanceRow(
              Icons.trending_up,
              'Persentase Hadir',
              '${((total / analytics.totalPendaftar) * 100).toStringAsFixed(1)}%',
              AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _attendanceRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
      ],
    );
  }
}
