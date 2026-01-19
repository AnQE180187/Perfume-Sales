import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'SHOPPING CART',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            letterSpacing: 6,
            fontSize: 12,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: cartState.items.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: cartState.items.length,
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return _CartItemCard(item: item);
                    },
                  ),
                ),
                _buildBottomSection(context, cartState),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'YOUR CART IS EMPTY',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Discover our curated collection',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('EXPLORE COLLECTION'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Promo Code Section
            _buildPromoCodeSection(context, cartState),
            const SizedBox(height: 24),

            // Price Summary
            _buildPriceSummary(context, cartState),
            const SizedBox(height: 24),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.push('/checkout'),
                child: const Text('PROCEED TO CHECKOUT'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeSection(BuildContext context, CartState cartState) {
    if (cartState.promoCode != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.champagneGold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.champagneGold.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.local_offer_outlined, color: AppTheme.accentGold, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartState.promoCode!.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.accentGold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${(cartState.promoDiscount * 100).toInt()}% discount applied',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => ref.read(cartProvider.notifier).removePromoCode(),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _promoController,
            decoration: InputDecoration(
              hintText: 'PROMO CODE',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 0.5,
                ),
              ),
            ),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () {
            if (_promoController.text.isNotEmpty) {
              ref.read(cartProvider.notifier).applyPromoCode(_promoController.text);
            }
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            side: BorderSide(color: Theme.of(context).primaryColor, width: 0.5),
          ),
          child: cartState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'APPLY',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(BuildContext context, CartState cartState) {
    return Column(
      children: [
        _buildPriceRow(context, 'Subtotal', '\$${cartState.subtotal.toStringAsFixed(2)}'),
        if (cartState.promoDiscount > 0) ...[
          const SizedBox(height: 12),
          _buildPriceRow(
            context,
            'Discount',
            '-\$${cartState.discount.toStringAsFixed(2)}',
            isDiscount: true,
          ),
        ],
        const SizedBox(height: 12),
        Divider(color: Theme.of(context).colorScheme.outline, thickness: 0.5),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 14),
            ),
            Text(
              '\$${cartState.total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 24,
                color: AppTheme.champagneGold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 14,
            color: isDiscount ? AppTheme.accentGold : null,
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.productImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.outline,
                    size: 32,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item.size != null)
                  Text(
                    item.size!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                  ),
                const SizedBox(height: 8),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.accentGold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Quantity Controls
          Column(
            children: [
              _QuantityControl(item: item),
              const SizedBox(height: 12),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                ),
                onPressed: () {
                  ref.read(cartProvider.notifier).removeItem(item.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends ConsumerWidget {
  final CartItem item;

  const _QuantityControl({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            context,
            Icons.remove,
            () => ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity - 1),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${item.quantity}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
            ),
          ),
          _buildButton(
            context,
            Icons.add,
            () => ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 16, color: Theme.of(context).primaryColor),
      ),
    );
  }
}
