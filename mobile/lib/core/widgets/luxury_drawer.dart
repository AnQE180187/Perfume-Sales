import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../../features/auth/providers/auth_provider.dart';

class LuxuryDrawer extends ConsumerWidget {
  const LuxuryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Drawer(
      backgroundColor: AppTheme.creamWhite,
      child: SafeArea(
        child: Column(
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(24),
              child: userProfile.when(
                data: (profile) {
                  if (profile == null) return const SizedBox.shrink();
                  
                  return Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.champagneGold,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: AppTheme.softTaupe,
                          backgroundImage: profile['avatar_url'] != null
                              ? NetworkImage(profile['avatar_url'])
                              : null,
                          child: profile['avatar_url'] == null
                              ? Text(
                                  (profile['full_name'] as String? ?? 'U')[0].toUpperCase(),
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accentGold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // User Name
                      Text(
                        profile['full_name'] ?? 'Guest',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Status/Role
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.champagneGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Privilege Member',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            const Divider(color: AppTheme.softTaupe, height: 1),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerMenuItem(
                    icon: Icons.local_florist_outlined,
                    title: 'Fragrance Library',
                    onTap: () {
                      context.pop();
                      context.push('/explore');
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.diamond_outlined,
                    title: 'Exclusive Collections',
                    onTap: () {
                      context.pop();
                      // Navigate to exclusive collections
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.psychology_outlined,
                    title: 'AI Scent Profile',
                    onTap: () {
                      context.pop();
                      // Navigate to AI profile
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.book_outlined,
                    title: 'Scent Journal',
                    onTap: () {
                      context.pop();
                      // Navigate to scent journal
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Privilege Club',
                    onTap: () {
                      context.pop();
                      // Navigate to privilege club
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.support_agent_outlined,
                    title: 'Concierge Support',
                    onTap: () {
                      context.pop();
                      // Navigate to support
                    },
                  ),
                ],
              ),
            ),

            const Divider(color: AppTheme.softTaupe, height: 1),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DrawerMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      context.pop();
                      // Navigate to settings
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.logout_outlined,
                    title: 'Logout',
                    onTap: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.mutedSilver,
        size: 22,
      ),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppTheme.deepCharcoal,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hoverColor: AppTheme.champagneGold.withValues(alpha: 0.1),
    );
  }
}
