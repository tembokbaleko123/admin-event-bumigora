import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/providers/informasi_provider.dart';
import 'package:aplikasi_kampus/providers/bookmark_provider.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/models/informasi_model.dart';

class InformasiDetailScreen extends StatefulWidget {
  final int informasiId;
  const InformasiDetailScreen({super.key, required this.informasiId});

  @override
  State<InformasiDetailScreen> createState() => _InformasiDetailScreenState();
}

class _InformasiDetailScreenState extends State<InformasiDetailScreen> {
  InformasiModel? _info;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (mounted) setState(() => _isLoading = true);
    final info = await context.read<InformasiProvider>().getDetail(widget.informasiId);
    if (mounted) {
      setState(() {
        _info = info;
        _isLoading = false;
        if (info == null) _error = 'Gagal memuat informasi';
      });
    }
    if (mounted) {
      context.read<BookmarkProvider>().checkStatus(AppStrings.bookmarkTypeInformasi, widget.informasiId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BookmarkProvider>();
    final bookmarked = bp.isBookmarked(AppStrings.bookmarkTypeInformasi, widget.informasiId);

    return Scaffold(
      
      appBar: AppBar(
        title: const Text(AppStrings.titleDetailInformasi),
        actions: [
          IconButton(
            icon: Icon(
              bookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: bookmarked ? AppColors.primary : Colors.grey.shade600,
            ),
            onPressed: () => bp.toggle(AppStrings.bookmarkTypeInformasi, widget.informasiId),
          ),
        ],
      ),
      body: _isLoading
          ? const ShimmerLoading()
          : _error != null || _info == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error.withValues(alpha: 0.6)),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text(AppStrings.cobaLagi)),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: Responsive.screenPadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text("PENGUMUMAN", style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                      const SizedBox(height: 16),
                      Text(_info!.judul, style: TextStyle(fontSize: Responsive.fontSize(context, 24), fontWeight: FontWeight.bold, height: 1.3)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Text(_info!.tanggal, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          if (_info!.creator != null) ...[
                            const SizedBox(width: 16),
                            Icon(Icons.person, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 6),
                            Text(_info!.creator!.nama, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 20),
                      Text(
                        _info!.isi,
                        style: const TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF2D2D2D)),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }
}
