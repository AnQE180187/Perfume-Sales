import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/luxury_button.dart';
import '../providers/cart_provider.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/cart_summary_section.dart';
import 'widgets/clear_cart_modal.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _selectAll = true;
  final Set<String> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    
    // Initialize selected items
    if (_selectedItems.isEmpty && cartState.items.isNotEmpty) {
      _selectedItems.addAll(cartState.items.map((item) => item.id));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: _buildAppBar(cartState),
      body: cartState.items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      // AI Suggestion Banner
                      _buildAISuggestionBanner(),
                      const SizedBox(height: 16),
                      
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
                              _selectAll = _selectedItems.length == cartState.items.length;
                            });
                          },
                          onQuantityChanged: (quantity) {
                            ref.read(cartProvider.notifier).updateQuantity(item.id, quantity);
                          },
                          onRemove: () {
                            ref.read(cartProvider.notifier).removeItem(item.id);
                            _selectedItems.remove(item.id);
                          },
                        );
                      }),
                      
                      const SizedBox(height: 16),
                      
                      // Promo Code Section
                      _buildPromoCodeSection(),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                
                // Bottom Summary
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
        'My Bag (${cartState.items.length})',
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
            'Select All',
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
            'Clear all',
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

  Widget _buildAISuggestionBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppTheme.accentGold,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PerfumeGPT Suggestion',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Add a Golden Amber sample to complement your selection.',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              // Add sample to cart
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              'Add +\$5',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Have a promo code?',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.accentGold,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.accentGold,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppTheme.mutedSilver.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Your bag is empty',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover our curated collection',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: AppTheme.mutedSilver,
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: LuxuryButton(
              text: 'EXPLORE COLLECTION',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
