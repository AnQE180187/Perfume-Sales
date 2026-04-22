import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../providers/quiz_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with SingleTickerProviderStateMixin {
  bool _showIntro = true;
  late AnimationController _angelController;

  final _iconMap = <String, IconData>{
    'person': Icons.person_outline_rounded,
    'favorite': Icons.favorite_border_rounded,
    'people': Icons.people_outline_rounded,
    'star': Icons.star_border_rounded,
    'business_center': Icons.business_center_outlined,
    'calendar_month': Icons.calendar_month_outlined,
    'celebration': Icons.celebration_outlined,
    'auto_awesome': Icons.auto_awesome_outlined,
    'savings': Icons.savings_outlined,
    'paid': Icons.paid_outlined,
    'currency_exchange': Icons.currency_exchange_outlined,
    'payments': Icons.payments_outlined,
    'workspace_premium': Icons.workspace_premium_outlined,
    'hourglass': Icons.hourglass_empty_rounded,
    'schedule': Icons.schedule_outlined,
    'timer': Icons.timer_outlined,
    'bolt': Icons.bolt_outlined,
    'air': Icons.air_rounded,
    'local_florist': Icons.local_florist_outlined,
    'park': Icons.park_outlined,
    'local_fire_department': Icons.local_fire_department_outlined,
    'spa': Icons.spa_outlined,
  };

  @override
  void initState() {
    super.initState();
    _angelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _angelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    final l10n = AppLocalizations.of(context)!;

    // The controller is now started in initState and runs continuously for the angel animations.

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentGold.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Cancel / close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: l10n.cancel,
                    ),
                  ),
                ),
                if (quizState.errorMessage != null)
                  _buildErrorHeader(quizState.errorMessage!, l10n),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _buildCurrentStage(quizState, l10n),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStage(QuizState state, AppLocalizations l10n) {
    if (_showIntro) return _buildIntro(l10n, key: const ValueKey('intro'));
    if (state.isAnalyzing)
      return _buildAnalyzing(l10n, key: const ValueKey('analyzing'));
    if (state.isComplete)
      return _buildResults(state, l10n, key: const ValueKey('results'));
    return _buildQuizFlow(
      state,
      l10n,
      key: ValueKey('step_${state.currentStep}'),
    );
  }

  Widget _buildErrorHeader(String message, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.red.withValues(alpha: 0.1),
      child: Text(
        message,
        style: GoogleFonts.montserrat(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildIntro(AppLocalizations l10n, {Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _angelController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 10 * math.sin(_angelController.value * 2 * math.pi)),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      transform: _ShimmerGradientTransform(_angelController.value),
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcOver,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/images/perfume_angel.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            l10n.discoverYourScentSignature,
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppTheme.deepCharcoal,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.quizIntroDescription,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.deepCharcoal.withValues(alpha: 0.6),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: () => setState(() => _showIntro = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: AppTheme.creamWhite,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 8,
              shadowColor: AppTheme.accentGold.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.startNow.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.estimatedTime,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedSilver,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizFlow(QuizState state, AppLocalizations l10n, {Key? key}) {
    final questionRaw = QuizState.questions[state.currentStep];
    final selectedIndex = state.answers[state.currentStep];

    // Localize question and options
    String questionText = '';
    List<String> optionTitles = [];

    switch (state.currentStep) {
      case 0:
        questionText = l10n.q1Text;
        optionTitles = [l10n.q1Opt1, l10n.q1Opt2, l10n.q1Opt3];
        break;
      case 1:
        questionText = l10n.q2Text;
        optionTitles = [
          l10n.q2Opt1,
          l10n.q2Opt2,
          l10n.q2Opt3,
          l10n.q2Opt4,
          l10n.q2Opt5,
        ];
        break;
      case 2:
        questionText = l10n.q3Text;
        optionTitles = questionRaw.options
            .map((o) => o.title)
            .toList(); // Budget values are fine as is
        break;
      case 3:
        questionText = l10n.q4Text;
        optionTitles = [
          l10n.q4Opt1,
          l10n.q4Opt2,
          l10n.q4Opt3,
          l10n.q4Opt4,
          l10n.q4Opt5,
        ];
        break;
      case 4:
        questionText = l10n.q5Text;
        optionTitles = [l10n.q5Opt1, l10n.q5Opt2, l10n.q5Opt3, l10n.q5Opt4];
        break;
    }

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Row(
            children: List.generate(state.totalSteps, (index) {
              final isPassed = index < state.currentStep;
              final isCurrent = index == state.currentStep;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isPassed || isCurrent
                        ? AppTheme.accentGold
                        : AppTheme.softTaupe.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (state.canGoBack)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                      onPressed: () => ref.read(quizProvider.notifier).goBack(),
                    ),
                  Text(
                    l10n.stepProgress(state.currentStep + 1, state.totalSteps),
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentGold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                questionText,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            itemCount: optionTitles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final option = questionRaw.options[index];
              final title = optionTitles[index];
              final isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () =>
                    ref.read(quizProvider.notifier).selectOption(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.creamWhite
                        : AppTheme.creamWhite.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accentGold
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 0),
                        ),
                      BoxShadow(
                        color: AppTheme.deepCharcoal.withValues(
                          alpha: isSelected ? 0.12 : 0.04,
                        ),
                        blurRadius: isSelected ? 25 : 10,
                        offset: Offset(0, isSelected ? 12 : 4),
                      ),
                    ],
                  ),
                  transform: Matrix4.identity()
                    ..translate(0.0, isSelected ? -8.0 : 0.0),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.accentGold.withValues(alpha: 0.1)
                              : AppTheme.ivoryBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _iconMap[option.icon] ?? Icons.circle,
                          color: AppTheme.accentGold,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.montserrat(
                            fontSize: 17,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: AppTheme.deepCharcoal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.accentGold,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzing(AppLocalizations l10n, {Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: AnimatedBuilder(
              animation: _angelController,
              builder: (context, child) {
                return CustomPaint(
                  painter: AuraAnalysisPainter(_angelController.value),
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, 8 * math.sin(_angelController.value * 2 * math.pi)),
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGold.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/perfume_angel.png',
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l10n.auraAnalysis,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentGold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.personalizingScentExperience,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppTheme.deepCharcoal.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 40),

          Container(
            width: 280,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.creamWhite,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusRow(l10n.processingOlfactoryData, 0.5),
                _buildStatusRow(l10n.matchingResonantNotes, 1.5),
                _buildStatusRow(l10n.identifyingPersonalSignature, 2.5),
                _buildStatusRow(l10n.completingAuraAlgorithm, 3.5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String text, double delayInSec) {
    return FutureBuilder(
      future: Future.delayed(
        Duration(milliseconds: (delayInSec * 1000).toInt()),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const SizedBox(height: 20);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Text(
                '>',
                style: TextStyle(
                  color: AppTheme.accentGold,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepCharcoal.withValues(alpha: 0.4),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResults(QuizState state, AppLocalizations l10n, {Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _angelController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 12 * math.sin(_angelController.value * 2 * math.pi)),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 1.0),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      transform: _ShimmerGradientTransform(_angelController.value),
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcOver,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.2),
                          blurRadius: 40,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/perfume_angel.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            l10n.yourScentSignature,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.deepCharcoal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l10n.resultsDescription,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppTheme.deepCharcoal.withValues(alpha: 0.6),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),

          if (state.recommendations.isNotEmpty)
            SizedBox(
              height: 550,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: state.recommendations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  final rec = state.recommendations[index];
                  return _buildRecommendationCard(rec, l10n);
                },
              ),
            )
          else
            Center(child: Text(l10n.noRecommendations)),

          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(quizProvider.notifier).reset();
                      setState(() => _showIntro = true);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: BorderSide(
                        color: AppTheme.softTaupe.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.retakeQuiz,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.mutedSilver,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(quizProvider.notifier).reset();
                      context.go('/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.deepCharcoal,
                      foregroundColor: AppTheme.creamWhite,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.exploreStore,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(dynamic rec, AppLocalizations l10n) {
    final imageUrl = rec['imageUrl'] as String?;
    final name = rec['name'] as String? ?? 'Scent';
    final brand = rec['brand'] as String? ?? 'Luxury Brand';
    final reason = rec['reason'] as String? ?? '';
    final productId = rec['productId'] as String?;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppTheme.creamWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepCharcoal.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: AspectRatio(
              aspectRatio: 1.25,
              child: Stack(
                children: [
                  if (imageUrl != null)
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                    )
                  else
                    _buildPlaceholderImage(),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 12,
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentGold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                    ),
                  ),
                  child: RichText(text: _buildHighlightedReason(reason)),
                ),
                const SizedBox(height: 12),
                if (productId != null)
                  TextButton(
                    onPressed: () => context.push('/product/$productId'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Row(
                      children: [
                        Text(
                          l10n.scentDetails.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepCharcoal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: AppTheme.deepCharcoal,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _buildHighlightedReason(String reason) {
    final List<TextSpan> spans = [];
    final words = reason.split(' ');
    final keywords = [
      'hương',
      'nốt',
      'tinh',
      'phù',
      'hợp',
      'sang',
      'trọng',
      'cuốn',
      'hút',
      'quyến',
      'rũ',
      'scent',
      'note',
      'matching',
      'luxury',
      'elegant',
    ];

    for (var word in words) {
      final isKeyword = keywords.any((k) => word.toLowerCase().contains(k));
      spans.add(
        TextSpan(
          text: '$word ',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: isKeyword ? FontWeight.w700 : FontWeight.w400,
            color: AppTheme.deepCharcoal,
            backgroundColor: isKeyword
                ? AppTheme.accentGold.withValues(alpha: 0.1)
                : null,
            height: 1.5,
          ),
        ),
      );
    }
    return TextSpan(children: spans);
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppTheme.softTaupe.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          color: AppTheme.softTaupe.withValues(alpha: 0.3),
          size: 40,
        ),
      ),
    );
  }
}

class AuraAnalysisPainter extends CustomPainter {
  final double progress;
  AuraAnalysisPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      paint.color = AppTheme.accentGold.withValues(alpha: 0.2 + (i * 0.2));
      final radius = (size.width / 2) - (i * 15);
      final rotation = (progress * 2 * 3.14159) * (1 + (i * 0.5));

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, rotation, 2.0, false, paint);
      canvas.drawArc(rect, rotation + 3.14159, 1.0, false, paint);
    }

    final dotPaint = Paint()..color = AppTheme.accentGold;
    for (int i = 0; i < 8; i++) {
      final angle = (progress * 2 * math.pi) + (i * math.pi / 4);
      final x =
          center.dx +
          (size.width / 2.5) *
              0.8 *
              (1 + 0.1 * (progress % 1)) *
              math.cos(angle);
      final y =
          center.dy +
          (size.height / 2.5) *
              0.8 *
              (1 + 0.1 * (progress % 1)) *
              math.sin(angle);
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ShimmerGradientTransform extends GradientTransform {
  final double progress;
  const _ShimmerGradientTransform(this.progress);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      -bounds.width + (bounds.width * 2 * progress),
      0,
      0,
    );
  }
}
