import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/luxury_button.dart';
import '../../providers/ai_preferences_provider.dart';
import '../../../../l10n/app_localizations.dart';

class AiPreferencesScreen extends ConsumerStatefulWidget {
  const AiPreferencesScreen({super.key});

  @override
  ConsumerState<AiPreferencesScreen> createState() => _AiPreferencesScreenState();
}

class _AiPreferencesScreenState extends ConsumerState<AiPreferencesScreen>
    with SingleTickerProviderStateMixin {
  double? _riskLevel;
  List<String>? _preferredNotes;
  List<String>? _avoidedNotes;
  bool _isInitialized = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(aiPreferencesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.deepCharcoal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            l10n.aiScentDna.toUpperCase(),
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppTheme.deepCharcoal,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _handleReset,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.reset.toUpperCase(),
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentGold,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.info_outline_rounded,
                color: AppTheme.mutedSilver, size: 20),
            onPressed: _showInfoSheet,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: prefsAsync.when(
        data: (prefs) {
          if (!_isInitialized) {
            _riskLevel = prefs.riskLevel;
            _preferredNotes = List.from(prefs.preferredNotes);
            _avoidedNotes = List.from(prefs.avoidedNotes);
            _isInitialized = true;
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              _buildRadarChartHeader(l10n),
              const SizedBox(height: 32),
              _buildSectionHeader(l10n.suggestionMode.toUpperCase(), l10n.exploreNewScents),
              const SizedBox(height: 24),
              _buildLuxurySlider(l10n),
              const SizedBox(height: 32),
              _buildSectionHeader(l10n.preferredNotesLabel.toUpperCase(), l10n.yourUniqueDna),
              const SizedBox(height: 16),
              _buildGlassNoteChips(_preferredNotes ?? [], AppTheme.accentGold, (note) {
                setState(() => _preferredNotes?.remove(note));
              }, l10n),
              const SizedBox(height: 32),
              _buildSectionHeader(l10n.avoidedNotesLabel.toUpperCase(), l10n.ingredientsToAvoid),
              const SizedBox(height: 16),
              _buildGlassNoteChips(_avoidedNotes ?? [], const Color(0xFFD44638), (note) {
                setState(() => _avoidedNotes?.remove(note));
              }, l10n),
              const SizedBox(height: 48),
              _buildSaveButton(l10n),
              const SizedBox(height: 40),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
        error: (err, stack) => Center(child: Text('${l10n.error}: $err')),
      ),
    );
  }

  Widget _buildRadarChartHeader(AppLocalizations l10n) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: RadarChartPainter(
                    preferredNotes: _preferredNotes ?? [],
                    animationValue: _animationController.value,
                    l10n: l10n,
                  ),
                ),
                Positioned(
                  bottom: 28,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppTheme.accentGold.withValues(alpha: 0.6),
                          const Color(0xFFD4AF37),
                          AppTheme.accentGold.withValues(alpha: 0.6),
                        ],
                        stops: [
                          (_animationController.value - 0.2).clamp(0.0, 1.0),
                          _animationController.value,
                          (_animationController.value + 0.2).clamp(0.0, 1.0),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        l10n.molecularAnalysis.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(subtitle, style: GoogleFonts.montserrat(fontSize: 11, color: AppTheme.mutedSilver)),
      ],
    );
  }

  Widget _buildLuxurySlider(AppLocalizations l10n) {
    double value = _riskLevel ?? 0.3;
    final Color trackColor = Color.lerp(AppTheme.accentGold, const Color(0xFFFF8C42), value)!;
    
    String description = '';
    Color statusColor = AppTheme.mutedSilver;

    if (value < 0.35) {
      description = l10n.aiSafeSuggestion;
      statusColor = Colors.green[600]!;
    } else if (value < 0.7) {
      description = l10n.aiBalancedSuggestion;
      statusColor = AppTheme.accentGold;
    } else {
      description = l10n.aiDaringSuggestion;
      statusColor = const Color(0xFFFF8C42);
    }
    
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.15)),
          ),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: statusColor,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: trackColor,
            inactiveTrackColor: AppTheme.softTaupe.withValues(alpha: 0.2),
            thumbColor: Colors.white,
            trackHeight: 4,
          ),
          child: Slider(value: value, onChanged: (v) => setState(() => _riskLevel = v)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.classic, style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.mutedSilver)),
            Text(l10n.daring, style: GoogleFonts.montserrat(fontSize: 10, color: trackColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassNoteChips(List<String> notes, Color color, Function(String) onRemove, AppLocalizations l10n) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...notes.map((note) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 48,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  note, 
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: color)
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(onTap: () => onRemove(note), child: Icon(Icons.close_rounded, size: 14, color: color.withValues(alpha: 0.4))),
            ],
          ),
        )),
        GestureDetector(
          onTap: () => _showAddNoteDialog(color == AppTheme.accentGold, l10n),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.softTaupe.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.add_rounded, size: 16, color: AppTheme.mutedSilver),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: AppTheme.accentGold.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ElevatedButton(
        onPressed: _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.deepCharcoal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(l10n.saveDnaConfig.toUpperCase(), style: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
    );
  }

  void _showInfoSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Color(0xFFFAF8F6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: HelixWatermarkPainter(
                        animationValue: _animationController.value),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppTheme.softTaupe.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            const SizedBox(height: 24),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  AppTheme.deepCharcoal,
                                  Color(0xFF7D6E5D),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                l10n.understandingYourDna,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n.dnaDescription,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: AppTheme.mutedSilver,
                                height: 1.8,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 48),
                            _buildEditorialItem(
                              Icons.bubble_chart_outlined,
                              l10n.molecularRadar,
                              l10n.molecularRadarDesc,
                            ),
                            _buildEditorialItem(
                              Icons.filter_vintage_outlined,
                              l10n.suggestionFocus,
                              l10n.suggestionFocusDesc,
                            ),
                            _buildEditorialItem(
                              Icons.psychology_outlined,
                              l10n.discoveryCurve,
                              l10n.discoveryCurveDesc,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGold.withValues(alpha: 0.15),
                              blurRadius: 25,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.deepCharcoal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.continueExploring.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditorialItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.accentGold, size: 28),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AppTheme.mutedSilver,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(aiPreferencesProvider.notifier).updatePreferences(
        riskLevel: _riskLevel, preferredNotes: _preferredNotes, avoidedNotes: _avoidedNotes
      );
      
      if (mounted) {
        // Show premium success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _DnaSuccessDialog(),
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
    }
  }

  Future<void> _handleReset() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetDna, style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Text(l10n.resetDnaConfirm, style: GoogleFonts.montserrat()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.no.toUpperCase(), style: GoogleFonts.montserrat(color: AppTheme.mutedSilver))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.reset.toUpperCase(), style: GoogleFonts.montserrat(color: const Color(0xFFD44638), fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(aiPreferencesProvider.notifier).resetPreferences();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.dnaResetSuccess)));
        }
        setState(() {
          _isInitialized = false;
        });
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    }
  }

  void _showAddNoteDialog(bool isPreferred, AppLocalizations l10n) {
    final allSelectedNotes = {
      ...(_preferredNotes ?? []),
      ...(_avoidedNotes ?? []),
    }.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddNoteSheet(
        isPreferred: isPreferred,
        existingNotes: allSelectedNotes,
        onAdd: (note) {
          final normalizedNote = note.trim();
          if (_preferredNotes?.contains(normalizedNote) == true || 
              _avoidedNotes?.contains(normalizedNote) == true) return;
          setState(() {
            if (isPreferred) _preferredNotes?.add(normalizedNote);
            else _avoidedNotes?.add(normalizedNote);
          });
        },
        l10n: l10n,
      ),
    );
  }
}

