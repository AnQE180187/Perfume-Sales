import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/settings_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.yourProfile.toUpperCase(),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  letterSpacing: 4,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 48),
              
              // Profile Header
              profileAsync.when(
                data: (profile) {
                  final roles = (profile?['roles'] as List?)?.cast<String>() ?? [];
                  final roleLabel = roles.contains('admin') 
                    ? 'ADMINISTRATIVE COUNCIL' 
                    : roles.contains('staff') 
                      ? 'ATELIER STAFF' 
                      : 'PRESTIGE MEMBER';

                  return Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.5),
                            ),
                            child: profile?['avatar_url'] != null 
                              ? Image.network(profile!['avatar_url'], fit: BoxFit.cover) 
                              : Icon(Icons.person_outline, color: Theme.of(context).primaryColor, size: 32),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile?['full_name'] ?? l10n.atelierMember.toUpperCase(),
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.military_tech, color: Theme.of(context).colorScheme.primary, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      roleLabel,
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Points Display
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LOYALTY POINTS'.toUpperCase(),
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${profile?['loyalty_points'] ?? 0}',
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
                                ),
                              ],
                            ),
                            Icon(Icons.trending_up, color: Theme.of(context).colorScheme.primary, size: 32),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.champagneGold, strokeWidth: 1)),
                error: (e, _) => Text('Error: $e'),
              ),
              
              const SizedBox(height: 64),
              
              _buildSectionTitle(context, l10n.theAtelier.toUpperCase()),
              _buildMenuItem(
                context, 
                Icons.history, 
                l10n.acquisitionHistory.toUpperCase(),
                onTap: () => context.push('/orders'),
              ),
              _buildMenuItem(
                context, 
                Icons.favorite_border, 
                l10n.curatedCollection.toUpperCase(),
                onTap: () => context.push('/wishlist'),
              ),
              _buildMenuItem(context, Icons.psychology_outlined, l10n.neuralDnaArchive.toUpperCase()),
              
              const SizedBox(height: 48),
              _buildSectionTitle(context, l10n.system.toUpperCase()),
              
              // Theme Toggle
              _buildMenuItem(
                context, 
                themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode, 
                '${l10n.appearance.toUpperCase()}: ${themeMode.name.toUpperCase()}',
                onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
              ),
              
              // Language Toggle
              _buildMenuItem(
                context, 
                Icons.language, 
                '${l10n.language.toUpperCase()}: ${locale.languageCode.toUpperCase()}',
                onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
              ),
              
              _buildMenuItem(context, Icons.help_outline, l10n.concierge.toUpperCase()),
              
              const SizedBox(height: 64),
              
              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: Text(
                    l10n.disconnectSession.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.redAccent,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          fontSize: 10,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 18),
            const SizedBox(width: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.3), size: 12),
          ],
        ),
      ),
    );
  }
}
