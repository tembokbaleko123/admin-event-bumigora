import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/theme/theme_extensions.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/utils/date_formatter.dart';
import 'package:aplikasi_kampus/providers/notifikasi_provider.dart';
import 'package:aplikasi_kampus/models/notifikasi_model.dart';

class NotificationScreen extends StatelessWidget {
  final bool isLecturer;
  const NotificationScreen({super.key, required this.isLecturer});

  @override
  Widget build(BuildContext context) {
    final notifProv = context.watch<NotifikasiProvider>();
    final notifs = notifProv.notifikasis;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.titleNotifikasi),
        actions: [
          if (notifs.any((n) => n.isUnread))
            TextButton(
              onPressed: () => notifProv.markAllAsRead(),
              child: const Text(
                "Mark all read",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: notifProv.isLoading
          ? const ShimmerLoading(itemCount: 4, itemHeight: 80, padding: EdgeInsets.zero)
          : notifs.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.notifications_off_outlined,
                  title: AppStrings.emptyNotifikasi,
                  subtitle: "Kamu akan menerima notifikasi di sini",
                )
              : RefreshIndicator(
                  onRefresh: () => notifProv.load(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: notifs.length,
                    itemBuilder: (_, i) => _NotificationItem(
                      notification: notifs[i],
                      onDismiss: () => notifProv.delete(notifs[i].id),
                      onTap: notifs[i].isUnread ? () => notifProv.markAsRead(notifs[i].id) : null,
                    ),
                  ),
                ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotifikasiModel notification;
  final VoidCallback? onTap;
  final Future<bool> Function() onDismiss;

  const _NotificationItem({
    required this.notification,
    this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;

    return Dismissible(
      key: ValueKey('notif_${n.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDismiss(context),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: n.isUnread ? context.surfaceColor : AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.padding(context),
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: (n.isUnread ? AppColors.primary : Colors.grey).withValues(alpha: 0.1),
            child: Icon(
              n.eventId != null ? Icons.event_rounded : Icons.campaign_rounded,
              color: n.isUnread ? AppColors.primary : Colors.grey,
              size: 22,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  n.event?.judul ?? "Notifikasi",
                  style: TextStyle(
                    fontWeight: n.isUnread ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (n.isUnread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Text(
                DateFormatter.formatRelative(n.createdAt),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              n.pesan,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Future<bool> _confirmDismiss(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(AppStrings.confirmHapusNotifikasi),
        content: const Text(AppStrings.msgYakinHapusNotif),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.batal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.hapus, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    final ok = await onDismiss();
    if (!ok && context.mounted) {
      SnackbarHelper.show(context, AppStrings.errorGagalHapusNotif, isError: true);
    }
    return ok;
  }
}
