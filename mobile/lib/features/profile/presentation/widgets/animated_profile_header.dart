import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';

class AnimatedProfileHeader extends SliverPersistentHeaderDelegate {
  final UserProfile profile;
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final VoidCallback onEdit;

  AnimatedProfileHeader({
    required this.profile,
    required this.onBack,
    required this.onSettings,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / maxExtent;
    final double avatarSize = (110 * (1 - progress)).clamp(60, 110);
    final double titleOpacity = (progress * 2).clamp(0, 1);
    final double headerOpacity = (1 - progress).clamp(0, 1);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.ivoryBackground,
        boxShadow: overlapsContent
            ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
            : null,
      ),
      child: Stack(
        children: [
          // Background Parallax
          Positioned(
            top: -shrinkOffset * 0.5,
            left: 0,
            right: 0,
            height: maxExtent,
            child: Opacity(
              opacity: headerOpacity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.accentGold.withOpacity(0.15),
                      AppTheme.ivoryBackground,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
            child: Stack(
              children: [
                // Custom App Bar (Fixed at top of sliver)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        ),
                        Opacity(
                          opacity: titleOpacity,
                          child: Text(
                            profile.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.deepCharcoal,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onSettings,
                          icon: const Icon(Icons.settings_outlined, size: 22),
                        ),
                      ],
                    ),
                  ),
                ),

                // Collapsing Profile Info (Fades out and moves)
                if (shrinkOffset < maxExtent - minExtent + 20)
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: headerOpacity,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.deepCharcoal.withOpacity(0.1),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundColor: AppTheme.creamWhite,
                                backgroundImage: profile.avatarUrl != null 
                                    ? NetworkImage(profile.avatarUrl!) 
                                    : null,
                                child: profile.avatarUrl == null 
                                    ? Icon(Icons.person, size: avatarSize * 0.5, color: AppTheme.mutedSilver)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              profile.name,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.deepCharcoal,
                              ),
                            ),
                            Text(
                              profile.email,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: AppTheme.mutedSilver,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    profile.memberSinceText.toUpperCase(),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: AppTheme.deepCharcoal.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: onEdit,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGold.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit_rounded, size: 10, color: AppTheme.accentGold),
                                        const SizedBox(width: 4),
                                        Text(
                                          'SỬA HỒ SƠ',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                            color: AppTheme.accentGold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 300.0;

  @override
  double get minExtent => 100.0;

  @override
  bool shouldRebuild(covariant AnimatedProfileHeader oldDelegate) => true;
}
