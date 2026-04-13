import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> with SingleTickerProviderStateMixin {
  bool _showIntro = true;
  late AnimationController _analysisController;

  final _iconMap = <String, IconData>{
    'person': Icons.person_outline_rounded,
    'favorite': Icons.favorite_border_rounded,
    'people': Icons.people_outline_rounded,
    'star': Icons.star_border_rounded,
    'business_center': Icons.business_center_outlined,
    'calendar_month': Icons.calendar_month_outlined,
    'celebration': Icons.celebration_outlined,
    'auto_awesome': Icons.auto_awesome_outlined,
    // Budget icons (Gold stacks logic)
    'savings': Icons.savings_outlined,
    'paid': Icons.paid_outlined,
    'currency_exchange': Icons.currency_exchange_outlined,
    'payments': Icons.payments_outlined,
    'workspace_premium': Icons.workspace_premium_outlined,
    // Longevity icons
    'hourglass': Icons.hourglass_empty_rounded,
    'schedule': Icons.schedule_outlined,
    'timer': Icons.timer_outlined,
    'bolt': Icons.bolt_outlined,
    // Families
    'air': Icons.air_rounded,
    'local_florist': Icons.local_florist_outlined,
    'park': Icons.park_outlined,
    'local_fire_department': Icons.local_fire_department_outlined,
    'spa': Icons.spa_outlined,
  };

  @override
  void initState() {
    super.initState();
    _analysisController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _analysisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);

    if (quizState.isAnalyzing && !_analysisController.isAnimating) {
      _analysisController.repeat();
    } else if (!quizState.isAnalyzing && _analysisController.isAnimating) {
      _analysisController.stop();
    }

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: Stack(
        children: [
          // Background Decorative elements
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
                if (quizState.errorMessage != null)
                  _buildErrorHeader(quizState.errorMessage!),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _buildCurrentStage(quizState),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStage(QuizState state) {
    if (_showIntro) return _buildIntro(key: const ValueKey('intro'));
    if (state.isAnalyzing) return _buildAnalyzing(key: const ValueKey('analyzing'));
    if (state.isComplete) return _buildResults(state, key: const ValueKey('results'));
    return _buildQuizFlow(state, key: ValueKey('step_${state.currentStep}'));
  }

  Widget _buildErrorHeader(String message) {
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

  // 1. Intro Stage
  Widget _buildIntro({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentGold, size: 40),
          ),
          const SizedBox(height: 40),
          Text(
            'Khám phá Chữ ký\nMùi hương của Bạn',
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
            'Hãy trả lời 5 câu hỏi nhanh để AI của chúng tôi tìm ra mùi hương lý tưởng nhất dành riêng cho cá tính của bạn.',
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
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              elevation: 8,
              shadowColor: AppTheme.accentGold.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BẮT ĐẦU NGAY',
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
            'Ước tính: 2 phút',
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

  // 2. Quiz Flow Stage
  Widget _buildQuizFlow(QuizState state, {Key? key}) {
    final question = QuizState.questions[state.currentStep];
    final selectedIndex = state.answers[state.currentStep];

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
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

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (state.canGoBack)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      onPressed: () => ref.read(quizProvider.notifier).goBack(),
                    ),
                  Text(
                    'BƯỚC ${state.currentStep + 1} / ${state.totalSteps}',
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
                question.text,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepCharcoal,
                ),
              ),
              if (state.errorMessage != null && state.currentStep == state.totalSteps - 1)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton.icon(
                    onPressed: () => ref.read(quizProvider.notifier).selectOption(selectedIndex!),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('THỬ LẠI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: Colors.white,
                      textStyle: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // Options
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            itemCount: question.options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final option = question.options[index];
              final isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () => ref.read(quizProvider.notifier).selectOption(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isSelected ? AppTheme.accentGold : Colors.transparent,
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
                        color: Colors.black.withValues(alpha: isSelected ? 0.12 : 0.04),
                        blurRadius: isSelected ? 25 : 10,
                        offset: Offset(0, isSelected ? 12 : 4),
                      ),
                    ],
                  ),
                  transform: Matrix4.identity()..translate(0.0, isSelected ? -8.0 : 0.0),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.accentGold.withValues(alpha: 0.1) : AppTheme.ivoryBackground,
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
                          option.title,
                          style: GoogleFonts.montserrat(
                            fontSize: 17,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: AppTheme.deepCharcoal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: AppTheme.accentGold, size: 24),
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

  // 3. Analyzing Stage
  Widget _buildAnalyzing({Key? key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Aura Analysis Frame
          SizedBox(
            width: 200,
            height: 200,
            child: AnimatedBuilder(
              animation: _analysisController,
              builder: (context, child) {
                return CustomPaint(
                  painter: AuraAnalysisPainter(_analysisController.value),
                  child: const Center(
                    child: Icon(Icons.auto_awesome_rounded, color: AppTheme.accentGold, size: 50),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 50),
          Text(
            'PHÂN TÍCH AURA...',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentGold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Đang cá nhân hóa trải nghiệm khứu giác của bạn',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppTheme.deepCharcoal.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 40),
          
          // Terminal status
          Container(
            width: 280,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusRow('Đang xử lý dữ liệu khứu giác...', 0.5),
                _buildStatusRow('Đối chiếu nốt hương cộng hưởng...', 1.5),
                _buildStatusRow('Xác định chữ ký cá nhân...', 2.5),
                _buildStatusRow('Hoàn tất thuật toán Aura...', 3.5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String text, double delayInSec) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: (delayInSec * 1000).toInt())),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 20);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Text('>', style: TextStyle(color: AppTheme.accentGold, fontSize: 10, fontFamily: 'monospace')),
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

  // 4. Results Stage
  Widget _buildResults(QuizState state, {Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppTheme.accentGold, size: 80),
          const SizedBox(height: 24),
          Text(
            'Chữ ký Mùi hương của Bạn',
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
              'Dựa trên sở thích của bạn, thuật toán Aura đã tinh tuyển những mùi hương phù hợp nhất.',
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
          
          // Recommendations List
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
                  return _buildRecommendationCard(rec);
                },
              ),
            )
          else
            const Center(child: Text('Không tìm thấy đề xuất phù hợp.')),

          const SizedBox(height: 20),
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
                      side: BorderSide(color: AppTheme.softTaupe.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'LÀM LẠI',
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
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'KHÁM PHÁ CỬA HÀNG',
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

  Widget _buildRecommendationCard(dynamic rec) {
    final imageUrl = rec['imageUrl'] as String?;
    final name = rec['name'] as String? ?? 'Scent';
    final brand = rec['brand'] as String? ?? 'Luxury Brand';
    final reason = rec['reason'] as String? ?? '';
    final productId = rec['productId'] as String?;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
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
                      child: const Icon(Icons.favorite_border_rounded, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content Section
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
                    border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.1)),
                  ),
                  child: RichText(
                    text: _buildHighlightedReason(reason),
                  ),
                ),
                const SizedBox(height: 12),
                if (productId != null)
                  TextButton(
                    onPressed: () => context.push('/product/$productId'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Row(
                      children: [
                        Text(
                          'CHI TIẾT MÙI HƯƠNG',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepCharcoal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.deepCharcoal),
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
    
    // Simple logic to highlight perfume keywords
    final keywords = ['hương', 'nốt', 'tinh', 'phù', 'hợp', 'sang', 'trọng', 'cuốn', 'hút', 'quyến', 'rũ'];

    for (var word in words) {
      final isKeyword = keywords.any((k) => word.toLowerCase().contains(k));
      spans.add(TextSpan(
        text: '$word ',
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: isKeyword ? FontWeight.w700 : FontWeight.w400,
          color: AppTheme.deepCharcoal,
          backgroundColor: isKeyword ? AppTheme.accentGold.withValues(alpha: 0.1) : null,
          height: 1.5,
        ),
      ));
    }
    return TextSpan(children: spans);
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppTheme.softTaupe.withValues(alpha: 0.1),
      child: Center(
        child: Icon(Icons.shopping_bag_outlined, color: AppTheme.softTaupe.withValues(alpha: 0.3), size: 40),
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

    // Draw three silk-like rotating paths
    for (int i = 0; i < 3; i++) {
      paint.color = AppTheme.accentGold.withValues(alpha: 0.2 + (i * 0.2));
      final radius = (size.width / 2) - (i * 15);
      final rotation = (progress * 2 * 3.14159) * (1 + (i * 0.5));
      
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, rotation, 2.0, false, paint);
      canvas.drawArc(rect, rotation + 3.14159, 1.0, false, paint);
    }

    // Draw fluid particles (dots)
    final dotPaint = Paint()..color = AppTheme.accentGold;
    for (int i = 0; i < 8; i++) {
        final angle = (progress * 2 * math.pi) + (i * math.pi / 4);
        final x = center.dx + (size.width / 2.5) * 0.8 * (1 + 0.1 * (progress % 1)) * math.cos(angle);
        final y = center.dy + (size.height / 2.5) * 0.8 * (1 + 0.1 * (progress % 1)) * math.sin(angle);
        canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
