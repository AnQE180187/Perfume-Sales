import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';

/// User Identity Section
/// 
/// Displays user avatar, name, and membership info.
/// 
/// Why this is a section:
/// - Centralizes user identity presentation
/// - Makes it easy to add membership badges/tiers
/// - Separates user display from profile actions
class UserIdentitySection extends StatelessWidget {
  final UserProfile profile;

  const UserIdentitySection({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.3),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.deepCharcoal.withValues(alpha: 0.08),
                  offset: const Offset(0, 3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: profile.avatarUrl != null
                  ? Image.network(
                      profile.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          const SizedBox(height: 14),
          // Name
          Text(
            profile.name,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.deepCharcoal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          // Membership info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                size: 12,
                color: AppTheme.accentGold,
              ),
              const SizedBox(width: 5),
              Text(
                profile.memberSinceText,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.mutedSilver,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.ivoryBackground,
      child: Icon(
        Icons.person_outline,
        size: 36,
        color: AppTheme.mutedSilver,
      ),
    );
  }
}
