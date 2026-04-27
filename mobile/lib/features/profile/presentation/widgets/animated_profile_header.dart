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
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
            : null,
      ),
      child: Stack(
        children: [
          // Premium Aura Background (Parallax)
          Positioned(
            top: -shrinkOffset * 0.4,
            left: -50,
            right: -50,
            height: maxExtent * 1.2,
            child: Opacity(
              opacity: headerOpacity,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.accentGold.withValues(alpha: 0.15),
                          AppTheme.ivoryBackground,
                        ],
                      ),
                    ),
                  ),
                  // Animated-like aura blobs
                  Positioned(
                    top: -20,
                    right: 40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentGold.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: -20,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.champagneGold.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
            child: Stack(
              children: [
                // Custom App Bar
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

                // Collapsing Profile Info
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
                            const SizedBox(height: 5),
                            // Avatar with Gold Ring & Shadow
                            Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.accentGold.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentGold.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: AppTheme.creamWhite,
                                  backgroundImage: profile.avatarUrl != null 
                                      ? NetworkImage(profile.avatarUrl!) 
                                      : null,
                                  child: profile.avatarUrl == null 
                                      ? Icon(Icons.person_rounded, size: avatarSize * 0.45, color: AppTheme.mutedSilver)
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              profile.name,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.deepCharcoal,
                                letterSpacing: 0.5,
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
                            const SizedBox(height: 16),
                            // Membership Info Row (Virtual Card Style)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    profile.memberSinceText.toUpperCase(),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: AppTheme.deepCharcoal.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: onEdit,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit_rounded, size: 11, color: AppTheme.accentGold),
                                        const SizedBox(width: 6),
                                        Text(
                                          'SỬA HỒ SƠ',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                            color: AppTheme.accentGold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
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
  double get maxExtent => 340.0;

  @override
  double get minExtent => 110.0;

  @override
  bool shouldRebuild(covariant AnimatedProfileHeader oldDelegate) => true;
}
