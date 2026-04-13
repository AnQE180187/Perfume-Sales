import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/providers/settings_provider.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../widgets/profile_action_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.deepCharcoal, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.settings.toUpperCase(),
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppTheme.deepCharcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildSectionHeader(l10n.appSettings),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: l10n.language,
            trailing: ref.watch(localeProvider).languageCode == 'vi'
                ? 'Tiếng Việt'
                : 'English',
            onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
          ),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: l10n.darkMode,
            trailingWidget: Switch.adaptive(
              value: ref.watch(themeModeProvider) == ThemeMode.dark,
              activeColor: AppTheme.accentGold,
              onChanged: (val) =>
                  ref.read(themeModeProvider.notifier).toggleTheme(),
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.support),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            title: l10n.helpCenter,
            onTap: () => context.push(AppRoutes.helpCenter),
          ),
          _SettingsTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: l10n.contactUs,
            onTap: () => context.push(AppRoutes.contactUs),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.legal),
          _SettingsTile(
            icon: Icons.policy_outlined,
            title: l10n.privacyPolicy,
            onTap: () => context.push(AppRoutes.privacyPolicy),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: l10n.termsOfService,
            onTap: () => context.push(AppRoutes.termsOfService),
          ),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Text(
                  'LUMINA ATELIER',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                    color: AppTheme.mutedSilver.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.version} 1.0.2 (Build 24)',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.mutedSilver.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: AppTheme.mutedSilver,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.trailingWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.ivoryBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: AppTheme.deepCharcoal),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.deepCharcoal,
                    ),
                  ),
                ),
                if (trailing != null)
                  Text(
                    trailing!,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.mutedSilver,
                    ),
                  ),
                if (trailingWidget != null) trailingWidget!,
                if (onTap != null && trailing == null && trailingWidget == null)
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppTheme.mutedSilver),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

