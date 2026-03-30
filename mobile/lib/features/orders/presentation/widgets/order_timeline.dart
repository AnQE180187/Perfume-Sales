import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../providers/order_provider.dart';

class OrderTimeline extends StatelessWidget {
  final List<TrackingTimelineStep> steps;

  const OrderTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;

        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: step.current
                          ? AppTheme.accentGold
                          : step.reached
                          ? const Color(0xFF12B76A)
                          : Colors.transparent,
                      border: Border.all(
                        color: step.reached
                            ? AppTheme.accentGold
                            : AppTheme.softTaupe,
                        width: 1.2,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 42,
                      color: step.reached
                          ? AppTheme.accentGold.withValues(alpha: 0.35)
                          : AppTheme.softTaupe,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: step.current ? FontWeight.w700 : FontWeight.w500,
                        color: step.current ? AppTheme.deepCharcoal : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(step.description, style: Theme.of(context).textTheme.bodyMedium),
                    if (step.timestamp != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(step.timestamp!),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

String _formatTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}
