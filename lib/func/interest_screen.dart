import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/providers/recommendation_provider.dart';
import 'package:aplikasi_kampus/core/constants/app_strings.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/Navigation/event_card.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';

class InterestScreen extends StatefulWidget {
  const InterestScreen({super.key});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  final _categories = AppStrings.allCategories;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load data after first frame to avoid build phase issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _isInitialized = true;
        _loadData();
      }
    });
  }

  void _loadData() {
    if (!mounted) return;
    try {
      final prov = context.read<RecommendationProvider>();
      prov.loadRecommendedEvents();
      prov.loadInterests();
    } catch (e) {
      debugPrint('Failed to load recommendation data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minat & Rekomendasi'),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Consumer<RecommendationProvider>(
        builder: (context, prov, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(Responsive.padding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Minat Kamu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Pilih kategori event yang kamu minati untuk mendapatkan rekomendasi yang lebih baik.',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categories.map((cat) {
                    final selected = prov.interests.contains(cat);
                    return FilterChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(color: selected ? Colors.white : Colors.grey.shade700),
                      onSelected: (val) async {
                        if (!context.mounted) return;
                        final updated = List<String>.from(prov.interests);
                        if (val) {
                          updated.add(cat);
                        } else {
                          updated.remove(cat);
                        }
                        await prov.saveInterests(updated);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Rekomendasi Event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${prov.recommendedEvents.length} event', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                if (prov.loading)
                  const ShimmerLoading(itemCount: 3, itemHeight: 90, padding: EdgeInsets.zero)
                else if (prov.recommendedEvents.isEmpty)
                  const EmptyStateWidget(title: AppStrings.emptyPilihMinat, icon: Icons.auto_awesome)
                else
                  ...prov.recommendedEvents.asMap().entries.map((e) => EventCard(
                    time: e.value.tanggal,
                    type: e.value.kategori ?? 'EVENT',
                    title: e.value.judul,
                    location: e.value.lokasi,
                    color: AppColors.primary,
                    eventId: e.value.id,
                    index: e.key,
                  )),
              ],
            ),
          );
        },
      ),
    );
  }
}