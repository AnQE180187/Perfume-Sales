import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/onboarding_provider.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';

/// Data model for each onboarding slide.
class _SlideData {
  final String title;
  final String subtitle;
  final String bgImagePath;
  final Color accentColor;

  const _SlideData({
    required this.title,
    required this.subtitle,
    required this.bgImagePath,
    required this.accentColor,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _contentAnimCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  late final AnimationController _floatAnimCtrl;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _contentAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _contentAnimCtrl,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _contentAnimCtrl, curve: Curves.easeOutCubic),
        );
    _contentAnimCtrl.forward();

    _floatAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: _floatAnimCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _contentAnimCtrl.dispose();
    _floatAnimCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _contentAnimCtrl.reset();
    _contentAnimCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final slides = [
      _SlideData(
        title: l10n.onboarding1Title,
        subtitle: l10n.onboarding1Subtitle,
        bgImagePath: 'assets/images/onboarding_bg_1.png',
        accentColor: const Color(0xFFD4A574),
      ),
      _SlideData(
        title: l10n.onboarding2Title,
        subtitle: l10n.onboarding2Subtitle,
        bgImagePath: 'assets/images/onboarding_bg_2.png',
        accentColor: const Color(0xFFB8A080),
      ),
      _SlideData(
        title: l10n.onboarding3Title,
        subtitle: l10n.onboarding3Subtitle,
        bgImagePath: 'assets/images/onboarding_bg_3.png',
        accentColor: const Color(0xFFAA8EC4),
      ),
    ];

    final slide = slides[_currentPage];

    return Scaffold(
      body: Stack(
        children: [
          // ── Cinematic Background Image ──
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              layoutBuilder: (child, List<Widget> previousChildren) {
                return Stack(
                  children: [
                    ...previousChildren,
                    if (child != null) child,
                  ],
                );
              },
              child: Image.asset(
                slide.bgImagePath,
                key: ValueKey(slide.bgImagePath),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // ── Gradient Overlay for Readability ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),



          // ── Page swipe area (invisible, for gesture) ──
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: slides.length,
            itemBuilder: (_, __) => const SizedBox.expand(),
          ),

          // ── Top bar: brand + skip ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.appName.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 8,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  if (_currentPage < slides.length - 1)
                    GestureDetector(
                      onTap: () async {
                        await ref
                            .read(onboardingProvider.notifier)
                            .completeOnboarding();
                        if (context.mounted) context.go('/login');
                      },
                      child: Text(
                        'BỎ QUA',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),



          // ── Bottom content ──
          Positioned(
            bottom: bottomPad + 40,
            left: 28,
            right: 28,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dot indicators
                    _buildIndicators(slides.length),
                    const SizedBox(height: 28),

                    // Title
                    Text(
                      slide.title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      slide.subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        height: 1.6,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Buttons
                    _buildButtons(context, l10n, slides, slide),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators(int count) {
    return Row(
      children: List.generate(count, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 8),
          height: 3,
          width: isActive ? 32 : 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: isActive
                ? AppTheme.accentGold
                : Colors.white.withValues(alpha: 0.25),
          ),
        );
      }),
    );
  }

  Widget _buildButtons(
    BuildContext context,
    AppLocalizations l10n,
    List<_SlideData> slides,
    _SlideData currentSlide,
  ) {
    final isLast = _currentPage == slides.length - 1;

    if (isLast) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () async {
            await ref.read(onboardingProvider.notifier).completeOnboarding();
            if (context.mounted) context.go('/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.deepCharcoal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          child: Text(l10n.beginJourney.toUpperCase()),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.white,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.next.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
