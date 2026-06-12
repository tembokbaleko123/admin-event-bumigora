import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/theme/theme_extensions.dart';
import 'package:aplikasi_kampus/providers/notifikasi_provider.dart';
import 'package:aplikasi_kampus/providers/event_provider.dart';
import 'package:aplikasi_kampus/services/user_service.dart';
import 'package:aplikasi_kampus/admin/manage_events.dart';
import 'package:aplikasi_kampus/admin/manage_users.dart';
import 'package:aplikasi_kampus/admin/manage_informasi.dart';
import 'package:aplikasi_kampus/admin/analytics_screen.dart';
import 'package:aplikasi_kampus/func/profile.dart';

class AdminNavigation extends StatefulWidget {
  final UserService userService;
  const AdminNavigation({super.key, required this.userService});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int _index = 0;

  late final _pages = [
    const AdminAnalyticsScreen(), // Changed from ManageEventsScreen to analytics dashboard
    const ManageEventsScreen(),
    ManageUsersScreen(userService: widget.userService),
    const ManageInformasiScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotifikasiProvider>().load();
      context.read<EventProvider>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: context.surfaceColor, boxShadow: [BoxShadow(color: context.onSurfaceColor.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4))]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.dashboard_outlined, Icons.dashboard, AppStrings.labelDashboard),
                _navItem(1, Icons.event_outlined, Icons.event, AppStrings.labelEvent),
                _navItem(2, Icons.people_outline, Icons.people, AppStrings.labelPengguna),
                _navItem(3, Icons.article_outlined, Icons.article, AppStrings.labelInfo),
                _navItem(4, Icons.person_outline, Icons.person, AppStrings.titleProfil),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, IconData active, String label) {
    final active_ = _index == i;
    return GestureDetector(
      onTap: () => setState(() => _index = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: active_ ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent, borderRadius: BorderRadius.circular(14)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active_ ? active : icon, color: active_ ? AppColors.primary : Colors.grey, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: active_ ? AppColors.primary : Colors.grey, fontSize: 11, fontWeight: active_ ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
