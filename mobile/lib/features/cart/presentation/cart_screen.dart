import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/cart_provider.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/cart_summary_section.dart';
import 'widgets/clear_cart_modal.dart';
import 'widgets/price_summary.dart';
import 'widgets/promo_code_section.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _selectAll = true;
  final Set<String> _selectedItems = {};
  bool _showAIBanner = true;
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    // Initialize selected items
    if (_selectedItems.isEmpty && cartState.items.isNotEmpty) {
      _selectedItems.addAll(cartState.items.map((item) => item.id));
    }

    final selectedSubtotal = cartState.items
        .where((item) => _selectedItems.contains(item.id))
        .fold(0.0, (sum, item) => sum + item.subtotal);
    final selectedDiscount = selectedSubtotal * cartState.promoDiscount;
    final total = selectedSubtotal - selectedDiscount;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: _buildAppBar(cartState),
      body: cartState.isLoading && cartState.items.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentGold),
            )
          : cartState.items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      // AI Upsell Banner (dismissible)
                      if (_showAIBanner) ...[
                        _AIUpsellBanner(
                          onDismiss: () =>
                              setState(() => _showAIBanner = false),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Cart Items
                      ...cartState.items.map((item) {
                        return CartItemTile(
                          item: item,
                          isSelected: _selectedItems.contains(item.id),
                          onSelectChanged: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedItems.add(item.id);
                              } else {
                                _selectedItems.remove(item.id);
                              }
                              _selectAll =
                                  _selectedItems.length ==
                                  cartState.items.length;
                            });
                          },
                          onQuantityChanged: (quantity) {
                            ref
                                .read(cartProvider.notifier)
                                .updateQuantity(item.id, quantity);
                          },
                          onRemove: () {
                            ref.read(cartProvider.notifier).removeItem(item.id);
                            setState(() => _selectedItems.remove(item.id));
                          },
                        );
                      }),

                      const SizedBox(height: 12),

                      // Promo Code Section
                      PromoCodeSection(
                        controller: _promoController,
                        hasPromoCode: cartState.promoCode != null,
                        promoCode: cartState.promoCode,
                        promoDiscount: cartState.promoDiscount,
                        isLoading: cartState.isLoading,
                      ),

                      const SizedBox(height: 12),

                      // Price Breakdown
                      if (_selectedItems.isNotEmpty)
                        PriceSummary(
                          subtotal: selectedSubtotal,
                          discount: selectedDiscount,
                          total: total,
                        ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Sticky Checkout CTA
                CartSummarySection(
                  cartState: cartState,
                  selectedItems: _selectedItems,
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(CartState cartState) {
    return AppBar(
      backgroundColor: const Color(0xFFFAF7F2),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          size: 20, // 👈 thêm dòng này
          color: AppTheme.deepCharcoal,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Giỏ hàng (${cartState.items.length})',
        style: GoogleFonts.cormorantGaramond(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.deepCharcoal,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              if (_selectAll) {
                _selectedItems.clear();
              } else {
                _selectedItems.addAll(cartState.items.map((item) => item.id));
              }
              _selectAll = !_selectAll;
            });
          },
          child: Text(
            _selectAll ? 'Bỏ chọn hết' : 'Chọn tất cả',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.deepCharcoal,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            showClearCartModal(
              context,
              onClearConfirmed: () {
                ref.read(cartProvider.notifier).clearCart();
                _selectedItems.clear();
                Navigator.pop(context);
              },
            );
          },
          child: Text(
            'Xóa tất cả',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.accentGold,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 72,
              color: AppTheme.mutedSilver.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Giỏ hàng đang trống',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Khám phá bộ sưu tập nước hoa cao cấp',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: AppTheme.mutedSilver,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'KHÁM PHÁ BỘ SƯU TẬP',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIUpsellBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  const _AIUpsellBanner({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppTheme.accentGold,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gợi ý từ PerfumeGPT',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                Text(
                  'Thêm mẫu thử Golden Amber để hoàn thiện bộ sưu tập.',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: AppTheme.deepCharcoal.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Thêm',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDismiss,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppTheme.mutedSilver,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
