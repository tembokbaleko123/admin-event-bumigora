import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/providers/auth_provider.dart';
import 'package:aplikasi_kampus/providers/event_provider.dart';
import 'package:aplikasi_kampus/providers/theme_provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/theme/theme_extensions.dart';
import 'package:aplikasi_kampus/func/edit_profile.dart';
import 'package:aplikasi_kampus/func/informasi_list.dart';
import 'package:aplikasi_kampus/func/bookmark_screen.dart';
import 'package:aplikasi_kampus/core/utils/route_transitions.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final eventProv = context.watch<EventProvider>();
    final statsEvents = eventProv.allEvents;
    final totalEvents = statsEvents.length;
    final now = DateTime.now();
    final upcoming = statsEvents.where((e) {
      try { return !DateTime.parse(e.tanggal).isBefore(now); } catch (_) { return false; }
    }).length;
    final completed = statsEvents.where((e) {
      try { return DateTime.parse(e.tanggal).isBefore(now); } catch (_) { return false; }
    }).length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Responsive.screenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(AppStrings.titleProfil, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: context.onSurfaceColor.withValues(alpha: 0.08), blurRadius: 4)]),
                    child: const Icon(Icons.settings_outlined, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.3),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 3),
                          ),
                          child: const Icon(Icons.person, size: 42, color: Colors.white),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, size: 14, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(auth.user?.nama ?? "Pengguna", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(auth.user?.email ?? "Email belum tersedia", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat("$totalEvents", "Events"),
                        _vDivider(),
                        _stat("$upcoming", "Upcoming"),
                        _vDivider(),
                        _stat("$completed", "Completed"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _section(AppStrings.labelAkun),
              const SizedBox(height: 12),
              _menu(context, [
                _item(context, Icons.person_outline, AppStrings.titleEditProfil, AppColors.primary, () => Navigator.push(context, RouteTransitions.slideFromRight(const EditProfileScreen()))),
                _divider(),
                _item(context, Icons.info_outline, AppStrings.titleInformasi, Colors.blue, () => Navigator.push(context, RouteTransitions.slideFromRight(const InformasiListScreen()))),
                _divider(),
                _item(context, Icons.bookmark_outline, AppStrings.titleBookmark, Colors.teal, () => Navigator.push(context, RouteTransitions.slideFromRight(const BookmarkScreen()))),
                _divider(),
                _item(context, Icons.notifications_outlined, AppStrings.titleNotifikasi, Colors.orange, null),
              ]),
              const SizedBox(height: 20),
              _section(AppStrings.labelPreferensi),
              const SizedBox(height: 12),
              _menu(context, [
                Consumer<ThemeProvider>(
                  builder: (context, theme, child) => Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(theme.isDark ? Icons.dark_mode : Icons.light_mode, color: Colors.purple, size: 18),
                      ),
                      title: const Text(AppStrings.labelModeGelap, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      value: theme.isDark,
                      onChanged: (_) => theme.toggle(),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(AppStrings.keluar, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: context.onSurfaceColor.withValues(alpha: 0.2)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), backgroundColor: context.surfaceColor),
                ),
              ),
              const SizedBox(height: 28),
              Center(child: Text(AppStrings.appVersion, style: TextStyle(color: context.textSecondaryColor, fontSize: 12))),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.keluar),
        content: const Text(AppStrings.msgYakinKeluar),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.batal)),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pop(context);
            },
            child: const Text(AppStrings.keluar, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _stat(String v, String l) => Column(children: [Text(v, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(l, style: const TextStyle(color: Colors.white70, fontSize: 12))]);
  Widget _vDivider() => Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3));
  Widget _section(String t) => Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  Widget _menu(BuildContext context, List<Widget> c) => Container(decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: context.onSurfaceColor.withValues(alpha: 0.05), blurRadius: 8)]), child: Column(children: c));
  Widget _item(BuildContext context, IconData icon, String label, Color color, VoidCallback? onTap) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
            Icon(Icons.arrow_forward_ios, size: 14, color: context.textSecondaryColor),
          ],
        ),
      ),
    ),
  );
  Widget _divider() => Divider(height: 1, indent: 60, endIndent: 18, color: Colors.grey.shade100);
}
