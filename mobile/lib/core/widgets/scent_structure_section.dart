import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ScentStructureSection extends StatelessWidget {
  final List<String> notes;

  const ScentStructureSection({
    super.key,
    required this.notes,
  });

  static const double _iconSize = 52;
  static const double _lineBottomOffset = 78;

  @override
  Widget build(BuildContext context) {
    final topNote = notes.isNotEmpty ? notes[0] : 'Citrus';
    final heartNote = notes.length > 1 ? notes[1] : 'Rose';
    final baseNote = notes.length > 2 ? notes[2] : 'Sandalwood';

    return Transform.translate(
      offset: const Offset(0, -30),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scent Structure',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                Text(
                  'VIEW ALL',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: AppTheme.accentGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ScentLayer(
                    icon: Icons.spa_outlined,
                    label: 'TOP',
                    note: topNote,
                    descriptor: 'Fresh & Light',
                    isActive: false,
                    iconSize: _iconSize,
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        top: _iconSize / 2,
                        bottom: _lineBottomOffset,
                      ),
                      height: 1.5,
                      color: AppTheme.softTaupe.withValues(alpha: 0.6),
                    ),
                  ),
                  _ScentLayer(
                    icon: Icons.local_florist,
                    label: 'HEART',
                    note: heartNote,
                    descriptor: 'Rich & Complex',
                    isActive: true,
                    iconSize: _iconSize,
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        top: _iconSize / 2,
                        bottom: _lineBottomOffset,
                      ),
                      height: 1.5,
                      color: AppTheme.softTaupe.withValues(alpha: 0.6),
                    ),
                  ),
                  _ScentLayer(
                    icon: Icons.water_drop_outlined,
                    label: 'BASE',
                    note: baseNote,
                    descriptor: 'Deep & Lasting',
                    isActive: false,
                    iconSize: _iconSize,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  const _ScentLayer({
    required this.icon,
    required this.label,
    required this.note,
    required this.descriptor,
    required this.isActive,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: isActive ? 1.0 : 0.95,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.accentGold : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? AppTheme.accentGold : AppTheme.softTaupe,
                  width: isActive ? 0 : 1.5,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : AppTheme.mutedSilver,
                size: isActive ? 26 : 22,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            descriptor,
            style: GoogleFonts.montserrat(
              fontSize: 8,
              color: AppTheme.mutedSilver,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
