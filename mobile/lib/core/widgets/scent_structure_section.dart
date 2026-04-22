import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                      icon: Icons.spa_outlined,
                      label: l10n.top.toUpperCase(),
                      note: topNote,
                      descriptor: l10n.topNotesDesc,
                      isActive: false,
                      iconSize: _iconSize,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 10),
                    _ScentLayer(
                      icon: Icons.local_florist,
                      label: l10n.heart.toUpperCase(),
                      note: heartNote,
                      descriptor: l10n.heartNotesDesc,
                      isActive: true,
                      iconSize: _iconSize,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 10),
                    _ScentLayer(
                      icon: Icons.water_drop_outlined,
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
                        icon: Icons.spa_outlined,
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
                        icon: Icons.local_florist,
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
                        icon: Icons.water_drop_outlined,
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
            scale: isActive ? 1.12 : 0.95,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.accentGold : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? AppTheme.accentGold : AppTheme.softTaupe,
                  width: isActive ? 0 : 0.8,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : AppTheme.mutedSilver,
                size: isActive ? 24 : 20,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

String _previewNote(List<String> notes, String fallback) {
  if (notes.isEmpty) return fallback;
  if (notes.length == 1) return notes.first;
  return '${notes.first} +${notes.length - 1}';
}
