import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

import '../../models/user_profile.dart';

class ProfileCompletionProgress extends StatelessWidget {
  final UserProfile profile;

  const ProfileCompletionProgress({super.key, required this.profile});

  void _showCriteria(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.softTaupe.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.checklist_rounded, color: AppTheme.accentGold, size: 20),
                const SizedBox(width: 12),
                Text(
                  'TIÊU CHÍ HOÀN THIỆN',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(profile.completionPercentage * 100).round()}%',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...profile.completionCriteria.map((item) {
              final isDone = item['isDone'] as bool;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: isDone ? AppTheme.accentGold : AppTheme.softTaupe.withOpacity(0.4),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item['label'] as String,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                        color: isDone ? AppTheme.deepCharcoal : AppTheme.mutedSilver,
                      ),
                    ),
                    const Spacer(),
                    if (isDone)
                      const Icon(Icons.auto_awesome, size: 12, color: AppTheme.accentGold),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = profile.completionPercentage;
    final int percentInt = (percentage * 100).round();
    
    return GestureDetector(
      onLongPress: () => _showCriteria(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.getPremiumShadow(borderRadius: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hoàn thiện hồ sơ',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                Text(
                  '$percentInt%',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.softTaupe.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutExpo,
                  height: 6,
                  width: (MediaQuery.of(context).size.width - 80) * percentage,
                  decoration: BoxDecoration(
                    gradient: AppTheme.getGoldGradient(),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (percentInt < 100) ...[
              const SizedBox(height: 10),
              Text(
                'Giữ im để xem tiêu chí nhận 50 điểm thưởng!',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: AppTheme.mutedSilver,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
