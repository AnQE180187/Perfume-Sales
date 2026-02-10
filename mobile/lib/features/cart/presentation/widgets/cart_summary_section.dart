import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/luxury_button.dart';
import '../../providers/cart_provider.dart';

class CartSummarySection extends StatelessWidget {
  final CartState cartState;
  final Set<String> selectedItems;

  const CartSummarySection({
    super.key,
    required this.cartState,
    required this.selectedItems,
  });

  double get selectedSubtotal {
    return cartState.items
        .where((item) => selectedItems.contains(item.id))
        .fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get estimatedTax => selectedSubtotal * 0.08;
  double get total => selectedSubtotal + estimatedTax;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎟 Voucher
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        size: 16,
                        color: AppTheme.accentGold,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Apply voucher',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.deepCharcoal,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppTheme.mutedSilver,
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 10),

              // 💰 Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                      Text(
                        'USD',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: AppTheme.mutedSilver,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.deepCharcoal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 🟡 CTA
              Builder(
                builder: (context) => LuxuryButton(
                  text: 'Proceed to Checkout',
                  trailingIcon: Icons.arrow_forward,
                  height: 42,
                  onPressed: selectedItems.isEmpty
                      ? null
                      : () => context.push(AppRoutes.checkout),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
