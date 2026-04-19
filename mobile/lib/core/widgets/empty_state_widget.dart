import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Empty State Widget
/// 
/// Reusable component for displaying empty states across the app.
/// Replaces duplicated empty state implementations with a luxury aesthetic.
class EmptyStateWidget extends StatelessWidget {
  /// Icon to display at the top
  final IconData icon;
  
  /// Main title text
  final String title;
  
  /// Subtitle/description text
  final String subtitle;
  
  /// Optional action button
  final Widget? action;
  
  /// Icon size (default: 42)
  final double iconSize;
  
  /// Optional background color for the icon container
  final Color? containerColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.iconSize = 42.0,
    this.containerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Luxury Icon Container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accentGold.withValues(alpha: 0.15),
                    AppTheme.accentGold.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: AppTheme.accentGold,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title - Premium Playfair Display
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepCharcoal,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Subtitle - Accessible Montserrat
            Text(
              subtitle,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                height: 1.6,
                fontWeight: FontWeight.w400,
                color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            // Optional action button
            if (action != null) ...[
              const SizedBox(height: 40),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
