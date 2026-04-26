import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../product/providers/product_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/product_section.dart';
import '../../consultation/presentation/consultation_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalizedProducts = ref.watch(personalizedProductsProvider);
    final recommendedProducts = ref.watch(recommendedProductsProvider);

    return Container(
      color: AppTheme.ivoryBackground,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header with Search
            const SliverToBoxAdapter(child: HomeHeader()),

            // Magical AI Prompt Banner
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: _AIPromptBanner(),
              ),
            ),

            // Personalized Selection
            SliverToBoxAdapter(
              child: ProductSection(
                title: AppLocalizations.of(context)!.personalizedSelection,
                productsAsync: personalizedProducts,
                isHorizontal: true,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // Tailored Recommendations
            SliverToBoxAdapter(
              child: ProductSection(
                title: AppLocalizations.of(context)!.tailoredRecommendations,
                actionText: AppLocalizations.of(context)!.viewCollection,
                productsAsync: recommendedProducts,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

class _AIPromptBanner extends StatefulWidget {
  const _AIPromptBanner();

  @override
  State<_AIPromptBanner> createState() => _AIPromptBannerState();
}

class _AIPromptBannerState extends State<_AIPromptBanner>
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
    void openConsultation() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ConsultationScreen(),
          fullscreenDialog: true,
        ),
      );
    }

    return GestureDetector(
      onTap: openConsultation,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            constraints: const BoxConstraints(minHeight: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accentGold.withValues(alpha: 0.1),
                  AppTheme.accentGold.withValues(alpha: 0.05),
                  AppTheme.creamWhite,
                ],
              ),
              border: Border.all(
                color: AppTheme.accentGold.withValues(
                  alpha: 0.1 + (0.1 * _controller.value),
                ),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGold.withValues(
                    alpha: 0.08 * (1.0 - _controller.value),
                  ),
                  blurRadius: 15 + (10 * _controller.value),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Glowing aura behind angel
                Positioned(
                  right: -10,
                  top: -10,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accentGold.withValues(
                        alpha: 0.05 * (1.0 - _controller.value),
                      ),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.homeAiBannerTitle,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.deepCharcoal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.homeAiBannerDesc,
                              maxLines: 4,
                              overflow: TextOverflow.visible,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                height: 1.4,
                                color: AppTheme.deepCharcoal.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: openConsultation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.deepCharcoal,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  l10n.askNow.toUpperCase(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Animated Angel
                      Transform.translate(
                        offset: Offset(0, 5 * math.sin(_controller.value * 2 * math.pi)),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentGold.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentGold.withValues(alpha: 0.2),
                                blurRadius: 20,
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
                      ),
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
}

