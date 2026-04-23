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
  final VoidCallback onSettings;
  final VoidCallback? onPaymentMethods;
  final String? activeShipmentsText;

  const AccountActionsSection({
    super.key,
    required this.onMyOrders,
    required this.onShippingAddresses,
    required this.onAiPreferences,
    required this.onSettings,
    this.onPaymentMethods,
    this.activeShipmentsText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 12),
            child: Text(
              l10n.accountManagement,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: AppTheme.mutedSilver,
              ),
            ),
          ),
          Column(
            children: [
              ProfileActionTile(
                icon: Icons.auto_stories_outlined,
                title: l10n.myOrders,
                subtitle: activeShipmentsText,
                subtitleIsBadge: activeShipmentsText != null,
                onTap: onMyOrders,
              ),
              const SizedBox(height: 8),
              ProfileActionTile(
                icon: Icons.map_outlined,
                title: l10n.shippingAddresses,
                onTap: onShippingAddresses,
              ),
              const SizedBox(height: 8),
              ProfileActionTile(
                icon: Icons.payment_outlined,
                title: l10n.paymentAndCards,
                onTap: onPaymentMethods ?? () {},
              ),
              const SizedBox(height: 8),
              ProfileActionTile(
                icon: Icons.gesture_outlined,
                title: l10n.aiScentPreferences,
                onTap: onAiPreferences,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

