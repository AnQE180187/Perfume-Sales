import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class ScentStructureSection extends StatelessWidget {
  final List<String>? notes;
  final List<String>? topNotes;
  final List<String>? heartNotes;
  final List<String>? baseNotes;
  final VoidCallback? onViewAll;

  const ScentStructureSection({
    super.key,
    required this.notes,
    this.topNotes,
    this.heartNotes,
    this.baseNotes,
    this.onViewAll,
  });

  static const double _iconSize = 52;
  static const double _lineBottomOffset = 78;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final safeNotes = notes ?? const <String>[];
    final safeTopNotes = topNotes ?? const <String>[];
    final safeHeartNotes = heartNotes ?? const <String>[];
    final safeBaseNotes = baseNotes ?? const <String>[];

    final previewTopNotes = safeTopNotes.isNotEmpty
        ? safeTopNotes
        : (safeNotes.isNotEmpty ? [safeNotes[0]] : <String>[]);
    final previewHeartNotes = safeHeartNotes.isNotEmpty
        ? safeHeartNotes
        : (safeNotes.length > 1 ? [safeNotes[1]] : <String>[]);
    final previewBaseNotes = safeBaseNotes.isNotEmpty
        ? safeBaseNotes
        : (safeNotes.length > 2 ? safeNotes.sublist(2) : <String>[]);

    final topNote = _previewNote(previewTopNotes, 'Bergamot');
    final heartNote = _previewNote(previewHeartNotes, 'Rose');
    final baseNote = _previewNote(previewBaseNotes, 'Sandalwood');

    final viewAllButton = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onViewAll,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.viewAll,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: AppTheme.accentGold,
              ),
            ],
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 330;

        final content = Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.scentStructure,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: viewAllButton,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.scentStructure,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    viewAllButton,
                  ],
                ),
              SizedBox(height: isCompact ? 16 : 24),
              if (isCompact)
                Column(
                  children: [
                    _ScentLayer(
                      icon: LucideIcons.sprout,
                      label: l10n.top.toUpperCase(),
                      note: topNote,
                      descriptor: l10n.topNotesDesc,
                      isActive: false,
                      iconSize: _iconSize,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 10),
                    _ScentLayer(
                      icon: LucideIcons.flower,
                      label: l10n.heart.toUpperCase(),
                      note: heartNote,
                      descriptor: l10n.heartNotesDesc,
                      isActive: true,
                      iconSize: _iconSize,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 10),
                    _ScentLayer(
                      icon: LucideIcons.droplets,
                      label: l10n.base.toUpperCase(),
                      note: baseNote,
                      descriptor: l10n.baseNotesDesc,
                      isActive: false,
                      iconSize: _iconSize,
                      width: double.infinity,
                    ),
                  ],
                )
              else
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ScentLayer(
                        icon: LucideIcons.sprout,
                        label: l10n.top.toUpperCase(),
                        note: topNote,
                        descriptor: l10n.topNotesDesc,
                        isActive: false,
                        iconSize: _iconSize,
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            top: _iconSize / 2,
                            bottom: _lineBottomOffset,
                          ),
                          height: 0.8,
                          color: AppTheme.accentGold.withValues(alpha: 0.25),
                        ),
                      ),
                      _ScentLayer(
                        icon: LucideIcons.flower,
                        label: l10n.heart.toUpperCase(),
                        note: heartNote,
                        descriptor: l10n.heartNotesDesc,
                        isActive: true,
                        iconSize: _iconSize,
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            top: _iconSize / 2,
                            bottom: _lineBottomOffset,
                          ),
                          height: 0.8,
                          color: AppTheme.accentGold.withValues(alpha: 0.25),
                        ),
                      ),
                      _ScentLayer(
                        icon: LucideIcons.droplets,
                        label: l10n.base.toUpperCase(),
                        note: baseNote,
                        descriptor: l10n.baseNotesDesc,
                        isActive: false,
                        iconSize: _iconSize,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );

        if (constraints.hasBoundedHeight) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: content,
          );
        }

        return content;
      },
    );
  }
}

class _ScentLayer extends StatelessWidget {
  final IconData icon;
  final String label;
  final String note;
  final String descriptor;
  final bool isActive;
  final double iconSize;
  final double width;

  const _ScentLayer({
    required this.icon,
    required this.label,
    required this.note,
    required this.descriptor,
    required this.isActive,
    required this.iconSize,
    this.width = 72,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: isActive ? 1.15 : 0.95,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            child: Container(
              width: iconSize,
              height: iconSize,
              child: CustomPaint(
                painter: HandDrawnCirclePainter(
                  color: isActive ? AppTheme.accentGold : AppTheme.softTaupe.withValues(alpha: 0.3),
                  isFilled: isActive,
                  strokeWidth: isActive ? 0 : 1.2,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : AppTheme.mutedSilver,
                    size: isActive ? 24 : 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: isActive ? AppTheme.accentGold : AppTheme.mutedSilver,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: GoogleFonts.playfairDisplay(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.deepCharcoal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class HandDrawnCirclePainter extends CustomPainter {
  final Color color;
  final bool isFilled;
  final double strokeWidth;

  HandDrawnCirclePainter({
    required this.color,
    required this.isFilled,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create an organic "wobbly" circle
    const steps = 8;
    for (int i = 0; i <= steps; i++) {
      final angle = (i * 2 * 3.14159) / steps;
      // Vary the radius slightly for each step
      final variance = i == steps ? 0.0 : (i % 2 == 0 ? 0.95 : 1.05);
      final r = radius * variance;
      
      final x = center.dx + r * 1 * (1.0 + (i % 3 == 0 ? 0.02 : -0.02)) * (i % 2 == 0 ? 0.98 : 1.02) * (i == 0 || i == steps ? 1.0 : 0.96 + (0.08 * (i % 5 / 5))) * (0.95 + (0.1 * (i % 7 / 7))) * (0.9 + (0.2 * (i % 4 / 4)));
      // Simplify logic for a better hand-drawn look:
      // We use a fixed set of variance multipliers to make it look "sketched"
    }

    // Refined hand-drawn path
    final points = <Offset>[];
    const numPoints = 12;
    final rList = [1.0, 1.05, 0.98, 1.02, 0.95, 1.08, 0.97, 1.03, 0.99, 1.04, 0.96, 1.0];
    
    for (int i = 0; i < numPoints; i++) {
      final angle = (i * 2 * 3.14159) / numPoints;
      final r = radius * rList[i];
      points.add(Offset(center.dx + r * 1.0 * (i == 0 ? 1.0 : 1.0) * (i % 2 == 0 ? 0.98 : 1.02) * (i % 3 == 0 ? 1.01 : 0.99), center.dy + r * 1.0 * (i % 4 == 0 ? 0.97 : 1.03)));
    }
    
    // Draw with cubic curves for smoothness
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];
      final xc = (p1.dx + p2.dx) / 2;
      final yc = (p1.dy + p2.dy) / 2;
      path.quadraticBezierTo(p1.dx, p1.dy, xc, yc);
    }
    path.close();

    if (isFilled) {
      // Add a subtle glow for filled version
      canvas.drawShadow(path, color.withValues(alpha: 0.3), 10, true);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

String _previewNote(List<String> notes, String fallback) {
  if (notes.isEmpty) return fallback;
  if (notes.length == 1) return notes.first;
  return '${notes.first} +${notes.length - 1}';
}