class _DnaSuccessDialog extends StatefulWidget {
  @override
  State<_DnaSuccessDialog> createState() => _DnaSuccessDialogState();
}

class _DnaSuccessDialogState extends State<_DnaSuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentGold.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentGold.withOpacity(0.2),
                      AppTheme.accentGold.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(color: AppTheme.accentGold.withOpacity(0.3), width: 2),
                ),
                child: Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/perfume_angel.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.dnaSuccessTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.dnaSuccessMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepCharcoal,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.dnaSuccessSubmessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: AppTheme.mutedSilver,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: LuxuryButton(
                text: l10n.exploreNow,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final List<String> preferredNotes;
  final double animationValue;
  final AppLocalizations l10n;

  RadarChartPainter({required this.preferredNotes, required this.animationValue, required this.l10n});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;
    const sides = 5;
    const angle = (2 * math.pi) / sides;
    final labels = [l10n.woody, l10n.floral, l10n.citrus, l10n.spicy, l10n.musky];

    final helixPaint = Paint()
      ..color = AppTheme.accentGold.withValues(alpha: 0.05)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 25; i++) {
      double t = (i / 25);
      double y = size.height * t;
      double xOffset = 30 * math.sin(t * 12 + animationValue * 2 * math.pi);
      canvas.drawCircle(Offset(center.dx + xOffset, y), 2, helixPaint);
      canvas.drawCircle(Offset(center.dx - xOffset, y), 2, helixPaint);
      if (i % 4 == 0) {
        canvas.drawLine(Offset(center.dx + xOffset, y), Offset(center.dx - xOffset, y), helixPaint);
      }
    }

    final particlePaint = Paint()..color = AppTheme.accentGold.withValues(alpha: 0.1);
    final random = math.Random(100);
    for (var i = 0; i < 20; i++) {
      double pX = (random.nextDouble() * size.width);
      double pY = (random.nextDouble() * size.height + animationValue * 50) % size.height;
      canvas.drawCircle(Offset(pX, pY), 1 + random.nextDouble() * 2, particlePaint);
    }

    final Map<String, double> scores = {for (var l in labels) l: 0.3};
    final Map<String, List<String>> keywords = {
      l10n.woody: ['gỗ', 'đàn hương', 'wood', 'cedar', 'agarwood', 'trầm'],
      l10n.floral: ['hoa', 'rose', 'jasmine', 'floral', 'violet', 'nhài'],
      l10n.citrus: ['cam', 'chanh', 'citrus', 'lemon', 'bergamot', 'lime'],
      l10n.spicy: ['gia vị', 'spicy', 'tiêu', 'pepper', 'quế', 'ginger'],
      l10n.musky: ['xạ hương', 'musk', 'amber', 'vanilla', 'da thuộc'],
    };
    for (var l in labels) {
      for (var n in preferredNotes) {
        if (keywords[l]!.any((kw) => n.toLowerCase().contains(kw.toLowerCase()))) {
          scores[l] = (scores[l]! + 0.18).clamp(0.2, 1.0);
        }
      }
    }

    final gridPaint = Paint()..color = AppTheme.accentGold.withValues(alpha: 0.1)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    for (var i = 1; i <= 4; i++) {
      final r = radius * (i / 4);
      final p = Path();
      for (var j = 0; j <= sides; j++) {
        final x = center.dx + r * math.cos(j * angle - math.pi / 2);
        final y = center.dy + r * math.sin(j * angle - math.pi / 2);
        if (j == 0) p.moveTo(x, y); else p.lineTo(x, y);
      }
      canvas.drawPath(p, gridPaint);
    }

    final pulse = 1.0 + 0.04 * math.sin(animationValue * 2 * math.pi);
    final polyPath = Path();
    for (var i = 0; i <= sides; i++) {
      final idx = i % sides;
      final r = radius * scores[labels[idx]]! * pulse;
      final x = center.dx + r * math.cos(idx * angle - math.pi / 2);
      final y = center.dy + r * math.sin(idx * angle - math.pi / 2);
      if (i == 0) polyPath.moveTo(x, y); else polyPath.lineTo(x, y);
    }

    canvas.drawPath(polyPath, Paint()..color = const Color(0xFFF0BD66).withValues(alpha: 0.3)..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * pulse));
    canvas.drawPath(polyPath, Paint()..color = AppTheme.accentGold.withValues(alpha: 0.8)..strokeWidth = 2..style = PaintingStyle.stroke);

    for (var i = 0; i < sides; i++) {
      final r = radius * scores[labels[i]]! * pulse;
      final x = center.dx + r * math.cos(i * angle - math.pi / 2);
      final y = center.dy + r * math.sin(i * angle - math.pi / 2);
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = AppTheme.accentGold..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = Colors.white);
      final textPainter = TextPainter(
        text: TextSpan(text: labels[i], style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: AppTheme.deepCharcoal.withValues(alpha: 0.6))),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(center.dx + (radius + 28) * math.cos(i * angle - math.pi / 2) - textPainter.width/2, center.dy + (radius + 20) * math.sin(i * angle - math.pi / 2) - textPainter.height/2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(RadarChartPainter old) => true;
}

