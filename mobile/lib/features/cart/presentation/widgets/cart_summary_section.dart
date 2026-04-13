import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
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

  double get selectedDiscount => selectedSubtotal * cartState.promoDiscount;
  double get total => selectedSubtotal - selectedDiscount;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedItems.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasSelection)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TỔNG TIỀN TẠM TÍNH',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: AppTheme.mutedSilver,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Phí vận chuyển sẽ được tính tại bước sau',
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontStyle: FontStyle.italic,
                                color: AppTheme.mutedSilver.withValues(alpha: 0.6),
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        formatVND(total),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.deepCharcoal,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              GestureDetector(
                onTap: hasSelection
                    ? () => context.push(AppRoutes.checkout)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 60,
                  decoration: BoxDecoration(
                    color: hasSelection
                        ? AppTheme.deepCharcoal
                        : AppTheme.softTaupe.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: hasSelection
                        ? [
                            BoxShadow(
                              color: AppTheme.deepCharcoal.withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      hasSelection ? 'ĐI ĐẾN THANH TOÁN' : 'HÃY CHỌN SẢN PHẨM',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: hasSelection ? Colors.white : AppTheme.mutedSilver,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
