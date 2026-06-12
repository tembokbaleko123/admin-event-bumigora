import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/utils/route_transitions.dart';
import 'package:aplikasi_kampus/admin/manage_events.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/providers/analytics_provider.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}
class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadDashboardOverview();
      context.read<AnalyticsProvider>().loadAdminSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AnalyticsProvider>();
    final summary = ap.summary;
    final overview = ap.overview;

    return Scaffold(
      
      appBar: AppBar(
        title: const Text("Dashboard Analytics",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ap.isLoading
          ? const ShimmerLoading()
          : summary == null
              ? const Center(child: Text("Gagal memuat data"))
              : RefreshIndicator(
                  onRefresh: () async {
                    await Future.wait([
                      ap.loadDashboardOverview(),
                      ap.loadAdminSummary(),
                    ]);
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (overview != null && overview.role == 'admin') ...[
                        _section("Operasional Hari Ini"),
                        const SizedBox(height: 12),
                        Row(children: [
                          _statCard("Event Hari Ini", overview.todayEvents.toString(), Colors.indigo, Icons.today),
                          const SizedBox(width: 8),
                          _actionStatCard(
                            "Pending Approval",
                            overview.adminPendingEvents.toString(),
                            Colors.orange,
                            Icons.pending_actions,
                            () => Navigator.push(
                              context,
                              RouteTransitions.slideFromRight(
                                const ManageEventsScreen(initialStatusFilter: AppStrings.statusPending),
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          _statCard("Upcoming", overview.upcomingEvents.toString(), Colors.green, Icons.upcoming),
                          const SizedBox(width: 8),
                          _statCard("Audit Hari Ini", overview.adminAuditToday.toString(), Colors.deepOrange, Icons.history),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          _statCard("Notifikasi", overview.unreadNotifications.toString(), Colors.pink, Icons.notifications_active),
                          const SizedBox(width: 8),
                          const Spacer(),
                        ]),
                        const SizedBox(height: 24),
                      ],
                      _section("Users"),
                      const SizedBox(height: 12),
                      Row(children: [
                        _statCard("Total", summary.totalUsers.toString(), Colors.blue, Icons.people),
                        const SizedBox(width: 8),
                        _statCard("Mahasiswa", summary.totalMahasiswa.toString(), Colors.green, Icons.school),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        _statCard("Dosen", summary.totalDosen.toString(), Colors.orange, Icons.person),
                        const SizedBox(width: 8),
                        _statCard("Admin", summary.totalAdmin.toString(), Colors.red, Icons.admin_panel_settings),
                      ]),
                      const SizedBox(height: 24),

                      _section("Konten & Partisipasi"),
                      const SizedBox(height: 12),
                      Row(children: [
                        _statCard("Event", summary.totalEvents.toString(), AppColors.primary, Icons.event),
                        const SizedBox(width: 8),
                        _statCard("Informasi", summary.totalInformasi.toString(), Colors.purple, Icons.info),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        _statCard("Pendaftar", summary.totalRegistrations.toString(), Colors.teal, Icons.assignment),
                        const SizedBox(width: 8),
                        _statCard("Hadir", "${summary.avgAttendance}%", Colors.green, Icons.check_circle),
                      ]),
                      const SizedBox(height: 24),

                      if (summary.categoryStats.isNotEmpty) ...[
                        _section("Event per Kategori"),
                        const SizedBox(height: 12),
                        _categoryChart(summary.categoryStats),
                        const SizedBox(height: 24),
                      ],

                      if (summary.eventMonthly.isNotEmpty) ...[
                        _section("Event per Bulan (6 bln terakhir)"),
                        const SizedBox(height: 12),
                        _monthlyChart(summary.eventMonthly),
                        const SizedBox(height: 24),
                      ],

                      if (summary.popularEvents.isNotEmpty) ...[
                        _section("Event Terpopuler"),
                        const SizedBox(height: 12),
                        ...summary.popularEvents.map((e) => _popularEventCard(e)),
                      ],
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
    return Expanded(
      child: _statCardContent(label, value, color, icon),
    );
  }

  Widget _actionStatCard(String label, String value, Color color, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: _statCardContent(label, value, color, icon),
      ),
    );
  }

  Widget _statCardContent(String label, String value, Color color, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return Container(
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
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _categoryChart(List<dynamic> data) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: data.isEmpty
              ? 1
              : (data.map((e) => (e['total'] as num?)?.toDouble() ?? 0).reduce(
                      (a, b) => a > b ? a : b)) *
                  1.2,
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: (entry.value['total'] is num ? (entry.value['total'] as num).toDouble() : 0),
                  color: AppColors.primary,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < data.length) {
                    final label = data[idx]['kategori'] ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(label.toString(),
                          style: const TextStyle(fontSize: 10)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _monthlyChart(List<dynamic> data) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: data.isEmpty
              ? 1
              : (data.map((e) => (e['total'] as num?)?.toDouble() ?? 0).reduce(
                      (a, b) => a > b ? a : b)) *
                  1.3,
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(),
                    (entry.value['total'] is num ? (entry.value['total'] as num).toDouble() : 0));
              }).toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: Colors.green,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withValues(alpha: 0.1),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < data.length) {
                    final bulan = data[idx]['bulan'] ?? '';
                    final parts = bulan.toString().split('-');
                    final label = parts.length >= 2 ? parts[1] : bulan;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(label, style: const TextStyle(fontSize: 10)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _popularEventCard(dynamic event) {
    final cs = Theme.of(context).colorScheme;
    final judul = event['judul'] ?? 'Event';
    final pendaftar = event['pendaftar'] ?? 0;
    final tanggal = event['tanggal'] ?? '';
    final lokasi = event['lokasi'] ?? '';

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
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events, color: Colors.amber),
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
                Text("$lokasi • $tanggal",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text("$pendaftar",
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
