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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.deepCharcoal,
        borderRadius: BorderRadius.circular(14),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1541544181051-e46607bc22a4?w=800',
          ),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppTheme.accentGold,
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                'AI ANALYSIS',
                style: GoogleFonts.montserrat(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                  color: AppTheme.accentGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your Olfactory Signature',
            style: GoogleFonts.playfairDisplay(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Based on your recent activity',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: olfactoryTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          LuxuryButton(
            text: 'Find my next scent',
            onPressed: onFindNextScent,
            trailingIcon: Icons.arrow_forward,
            height: 44,
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: onViewScentProfile,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View my scent profile',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
