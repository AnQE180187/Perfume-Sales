import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/profile_action_tile.dart';

/// Account Actions Section
/// 
/// List of account-related navigation items.
/// 
/// Why this is a section:
/// - Groups all account actions in one place
/// - Makes it easy to reorder or add new actions
/// - Separates navigation from profile display
class AccountActionsSection extends StatelessWidget {
  final VoidCallback onMyOrders;
  final VoidCallback onShippingAddresses;
  final VoidCallback onPaymentMethods;
  final VoidCallback onAiPreferences;
  final String? activeShipmentsText;

  const AccountActionsSection({
    super.key,
    required this.onMyOrders,
    required this.onShippingAddresses,
    required this.onPaymentMethods,
    required this.onAiPreferences,
    this.activeShipmentsText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              ProfileActionTile(
                icon: Icons.shopping_bag_outlined,
                title: 'My Orders',
                subtitle: activeShipmentsText,
                onTap: onMyOrders,
              ),
              ProfileActionTile(
                icon: Icons.local_shipping_outlined,
                title: 'Shipping Addresses',
                onTap: onShippingAddresses,
              ),
              ProfileActionTile(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                onTap: onPaymentMethods,
              ),
              ProfileActionTile(
                icon: Icons.tune_outlined,
                title: 'AI Preferences',
                onTap: onAiPreferences,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Logout Section
/// 
/// Separated logout action with low visual emphasis.
/// 
/// Why this is separate:
/// - Logout is destructive and should be visually distinct
/// - Easy to customize logout behavior
/// - Can add logout confirmation modal here
class LogoutSection extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutSection({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: TextButton(
        onPressed: onLogout,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              size: 14,
              color: AppTheme.mutedSilver,
            ),
            const SizedBox(width: 7),
            Text(
              'Log Out',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.mutedSilver,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
