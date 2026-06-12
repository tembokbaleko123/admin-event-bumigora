import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_kampus/InApp/event_detail.dart';
import 'package:aplikasi_kampus/core/utils/route_transitions.dart';
import 'package:aplikasi_kampus/core/utils/responsive.dart';
import 'package:aplikasi_kampus/core/constants/app_colors.dart';
import 'package:aplikasi_kampus/core/widgets/widgets.dart';
import 'package:aplikasi_kampus/providers/event_provider.dart';

class EventCard extends StatelessWidget {
  final String time;
  final String type;
  final String title;
  final String location;
  final Color color;
  final int? eventId;
  final int index;
  final bool isToday;

  const EventCard({
    super.key,
    required this.time,
    required this.type,
    required this.title,
    required this.location,
    required this.color,
    this.eventId,
    this.index = 0,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.cardContentPadding(context);
    return AnimatedListItem(
      index: index,
      child: GestureDetector(
        onTap: () async {
          // Check if context is still valid before navigation
          if (!context.mounted) return;

          final changed = await Navigator.push<bool>(
            context,
            RouteTransitions.slideUp(EventDetailScreen(
              eventId: eventId,
              title: title,
              location: location,
              time: time,
              type: type,
            )),
          );

          // Refresh events if user registered/cancelled
          if (changed == true && context.mounted) {
            context.read<EventProvider>().loadEvents(force: true);
          }
        },
      child: Container(
        margin: EdgeInsets.only(bottom: Responsive.isMobile(context) ? 14 : 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  Text(time, style: TextStyle(fontWeight: FontWeight.bold, fontSize: Responsive.fontSize(context, 13))),
                  const SizedBox(height: 4),
                  Container(height: 30, width: 2, decoration: BoxDecoration(color: isToday ? Colors.orange : color.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(1))),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: pad,
                decoration: BoxDecoration(
                  color: isToday ? Colors.orange.withValues(alpha: 0.08) : color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                  border: Border(left: BorderSide(color: isToday ? Colors.orange : color, width: 4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: (isToday ? Colors.orange : color).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text(type, style: TextStyle(color: isToday ? Colors.orange : color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                            child: const Text('HARI INI', style: TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          ),
                        ],
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(child: Text(location, style: TextStyle(color: AppColors.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}