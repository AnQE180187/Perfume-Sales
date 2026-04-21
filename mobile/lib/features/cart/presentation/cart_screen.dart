import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/cart_provider.dart';
import '../providers/cart_selection_provider.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/cart_summary_section.dart';
import 'widgets/clear_cart_modal.dart';
import 'widgets/price_summary.dart';
import 'widgets/promo_code_section.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/luxury_button.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final items = ref.read(cartProvider).items;
      final availableItems = items.where((e) => !e.isOutOfStock).map((e) => e.id).toList();
      if (availableItems.isNotEmpty) {
        ref
            .read(cartSelectionProvider.notifier)
            .syncWithAvailableItems(availableItems);
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
    final l10n = AppLocalizations.of(context)!;
    final cartState = ref.watch(cartProvider);
    final selection = ref.watch(cartSelectionProvider);

    ref.listen<CartState>(cartProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.items.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final available = next.items.where((e) => !e.isOutOfStock).map((e) => e.id).toList();
            ref
                .read(cartSelectionProvider.notifier)
                .syncWithAvailableItems(available);
          }
        });
      }
    });

    final selectedSubtotal = cartState.items
        .where((item) => selection.selectedIds.contains(item.id))
        .fold(0.0, (sum, item) => sum + item.subtotal);
    
    // Calculate discount based on selected items percentage or full fixed amount
    double selectedDiscount = 0.0;
    if (cartState.promoCode != null) {
      if (cartState.promoDiscountType == 'FIXED_AMOUNT') {
         // Apply fixed amount only if items are selected (prorated or full depending on business logic, here full)
         selectedDiscount = selectedSubtotal > 0 ? cartState.promoDiscountRaw : 0.0;
      } else {
         selectedDiscount = selectedSubtotal * cartState.promoDiscount;
      }
    }
    
    final total = (selectedSubtotal - selectedDiscount).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: _buildAppBar(cartState, selection, l10n),
      body: cartState.isLoading && cartState.items.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentGold),
            )
          : cartState.items.isEmpty
              ? _buildEmptyCart(l10n)
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        children: [
                          ...cartState.items.map((item) {
                            return CartItemTile(
                              item: item,
                              isSelected: selection.selectedIds.contains(item.id),
                              onSelectChanged: (selected) {
                                ref
                                    .read(cartSelectionProvider.notifier)
                                    .toggle(item.id, cartState.items.where((e) => !e.isOutOfStock).length);
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
                              onLimitReached: () {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.info_outline_rounded,
                                            color: Colors.white, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Rất tiếc, sản phẩm này chỉ còn ${item.stock} món trong kho',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppTheme.deepCharcoal,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    duration: const Duration(seconds: 2),
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              },
                            );
                          }),
                          const SizedBox(height: 12),
                          PromoCodeSection(
                            controller: _promoController,
                            hasPromoCode: cartState.promoCode != null,
                            promoCode: cartState.promoCode,
                            promoDiscount: cartState.promoDiscount,
                            isLoading: cartState.isLoading,
                          ),
                          const SizedBox(height: 12),
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
    AppLocalizations l10n,
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
        l10n.cart.toUpperCase(),
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
              selection.selectAll
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: AppTheme.accentGold,
            ),
            padding: EdgeInsets.zero,
            onPressed: () {
              final available = cartState.items.where((e) => !e.isOutOfStock).map((e) => e.id).toList();
              ref
                  .read(cartSelectionProvider.notifier)
                  .toggleAll(available);
            },
            tooltip: l10n.selectAll,
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

  Widget _buildEmptyCart(AppLocalizations l10n) {
    return EmptyStateWidget(
      icon: Icons.shopping_bag_outlined,
      title: l10n.yourCartEmpty,
      subtitle: l10n.discoverCollection,
      action: LuxuryButton(
        text: l10n.exploreCollection,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
