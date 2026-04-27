import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/achievement_model.dart';
import '../../../../l10n/app_localizations.dart';

class AchievementBadges extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementBadges({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            l10n.achievementsHeader,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppTheme.deepCharcoal.withValues(alpha: 0.5),
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
    final l10n = AppLocalizations.of(context)!;
    
    // Dynamic translation based on ID
    String title = achievement.title;
    String description = achievement.description;
    
    switch (achievement.id) {
      case 'welcome':
        title = l10n.achWelcomeTitle;
        description = l10n.achWelcomeDesc;
        break;
      case 'explorer':
        title = l10n.achExplorerTitle;
        description = l10n.achExplorerDesc;
        break;
      case 'notemaster':
        title = l10n.achNoteMasterTitle;
        description = l10n.achNoteMasterDesc;
        break;
      case 'shopper':
        title = l10n.achShopperTitle;
        description = l10n.achShopperDesc;
        break;
      case 'reviewer':
        title = l10n.achReviewerTitle;
        description = l10n.achReviewerDesc;
        break;
    }

    final statusText = achievement.isUnlocked 
        ? (l10n.localeName == 'vi' ? 'Đã đạt được' : 'Achieved')
        : (l10n.localeName == 'vi' ? 'Chưa đạt' : 'Locked');

    return Tooltip(
      message: '$statusText: $description',
      preferBelow: false,
      verticalOffset: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: AppTheme.deepCharcoal.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: achievement.isUnlocked 
                  ? Colors.white 
                  : AppTheme.mutedSilver.withValues(alpha: 0.05),
              border: Border.all(
                color: achievement.isUnlocked 
                    ? AppTheme.accentGold.withValues(alpha: 0.5) 
                    : AppTheme.mutedSilver.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: achievement.isUnlocked ? [
                BoxShadow(
                  color: AppTheme.accentGold.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ] : null,
            ),
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: achievement.isUnlocked 
                      ? AppTheme.accentGold.withValues(alpha: 0.08)
                      : Colors.transparent,
                ),
                child: Icon(
                  achievement.icon,
                  color: achievement.isUnlocked 
                      ? AppTheme.accentGold 
                      : AppTheme.mutedSilver.withValues(alpha: 0.4),
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              title,
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
