import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

class ScentStructureDetailScreen extends StatelessWidget {
  final String productName;
  final List<String>? notes;
  final List<String>? topNotes;
  final List<String>? heartNotes;
  final List<String>? baseNotes;

  const ScentStructureDetailScreen({
    super.key,
    required this.productName,
    this.notes,
    required this.topNotes,
    required this.heartNotes,
    required this.baseNotes,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final safeNotes = notes ?? const <String>[];
    var safeTopNotes = topNotes ?? const <String>[];
    var safeHeartNotes = heartNotes ?? const <String>[];
    var safeBaseNotes = baseNotes ?? const <String>[];

    if (safeTopNotes.isEmpty &&
        safeHeartNotes.isEmpty &&
        safeBaseNotes.isEmpty) {
      if (safeNotes.length == 1) {
        safeTopNotes = [safeNotes.first];
      } else if (safeNotes.length == 2) {
        safeTopNotes = [safeNotes[0]];
        safeHeartNotes = [safeNotes[1]];
      } else if (safeNotes.length > 2) {
        final topEnd = (safeNotes.length / 3).ceil();
        final heartEnd = ((safeNotes.length * 2) / 3).ceil();
        safeTopNotes = safeNotes.sublist(0, topEnd);
        safeHeartNotes = safeNotes.sublist(topEnd, heartEnd);
        safeBaseNotes = safeNotes.sublist(heartEnd);
      }
    }

    final totalNotes =
        safeTopNotes.length + safeHeartNotes.length + safeBaseNotes.length;

    final summaryCard = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppTheme.creamWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            productName.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: AppTheme.accentGold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.architectureOfScent,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.architectureOfScentDesc,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                height: 1.6,
                fontWeight: FontWeight.w300,
                color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.ivoryBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepCharcoal),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.scentStructure,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppTheme.deepCharcoal,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Vertical Connecting Line
          Positioned(
            left: 36,
            top: 140,
            bottom: 40,
            child: CustomPaint(
              size: const Size(2, double.infinity),
              painter: _DashedLinePainter(),
            ),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              summaryCard,
              const SizedBox(height: 48),
              _ScentLayerTimelineItem(
                title: l10n.topNotes,
                subtitle: 'Immédiat — 0 to 15 mins',
                description: l10n.topNotesDesc,
                notes: safeTopNotes,
                icon: Icons.auto_awesome_outlined,
              ),
              _ScentLayerTimelineItem(
                title: l10n.heartNotes,
                subtitle: 'Cœur — 20 mins to 2 hours',
                description: l10n.heartNotesDesc,
                notes: safeHeartNotes,
                icon: Icons.spa_outlined,
              ),
              _ScentLayerTimelineItem(
                title: l10n.baseNotes,
                subtitle: 'Sillage — 3 to 8 hours',
                description: l10n.baseNotesDesc,
                notes: safeBaseNotes,
                icon: Icons.park_outlined,
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScentLayerTimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final List<String> notes;
  final IconData icon;
  final bool isLast;

  const _ScentLayerTimelineItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.notes,
    required this.icon,
    this.isLast = false,
  });

  Color _getTagColor(String scent) {
    final s = scent.toLowerCase();
    if (s.contains('bergamot') || s.contains('lemon') || s.contains('citrus')) {
      return const Color(0xFFFDF7E7);
    }
    if (s.contains('jasmine') || s.contains('rose') || s.contains('floral') || s.contains('lavender')) {
      return const Color(0xFFF5EEFD);
    }
    if (s.contains('wood') || s.contains('cedar') || s.contains('sandalwood')) {
      return const Color(0xFFEFEBE9);
    }
    return const Color(0xFFF1F8E9);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 56),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Node
          Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.creamWhite,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accentGold.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppTheme.accentGold,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: AppTheme.accentGold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                if (notes.isEmpty)
                  _buildEmptyState(l10n)
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: notes.map((note) => _buildTag(context, note)).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String note) {
    final bgColor = _getTagColor(note);
    final availableWidth = MediaQuery.of(context).size.width - 120; // Accounts for timeline node and padding
    
    return InkWell(
      onTap: () => context.push('/search?note=$note'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        constraints: BoxConstraints(maxWidth: availableWidth),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.03),
            width: 1,
          ),
        ),
        child: Text(
          note,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.deepCharcoal.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.creamWhite.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.softTaupe.withValues(alpha: 0.4),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.eco_outlined,
            size: 14,
            color: AppTheme.mutedSilver.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.informationPending,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppTheme.mutedSilver.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentGold.withValues(alpha: 0.2)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double startY = 0;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2, size.height);

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
