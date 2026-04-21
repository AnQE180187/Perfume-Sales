import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class BrandStoryScreen extends StatelessWidget {
  const BrandStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.creamWhite,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Cinematic Hero Section
            _buildHeroSection(l10n),
 
            // 2. Philosophy Section
            _buildPhilosophySection(l10n),
 
            // 3. The Aura Method Section
            _buildMethodSection(l10n),
 
            // 4. CTA Section
            _buildCtaSection(context, l10n),

            // Bottom Spacing
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(AppLocalizations l10n) {
    return Container(
      height: 600,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/brand_hero.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppTheme.deepCharcoal.withValues(alpha: 0.9),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.accentGold,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
          // Dark Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.deepCharcoal.withValues(alpha: 0.7),
                    AppTheme.deepCharcoal.withValues(alpha: 0.2),
                    AppTheme.deepCharcoal.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.creamWhite.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      l10n.sinceLabel,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.creamWhite,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.storyHeroSub,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.creamWhite,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    l10n.storyHeroTitle,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.creamWhite,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: 1,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.creamWhite,
                          AppTheme.creamWhite.withValues(alpha: 0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhilosophySection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.philosophyLabel,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.accentGold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '"${l10n.philosophyQuote}"',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: AppTheme.deepCharcoal,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            l10n.philosophyDesc,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: AppTheme.deepCharcoal,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 50),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/brand_philosophy.png',
              height: 450,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 450,
                width: double.infinity,
                color: AppTheme.softTaupe.withValues(alpha: 0.2),
                child: const Center(
                  child: Icon(
                    Icons.science_outlined,
                    color: AppTheme.accentGold,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSection(AppLocalizations l10n) {
    return Container(
      color: AppTheme.creamWhite,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          Text(
            l10n.methodLabel,
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 60),
          _MethodStep(
            imagePath: 'assets/icons/icon_sourcing.png',
            title: l10n.methodSourcingTitle,
            description: l10n.methodSourcingDesc,
          ),
          const SizedBox(height: 48),
          _MethodStep(
            imagePath: 'assets/icons/icon_analysis.png',
            title: l10n.methodAnalysisTitle,
            description: l10n.methodAnalysisDesc,
          ),
          const SizedBox(height: 48),
          _MethodStep(
            imagePath: 'assets/icons/icon_crafting.png',
            title: l10n.methodCraftingTitle,
            description: l10n.methodCraftingDesc,
          ),
        ],
      ),
    );
  }

  Widget _buildCtaSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 500,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/brand_cta.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppTheme.deepCharcoal,
                child: const Center(
                  child: Icon(
                    Icons.star_border_rounded,
                    color: AppTheme.accentGold,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.ctaStoryTitle,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.creamWhite,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () => context.push(AppRoutes.quiz),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.deepCharcoal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 10,
                      shadowColor: AppTheme.accentGold.withValues(alpha: 0.4),
                    ),
                    child: Text(
                      l10n.ctaStoryBtn,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodStep extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const _MethodStep({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppTheme.accentGold.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentGold.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppTheme.deepCharcoal,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            description,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.mutedSilver,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
