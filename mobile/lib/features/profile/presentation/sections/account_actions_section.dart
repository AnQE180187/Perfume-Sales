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
  final VoidCallback onAiPreferences;
  final VoidCallback? onPaymentMethods;
  final String? activeShipmentsText;

  const AccountActionsSection({
    super.key,
    required this.onMyOrders,
    required this.onShippingAddresses,
    required this.onAiPreferences,
    this.onPaymentMethods,
    this.activeShipmentsText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 12),
            child: Text(
              'QUẢN LÝ TÀI KHOẢN',
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
                title: 'Đơn hàng của tôi',
                subtitle: activeShipmentsText,
                subtitleIsBadge: activeShipmentsText != null,
                onTap: onMyOrders,
              ),
              const SizedBox(height: 8),
              ProfileActionTile(
                icon: Icons.map_outlined,
                title: 'Địa chỉ nhận hàng',
                onTap: onShippingAddresses,
              ),
              const SizedBox(height: 8),
              ProfileActionTile(
                icon: Icons.payment_outlined,
                title: 'Thanh toán & Thẻ',
                onTap: onPaymentMethods ?? () {},
              ),
              const SizedBox(height: 8),
              ProfileActionTile(
                icon: Icons.gesture_outlined,
                title: 'Tùy chọn mùi hương AI',
                onTap: onAiPreferences,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Logout Section
class LogoutSection extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutSection({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 40),
      child: Center(
        child: InkWell(
          onTap: onLogout,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.1),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.power_settings_new_rounded,
                  size: 14,
                  color: Colors.red.withValues(alpha: 0.35),
                ),
                const SizedBox(width: 8),
                Text(
                  'ĐĂNG XUẤT',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Colors.red.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
