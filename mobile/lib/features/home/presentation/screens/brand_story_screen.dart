import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_theme.dart';

class BrandStoryScreen extends StatelessWidget {
  const BrandStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            _buildHeroSection(),

            // 2. Philosophy Section
            _buildPhilosophySection(),

            // 3. The Aura Method Section
            _buildMethodSection(),

            // 4. CTA Section
            _buildCtaSection(context),

            // Bottom Spacing
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 600,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?q=80&w=2000&auto=format&fit=crop',
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
                      'SINCE 2026',
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
                    'The Intersection of',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.creamWhite,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Nature & Intellect',
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

  Widget _buildPhilosophySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OUR PHILOSOPHY',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.accentGold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '"Scent is the most intense form of memory."',
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
            'AURA was founded on a simple yet radical idea: that the ancient art of perfumery should be personal, precise, and profoundly intelligent.\n\nWe combined the sensitivity of world-class "noses" with the analytical power of advanced AI to bridge the gap between human emotion and chemical composition.',
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
            child: Image.network(
              'https://images.unsplash.com/photo-1595475242265-c30c94950637?q=80&w=1000&auto=format&fit=crop',
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

  Widget _buildMethodSection() {
    return Container(
      color: AppTheme.creamWhite,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          Text(
            'THE AURA METHOD',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 60),
          _MethodStep(
            icon: Icons.wind_power_outlined,
            title: 'Sourcing',
            description:
                'We travel the globe to source the highest quality raw materials from sustainable estates.',
          ),
          const SizedBox(height: 48),
          _MethodStep(
            icon: Icons.auto_awesome_outlined,
            title: 'Analysis',
            description:
                'Our AI engine analyzes millions of sensory data points to understand human olfactory resonance.',
          ),
          const SizedBox(height: 48),
          _MethodStep(
            icon: Icons.favorite_outline_rounded,
            title: 'Crafting',
            description:
                'Each bottle is finished by hand in our atelier, ensuring the human touch remains at our core.',
          ),
        ],
      ),
    );
  }

  Widget _buildCtaSection(BuildContext context) {
    return Container(
      height: 500,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1512201066735-b5a6881c19b8?q=80&w=2000&auto=format&fit=crop',
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
                    'Experience the Future\nof Fragrance.',
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
                      'DISCOVER MY SCENT',
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
  final IconData icon;
  final String title;
  final String description;

  const _MethodStep({
    required this.icon,
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
            color: AppTheme.ivoryBackground,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppTheme.accentGold.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(icon, color: AppTheme.accentGold, size: 32),
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
