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

  const UserIdentitySection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          // Avatar with premium gold stroke
          Container(
            width: 110,
            height: 110,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
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
          ),
          const SizedBox(height: 24),
          // Name with editorial serif
          Text(
            profile.name.toUpperCase(),
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.deepCharcoal,
              letterSpacing: 1.5,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Membership badge with minimalist star
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppTheme.softTaupe.withValues(alpha: 0.3),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 10, color: AppTheme.accentGold),
                const SizedBox(width: 6),
                Text(
                  profile.memberSinceText.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.accentGold.withValues(alpha: 0.06),
      child: Icon(
        Icons.person_outline,
        size: 42,
        color: AppTheme.accentGold.withValues(alpha: 0.5),
      ),
    );
  }
}
