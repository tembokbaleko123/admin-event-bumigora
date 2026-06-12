import 'package:flutter/material.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/utils/date_formatter.dart';
import 'package:aplikasi_kampus/models/event_model.dart';

class EventTimeline extends StatelessWidget {
  final List<EventModel> events;
  final void Function(EventModel event)? onTap;

  const EventTimeline({super.key, required this.events, this.onTap});

  static const double _hourHeight = 60.0;
  static const double _startHour = 6;
  static const double _endHour = 22;

  Color _colorForCategory(String? kategori) {
    switch (kategori?.toLowerCase()) {
      case 'kuliah':
        return const Color(0xFF4A90D9);
      case 'workshop':
        return const Color(0xFF34C759);
      case 'seminar':
        return const Color(0xFFFF9500);
      case 'meeting':
        return const Color(0xFFAF52DE);
      case 'ukm':
        return const Color(0xFFFF2D55);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalMinutes = (_endHour - _startHour) * 60;
    final totalHeight = totalMinutes / 60 * _hourHeight;

    return SizedBox(
      height: totalHeight + 16,
      child: Stack(
        children: [
          ...List.generate((_endHour - _startHour).round(), (i) {
            final hour = _startHour + i;
            return Positioned(
              top: i * _hourHeight,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                  Expanded(child: Divider(height: 1, color: Colors.grey.shade200)),
                ],
              ),
            );
          }),
          for (final ev in events)
            _buildEventBlock(context, ev, totalMinutes),
        ],
      ),
    );
  }

  Widget _buildEventBlock(BuildContext context, EventModel ev, double totalMinutes) {
    final startDt = DateTime.tryParse(ev.tanggal);
    if (startDt == null) return const SizedBox.shrink();

    DateTime? endDt;
    if (ev.tanggalSelesai != null) {
      endDt = DateTime.tryParse(ev.tanggalSelesai!);
    }
    if (endDt == null || endDt.isBefore(startDt)) {
      endDt = startDt.add(const Duration(hours: 1));
    }

    final startMinutes = startDt.hour * 60 + startDt.minute;
    final endMinutes = endDt.hour * 60 + endDt.minute;

    if (endMinutes <= _startHour * 60 || startMinutes >= _endHour * 60) {
      return const SizedBox.shrink();
    }

    final effectiveStart = startMinutes.clamp((_startHour * 60).toInt(), (_endHour * 60).toInt());
    final effectiveEnd = endMinutes.clamp((_startHour * 60).toInt(), (_endHour * 60).toInt());
    final effectiveDuration = effectiveEnd - effectiveStart;

    final top = (effectiveStart - _startHour * 60) / totalMinutes * (totalMinutes / 60 * _hourHeight);
    final height = (effectiveDuration / totalMinutes) * (totalMinutes / 60 * _hourHeight);

    final color = _colorForCategory(ev.kategori);

    return Positioned(
      top: top + 8,
      left: 52,
      right: 8,
      height: height.clamp(28, double.infinity),
      child: GestureDetector(
        onTap: () => onTap?.call(ev),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: color, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ev.judul,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    DateFormatter.formatTime(ev.tanggal),
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
                  ),
                  if (ev.tanggalSelesai != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '- ${DateFormatter.formatTime(ev.tanggalSelesai!)}',
                      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
                    ),
                  ],
                  const Spacer(),
                  Flexible(
                    child: Text(
                      ev.lokasi,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
