import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/mahasiswa/dashboard_mhs.dart';
import 'package:aplikasi_kampus/mahasiswa/my_events_screen.dart';
import 'package:aplikasi_kampus/Navigation/calendar.dart';
import 'package:aplikasi_kampus/func/profile.dart';
import 'package:aplikasi_kampus/providers/notifikasi_provider.dart';

class MainNavigationStudent extends StatefulWidget {
  const MainNavigationStudent({super.key});

  @override
  State<MainNavigationStudent> createState() => _MainNavigationStudentState();
}

class _MainNavigationStudentState extends State<MainNavigationStudent> {
  int _index = 0;
  bool _isInitialized = false;

  final _screens = const [
    StudentDashboardScreen(),
    MyEventsScreen(),
    CalendarViewAllScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load notifications after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _isInitialized = true;
        _loadNotifications();
      }
    });
  }

  void _loadNotifications() {
    if (!mounted) return;
    try {
      context.read<NotifikasiProvider>().load();
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotifikasiProvider>().unreadCount;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, -4)),
        ]),
        child: BottomNavigationBar(
          currentIndex: _index,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => _index = i),
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), activeIcon: Icon(Icons.grid_view_rounded, color: AppColors.primary), label: AppStrings.labelBeranda),
            const BottomNavigationBarItem(icon: Icon(Icons.event_available_outlined), activeIcon: Icon(Icons.event_available_rounded, color: AppColors.primary), label: AppStrings.labelEventSaya),
            const BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today_rounded, color: AppColors.primary), label: AppStrings.labelJadwal),
            BottomNavigationBarItem(
              icon: Badge(isLabelVisible: unread > 0, label: Text('$unread'), child: const Icon(Icons.person_outline_rounded)),
              activeIcon: Badge(isLabelVisible: unread > 0, label: Text('$unread'), child: const Icon(Icons.person_rounded, color: AppColors.primary)),
              label: AppStrings.titleProfil,
            ),
          ],
        ),
      ),
    );
  }
}
