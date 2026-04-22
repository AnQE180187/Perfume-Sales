import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

/// Profile Action Tile
///
/// Reusable navigation list item for profile actions.
/// Used for: My Orders, Shipping Addresses, Payment Methods, AI Preferences.
///
/// Why this widget exists:
/// - Eliminates code duplication across profile items
/// - Ensures consistent spacing and styling
/// - Makes adding new profile actions trivial
class ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool subtitleIsBadge;

  const ProfileActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.subtitleIsBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.softTaupe.withValues(alpha: 0.1),
                width: 0.8,
              ),
            ),
          ),
          child: Row(
            children: [
              // Icon box with gold theme
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.accentGold.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: Icon(icon, color: AppTheme.accentGold, size: 20),
              ),
              const SizedBox(width: 18),
              // Title
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal.withValues(alpha: 0.9),
                    letterSpacing: 1,
                  ),
                ),
              ),
              // Trailing: badge pill or chevron
              if (subtitle != null && subtitleIsBadge)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    subtitle!.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.deepCharcoal,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else if (subtitle != null)
                Text(
                  subtitle!,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: AppTheme.mutedSilver,
                  ),
                ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: AppTheme.mutedSilver.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
