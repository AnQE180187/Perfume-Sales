import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/achievement_model.dart';

class AchievementBadges extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementBadges({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'THÀNH TỰU ĐÃ ĐẠT',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppTheme.deepCharcoal.withOpacity(0.5),
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _BadgeIcon(achievement: achievement);
            },
          ),
        ),
      ],
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final Achievement achievement;

  const _BadgeIcon({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: achievement.isUnlocked 
          ? 'Đã đạt được: ${achievement.description}'
          : 'Chưa đạt: ${achievement.description}',
      preferBelow: false,
      verticalOffset: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: AppTheme.deepCharcoal.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentGold.withOpacity(0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      textStyle: GoogleFonts.montserrat(
        color: AppTheme.creamWhite,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: achievement.isUnlocked 
                  ? AppTheme.accentGold.withOpacity(0.1)
                  : AppTheme.mutedSilver.withOpacity(0.1),
              border: Border.all(
                color: achievement.isUnlocked 
                    ? AppTheme.accentGold 
                    : AppTheme.mutedSilver.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.isUnlocked 
                  ? AppTheme.accentGold 
                  : AppTheme.mutedSilver.withOpacity(0.5),
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: achievement.isUnlocked 
                    ? AppTheme.deepCharcoal 
                    : AppTheme.mutedSilver,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
