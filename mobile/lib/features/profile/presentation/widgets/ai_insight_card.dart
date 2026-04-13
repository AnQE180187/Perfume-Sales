import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/luxury_button.dart';

/// AI Insight Card - Olfactory Signature
///
/// Reusable card displaying user's AI-generated scent preferences.
/// Can be used on Profile, Home, or Onboarding screens.
///
/// Why this is extracted:
/// - Reusable across multiple screens
/// - Separates AI insight presentation from profile logic
/// - Makes it easy to A/B test different insight card designs
class AiInsightCard extends StatelessWidget {
  final List<String> olfactoryTags;
  final VoidCallback onFindNextScent;
  final VoidCallback onViewScentProfile;

  const AiInsightCard({
    super.key,
    required this.olfactoryTags,
    required this.onFindNextScent,
    required this.onViewScentProfile,
  });

  @override
  Widget build(BuildContext context) {
    // Show at most 3 tags to keep card compact
    final displayTags = olfactoryTags.take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
      decoration: BoxDecoration(
        color: AppTheme.deepCharcoal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // High-end photographic background
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1541544181051-e46607bc22a4?w=800', // Reliable placeholder
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppTheme.deepCharcoal.withValues(alpha: 0.8),
                  child: const Center(
                    child: Icon(Icons.auto_awesome_rounded, color: AppTheme.accentGold, size: 40),
                  ),
                ),
              ),
            ),
            // Dark overlay for readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentGold, size: 12),
                      const SizedBox(width: 8),
                      Text(
                        'AI SCENT SIGNATURE',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Dấu ấn mùi hương riêng biệt',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Glassmorphism tags
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: displayTags.map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                tag.toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ).toList(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Sleek CTA with glow
                      GestureDetector(
                        onTap: onFindNextScent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentGold.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'KHÁM PHÁ',
                                style: GoogleFonts.montserrat(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.deepCharcoal,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, size: 10, color: AppTheme.deepCharcoal),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