class HelixWatermarkPainter extends CustomPainter {
  final double animationValue;
  HelixWatermarkPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentGold.withValues(alpha: 0.04)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final centerX = size.width * 0.8;
    for (var i = 0; i < 40; i++) {
      double t = i / 40;
      double y = size.height * t;
      double xOffset = 40 * math.sin(t * 10 + animationValue * 2 * math.pi);

      canvas.drawCircle(Offset(centerX + xOffset, y), 3, paint);
      canvas.drawCircle(Offset(centerX - xOffset, y), 3, paint);
      if (i % 5 == 0) {
        canvas.drawLine(Offset(centerX + xOffset, y),
            Offset(centerX - xOffset, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(HelixWatermarkPainter old) => true;
}

class _AddNoteSheet extends ConsumerStatefulWidget {
  final bool isPreferred;
  final List<String> existingNotes;
  final Function(String) onAdd;
  final AppLocalizations l10n;
  const _AddNoteSheet({required this.isPreferred, required this.existingNotes, required this.onAdd, required this.l10n});
  @override ConsumerState<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends ConsumerState<_AddNoteSheet> {
  String _search = '';
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(color: Color(0xFFFAF8F6), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.l10n.exploreNotes.toUpperCase(), style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(hintText: widget.l10n.searchNotesHint, prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
          ),
          Expanded(child: _buildSearchList()),
        ],
      ),
    );
  }

  Widget _buildSearchList() {
    final notesAsync = ref.watch(scentNotesProvider);
    return notesAsync.when(
      data: (notes) {
        final filtered = notes.where((n) => n.toLowerCase().contains(_search.toLowerCase()) && !widget.existingNotes.contains(n)).toList();
        if (filtered.isEmpty && _search.isNotEmpty) {
           return Center(child: TextButton(onPressed: () { widget.onAdd(_search); Navigator.pop(context); }, child: Text('${widget.l10n.addNewNote} "$_search"', style: GoogleFonts.montserrat(color: AppTheme.accentGold, fontWeight: FontWeight.bold))));
        }
        return ListView.builder(itemCount: filtered.length, itemBuilder: (c, i) => ListTile(title: Text(filtered[i], style: GoogleFonts.montserrat(fontSize: 14)), trailing: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.accentGold), onTap: () { widget.onAdd(filtered[i]); Navigator.pop(context); }));
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Container(),
    );
  }
}
