import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

        // Progress for the bottle: 0.0 (empty) to 1.0 (full)
        // We'll map the index to a fill level
        final fillLevel = step.reached ? (index + 1) / steps.length : (index / steps.length);

        return _TimelineRow(
          step: step,
          fillLevel: fillLevel,
          isLast: isLast,
        );
      }).toList(),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final TrackingTimelineStep step;
  final double fillLevel;
  final bool isLast;

  const _TimelineRow({
    required this.step,
    required this.fillLevel,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = step.current
        ? AppTheme.accentGold
        : const Color(0xFF12B76A);
    final Color inactiveColor = AppTheme.softTaupe;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: bottle icon + connector line ──
          SizedBox(
            width: 44,
            child: Column(
              children: [
                // Bottle Icon with fill animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  width: step.current ? 42 : 38,
                  height: step.current ? 42 : 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.reached
                        ? (step.current
                                ? AppTheme.accentGold.withValues(alpha: 0.08)
                                : const Color(0xFF12B76A).withValues(alpha: 0.05))
                        : Colors.white,
                    boxShadow: step.current
                        ? [
                            BoxShadow(
                              color: AppTheme.accentGold.withValues(alpha: 0.2),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(20, 24),
                      painter: _PerfumeBottlePainter(
                        fillLevel: fillLevel,
                        strokeColor: step.reached ? activeColor : inactiveColor,
                        fillColor: step.reached ? activeColor : Colors.transparent,
                        isCurrent: step.current,
                      ),
                    ),
                  ),
                ),
                // Connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        gradient: step.reached
                            ? LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  activeColor.withValues(alpha: 0.5),
                                  activeColor.withValues(alpha: 0.15),
                                ],
                              )
                            : null,
                        color: step.reached
                            ? null
                            : inactiveColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Right: title + description + time ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    step.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: step.current ? 16 : 14,
                      fontWeight: step.current
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: step.reached
                          ? AppTheme.deepCharcoal
                          : AppTheme.mutedSilver,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.description,
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: step.reached
                          ? const Color(0xFF6B6B6B)
                          : AppTheme.mutedSilver.withValues(alpha: 0.7),
                    ),
                  ),
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: step.current
                              ? AppTheme.accentGold
                              : AppTheme.mutedSilver,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(step.timestamp!),
                          style: GoogleFonts.montserrat(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: step.current
                                ? AppTheme.accentGold
                                : AppTheme.mutedSilver,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfumeBottlePainter extends CustomPainter {
  final double fillLevel;
  final Color strokeColor;
  final Color fillColor;
  final bool isCurrent;

  _PerfumeBottlePainter({
    required this.fillLevel,
    required this.strokeColor,
    required this.fillColor,
    required this.isCurrent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isCurrent ? 2.0 : 1.2;

    final fillPaint = Paint()
      ..color = fillColor.withValues(alpha: isCurrent ? 0.8 : 0.6)
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Draw bottle shape (Rectangle body + smaller neck + cap)
    final bodyHeight = h * 0.7;
    final neckWidth = w * 0.4;
    final neckHeight = h * 0.15;
    final capHeight = h * 0.15;

    // Body
    final bodyRect = Rect.fromLTWH(0, h - bodyHeight, w, bodyHeight);
    final bodyPath = Path()..addRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)));
    
    // Fill level path
    if (fillLevel > 0) {
      final fillRect = Rect.fromLTWH(
        0, 
        h - (bodyHeight * fillLevel), 
        w, 
        bodyHeight * fillLevel
      );
      final fillPath = Path()..addRRect(RRect.fromRectAndRadius(fillRect, const Radius.circular(4)));
      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw outlines
    canvas.drawPath(bodyPath, strokePaint);
    
    // Neck
    final neckRect = Rect.fromLTWH((w - neckWidth) / 2, capHeight, neckWidth, neckHeight);
    canvas.drawRect(neckRect, strokePaint);
    
    // Cap
    final capRect = Rect.fromLTWH((w - neckWidth - 4) / 2, 0, neckWidth + 4, capHeight);
    canvas.drawRRect(RRect.fromRectAndRadius(capRect, const Radius.circular(2)), strokePaint);
  }

  @override
  bool shouldRepaint(covariant _PerfumeBottlePainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel || 
           oldDelegate.strokeColor != strokeColor || 
           oldDelegate.isCurrent != isCurrent;
  }
}

String _formatTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}
