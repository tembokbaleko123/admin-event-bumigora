import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonDetail extends StatelessWidget {
  final bool hasHeader;

  const SkeletonDetail({super.key, this.hasHeader = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasHeader)
              Container(height: 200, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
            if (hasHeader) const SizedBox(height: 16),
            _line(double.infinity, 24),
            const SizedBox(height: 8),
            _line(120, 14),
            const SizedBox(height: 16),
            _line(double.infinity, 14),
            const SizedBox(height: 8),
            _line(double.infinity, 14),
            const SizedBox(height: 8),
            _line(180, 14),
            const SizedBox(height: 20),
            Row(
              children: List.generate(3, (_) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      const SizedBox(height: 8),
                      Container(height: 20, width: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                      const SizedBox(height: 4),
                      Container(height: 10, width: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                    ],
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(double width, double height) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
