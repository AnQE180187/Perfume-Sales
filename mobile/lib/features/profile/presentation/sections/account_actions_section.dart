import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../widgets/profile_action_tile.dart';

/// Account Actions Section
///
/// List of account-related navigation items.
class AccountActionsSection extends StatelessWidget {
  final VoidCallback onMyOrders;
  final VoidCallback onShippingAddresses;
  final VoidCallback onAiPreferences;
  final VoidCallback onQuizHistory;
  final VoidCallback onSettings;
  final VoidCallback? onPaymentMethods;
  final String? activeShipmentsText;

  const AccountActionsSection({
    super.key,
    required this.onMyOrders,
    required this.onShippingAddresses,
    required this.onAiPreferences,
    required this.onQuizHistory,
    required this.onSettings,
    this.onPaymentMethods,
    this.activeShipmentsText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroup(
            context,
            l10n.accountManagement,
            [
              ProfileActionTile(
                icon: Icons.shopping_bag_outlined,
                title: l10n.myOrders,
                subtitle: activeShipmentsText,
                subtitleIsBadge: activeShipmentsText != null,
                onTap: onMyOrders,
              ),
              const Divider(height: 1, indent: 56, color: AppTheme.softTaupe, thickness: 0.2),
              ProfileActionTile(
                icon: Icons.location_on_outlined,
                title: l10n.shippingAddresses,
                onTap: onShippingAddresses,
              ),
              const Divider(height: 1, indent: 56, color: AppTheme.softTaupe, thickness: 0.2),
              ProfileActionTile(
                icon: Icons.credit_card_outlined,
                title: l10n.paymentAndCards,
                onTap: onPaymentMethods ?? () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildGroup(
            context,
            'CÁ NHÂN HÓA AI',
            [
              ProfileActionTile(
                icon: Icons.psychology_outlined,
                title: l10n.aiScentPreferences,
                onTap: onAiPreferences,
              ),
              const Divider(height: 1, indent: 56, color: AppTheme.softTaupe, thickness: 0.2),
              ProfileActionTile(
                icon: Icons.history_rounded,
                title: l10n.quizHistoryTitle,
                onTap: onQuizHistory,
              ),
              const Divider(height: 1, indent: 56, color: AppTheme.softTaupe, thickness: 0.2),
              ProfileActionTile(
                icon: Icons.settings_outlined,
                title: l10n.settings,
                onTap: onSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppTheme.mutedSilver,
            ),
          ),
        ),
        Container(
          decoration: AppTheme.getPremiumShadow(borderRadius: 20),
          child: Column(children: children),
        ),
      ],
    );
  }
}

