import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/theme/theme_extensions.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/utils/route_transitions.dart';
import 'package:aplikasi_kampus/providers/informasi_provider.dart';
import 'package:aplikasi_kampus/models/informasi_model.dart';
import 'package:aplikasi_kampus/func/informasi_detail.dart';

class InformasiListScreen extends StatefulWidget {
  const InformasiListScreen({super.key});

  @override
  State<InformasiListScreen> createState() => _InformasiListScreenState();
}

class _InformasiListScreenState extends State<InformasiListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InformasiProvider>().loadInformasi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<InformasiProvider>();

    return Scaffold(
      
      appBar: AppBar(
        title: const Text(AppStrings.titleInformasi),
      ),
      body: prov.isLoading
          ? const ShimmerLoading(itemCount: 4, itemHeight: 100, padding: EdgeInsets.all(16))
          : prov.error != null
              ? ErrorDisplayWidget(message: prov.error!, onRetry: () => prov.loadInformasi())
              : prov.informasiList.isEmpty
                  ? const EmptyStateWidget(icon: Icons.info_outline, title: AppStrings.emptyInformasi)
                  : RefreshIndicator(
                      onRefresh: () => prov.loadInformasi(),
                      child: ListView.builder(
                        padding: Responsive.screenPadding(context),
                        itemCount: prov.informasiList.length,
                        itemBuilder: (_, i) {
                          final InformasiModel info = prov.informasiList[i];
                          return AnimatedListItem(index: i, child: _infoCard(context, info));
                        },
                      ),
                    ),
    );
  }

  Widget _infoCard(BuildContext context, InformasiModel info) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        RouteTransitions.slideFromRight(InformasiDetailScreen(informasiId: info.id)),
      ).then((_) {
        if (mounted) context.read<InformasiProvider>().loadInformasi();
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: Responsive.cardContentPadding(context),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: context.onSurfaceColor.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.article_outlined, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.judul,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    info.isi,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 11, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        info.tanggal,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                      ),
                      if (info.creator != null) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.person, size: 11, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          info.creator!.nama,
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}
