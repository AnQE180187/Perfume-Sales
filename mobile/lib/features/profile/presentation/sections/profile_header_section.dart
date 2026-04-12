import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

/// Profile Header Section
///
/// Top bar with back button, title, and edit action.
///
/// Why this is a section:
/// - Separates header logic from profile content
/// - Makes it easy to customize header behavior per screen
/// - Reusable across other profile-related screens
class ProfileHeaderSection extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const ProfileHeaderSection({
    super.key,
    required this.onBack,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppTheme.deepCharcoal,
            padding: const EdgeInsets.all(8),
          ),
          Text(
            'HỒ SƠ CỦA TÔI',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              color: AppTheme.deepCharcoal,
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.settings_outlined, size: 22),
            color: AppTheme.deepCharcoal,
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}
