import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/cart_provider.dart';
import '../providers/cart_selection_provider.dart';
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
  final TextEditingController _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Defer initial selection sync to after the first build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final items = ref.read(cartProvider).items;
      if (items.isNotEmpty) {
        ref
            .read(cartSelectionProvider.notifier)
            .initFromCart(items.map((e) => e.id).toList());
      }
    });
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _removeSelectedItems(WidgetRef ref, Set<String> selectedIds) {
    for (final id in selectedIds) {
      ref.read(cartProvider.notifier).removeItem(id);
      ref.read(cartSelectionProvider.notifier).removeId(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final selection = ref.watch(cartSelectionProvider);

    // Initialize selection when cart loads — deferred to avoid modifying
    // a provider while the widget tree is building.
    ref.listen<CartState>(cartProvider, (previous, next) {
      if (next.items.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref
                .read(cartSelectionProvider.notifier)
                .initFromCart(next.items.map((e) => e.id).toList());
          }
        });
      }
    });

    final selectedSubtotal = cartState.items
        .where((item) => selection.selectedIds.contains(item.id))
        .fold(0.0, (sum, item) => sum + item.subtotal);
    final selectedDiscount = selectedSubtotal * cartState.promoDiscount;
    final total = selectedSubtotal - selectedDiscount;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: _buildAppBar(cartState, selection),
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

                      // Cart Items
                      ...cartState.items.map((item) {
                        return CartItemTile(
                          item: item,
                          isSelected: selection.selectedIds.contains(item.id),
                          onSelectChanged: (selected) {
                            ref
                                .read(cartSelectionProvider.notifier)
                                .toggle(item.id, cartState.items.length);
                          },
                          onQuantityChanged: (quantity) {
                            ref
                                .read(cartProvider.notifier)
                                .updateQuantity(item.id, quantity);
                          },
                          onRemove: () {
                            ref.read(cartProvider.notifier).removeItem(item.id);
                            ref
                                .read(cartSelectionProvider.notifier)
                                .removeId(item.id);
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
                      if (selection.selectedIds.isNotEmpty)
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
                  selectedItems: selection.selectedIds,
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    CartState cartState,
    CartSelectionState selection,
  ) {
    return AppBar(
      backgroundColor: const Color(0xFFFAF7F2),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: AppTheme.deepCharcoal,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Giỏ hàng'.toUpperCase(),
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: AppTheme.deepCharcoal,
        ),
      ),
      actions: [
        if (cartState.items.isNotEmpty) ...[
          IconButton(
            icon: Icon(
              selection.selectAll ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: AppTheme.accentGold,
            ),
            padding: EdgeInsets.zero,
            onPressed: () {
              ref
                  .read(cartSelectionProvider.notifier)
                  .toggleAll(cartState.items.map((e) => e.id).toList());
            },
            tooltip: 'Chọn tất cả',
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 22,
              color: AppTheme.mutedSilver,
            ),
            onPressed: selection.selectedIds.isEmpty
                ? null
                : () {
                    if (selection.selectAll) {
                      showClearCartModal(
                        context,
                        onClearConfirmed: () {
                          ref.read(cartProvider.notifier).clearCart();
                          ref.read(cartSelectionProvider.notifier).clear();
                          Navigator.pop(context);
                        },
                      );
                    } else {
                      _removeSelectedItems(ref, selection.selectedIds);
                    }
                  },
          ),
          const SizedBox(width: 8),
        ],
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
              'Gio hang dang trong',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kham pha bo suu tap nuoc hoa cao cap',
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
                  'Kham pha ngay',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
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

