import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/providers/analytics_provider.dart';

class LecturerAnalyticsScreen extends StatefulWidget {
  const LecturerAnalyticsScreen({super.key});

  @override
  State<LecturerAnalyticsScreen> createState() =>
      _LecturerAnalyticsScreenState();
}

class _LecturerAnalyticsScreenState extends State<LecturerAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadLecturerData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AnalyticsProvider>();
    final summary = ap.lecturerSummary;

    return Scaffold(
      
      appBar: AppBar(
        title: const Text("Analytics Saya",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ap.isLoading
          ? const ShimmerLoading()
          : summary == null
              ? const Center(child: Text("Gagal memuat data"))
              : RefreshIndicator(
                  onRefresh: () => ap.loadLecturerData(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _section("Ringkasan"),
                      const SizedBox(height: 12),
                      Row(children: [
                        _statCard("Event", summary.totalEvents.toString(),
                            AppColors.primary, Icons.event),
                        const SizedBox(width: 8),
                        _statCard("Pendaftar", summary.totalPendaftar.toString(),
                            Colors.blue, Icons.people),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        _statCard("Hadir", summary.totalHadir.toString(),
                            Colors.green, Icons.check_circle),
                        const SizedBox(width: 8),
                        _statCard("Kehadiran",
                            "${summary.avgAttendance.toStringAsFixed(1)}%",
                            Colors.orange, Icons.trending_up),
                      ]),
                      const SizedBox(height: 24),

                      _section("Daftar Event"),
                      const SizedBox(height: 12),
                      if (ap.lecturerEvents.isEmpty)
                      const EmptyStateWidget(title: 'Belum ada event', icon: Icons.event_note)
                      else
                        ...ap.lecturerEvents.map((e) => _eventCard(e)),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _section(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _eventCard(dynamic event) {
    final cs = Theme.of(context).colorScheme;
    final judul = event['judul'] ?? 'Event';
    final tanggal = event['tanggal'] ?? '';
    final pendaftar = event['total_pendaftar'] ?? 0;
    final aktif = event['pendaftar_aktif'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text(tanggal.toString(),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
              ],
            ),
          ),
          Column(
            children: [
              Text("$pendaftar",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text("Pendaftar",
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 10)),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text("$aktif",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green)),
              Text("Aktif",
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
