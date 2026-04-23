import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/app_text_style.dart';

class AIScentAnalysisCard extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<String> notes;
  final String? scentAnalysis;

  const AIScentAnalysisCard({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.notes,
    this.scentAnalysis,
  });

  @override
  State<AIScentAnalysisCard> createState() => _AIScentAnalysisCardState();
}

class _AIScentAnalysisCardState extends State<AIScentAnalysisCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final highlightNote = widget.notes.isNotEmpty ? widget.notes.first : 'floral';

    return Transform.translate(
      offset: const Offset(0, -30),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onToggle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.creamWhite.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.accentGold.withValues(
                      alpha: 0.2 + (0.3 * _controller.value),
                    ),
                    width: 1.5,
                  ),
                  boxShadow: [
                    // Golden aura pulse
                    BoxShadow(
                      color: AppTheme.accentGold.withValues(
                        alpha: 0.1 * (1.0 - _controller.value),
                      ),
                      blurRadius: 15 + (10 * _controller.value),
                      spreadRadius: 2 + (8 * _controller.value),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Miniature Angel Avatar with floating effect
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 2 * math.sin(_controller.value * 2 * math.pi)),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.accentGold, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentGold.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/perfume_angel.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.aiScentAnalysis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: widget.isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
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
                    child: widget.scentAnalysis != null && widget.scentAnalysis!.isNotEmpty
                        ? Text(
                            widget.scentAnalysis!,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              height: 1.5,
                              color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
                            ),
                          )
                        : RichText(
                            text: TextSpan(
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                height: 1.5,
                                color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
                              ),
                              children: [
                                TextSpan(text: l10n.aiScentAnalysisDesc1),
                                TextSpan(
                                  text: highlightNote.toLowerCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.accentGold,
                                  ),
                                ),
                                TextSpan(text: l10n.aiScentAnalysisDesc2),
                              ],
                            ),
                          ),
                  ),
                  crossFadeState: widget.isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 400),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
