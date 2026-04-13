import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class AIScentAnalysisCard extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<String> notes;

  const AIScentAnalysisCard({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final highlightNote = notes.isNotEmpty ? notes.first : 'floral';

    return Transform.translate(
      offset: const Offset(0, -30),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_outlined,
                      size: 20,
                      color: AppTheme.accentGold,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.aiScentAnalysis,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: AppTheme.mutedSilver,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          height: 1.6,
                          color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
                        ),
                        children: [
                          TextSpan(
                            text: l10n.aiScentAnalysisDesc1,
                          ),
                          TextSpan(
                            text: highlightNote.toLowerCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentGold,
                            ),
                          ),
                          TextSpan(
                            text: l10n.aiScentAnalysisDesc2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 280),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
