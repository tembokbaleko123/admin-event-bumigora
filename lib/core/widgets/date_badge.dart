import 'package:flutter/material.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';

class DateBadge extends StatelessWidget {
  final String day;
  final String date;
  final bool isSelected;
  final bool hasEvent;
  final VoidCallback? onTap;

  const DateBadge({
    super.key,
    required this.day,
    required this.date,
    this.isSelected = false,
    this.hasEvent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black12, blurRadius: 2)],
          border: isSelected ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day, style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
                const SizedBox(height: 5),
                Text(date, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            if (hasEvent)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  height: 7,
                  width: 7,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
