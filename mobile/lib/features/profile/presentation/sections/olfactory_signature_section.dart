import 'package:flutter/material.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/scent_radar_chart.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class OlfactorySignatureSection extends StatelessWidget {
  final List<String> olfactoryTags;
  final VoidCallback onFindNextScent;
  final VoidCallback onViewScentProfile;

  const OlfactorySignatureSection({
    super.key,
    required this.olfactoryTags,
    required this.onFindNextScent,
    required this.onViewScentProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DNA MÙI HƯƠNG RIÊNG BIỆT',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppTheme.mutedSilver,
                ),
              ),
              Icon(Icons.auto_awesome_rounded, size: 14, color: AppTheme.accentGold),
            ],
          ),
          const SizedBox(height: 16),
          // AI Banner Section
          AiInsightCard(
            olfactoryTags: olfactoryTags,
            onFindNextScent: onFindNextScent,
            onViewScentProfile: onViewScentProfile,
          ),
        ],
      ),
    );
  }
}
