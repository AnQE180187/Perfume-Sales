import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';

class CartState {
  final List<CartItem> items;
  final String? promoCode;
  final double promoDiscount;
  final bool isLoading;
  final String? error;

  CartState({
    this.items = const [],
    this.promoCode,
    this.promoDiscount = 0.0,
    this.isLoading = false,
    this.error,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get discount => subtotal * promoDiscount;
  double get total => subtotal - discount;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartItem>? items,
    String? promoCode,
    double? promoDiscount,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      promoCode: promoCode ?? this.promoCode,
      promoDiscount: promoDiscount ?? this.promoDiscount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState(items: _mockItems));

  // Mock data for testing
  static final List<CartItem> _mockItems = [
    CartItem(
      id: '1',
      productId: 'p1',
      productName: 'Elysium Essence',
      productImage: 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=400',
      price: 120.00,
      quantity: 1,
      size: '100ml',
      variant: 'Oud & Bergamot',
    ),
    CartItem(
      id: '2',
      productId: 'p2',
      productName: 'Night Shade',
      productImage: 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=400',
      price: 85.00,
      quantity: 1,
      size: '50ml',
      variant: 'AI Formulation #4',
    ),
    CartItem(
      id: '3',
      productId: 'p3',
      productName: 'Solar Flare',
      productImage: 'https://images.unsplash.com/photo-1588405748880-12d1d2a59db9?w=400',
      price: 0.00, // Free sample
      quantity: 1,
      size: '2ml',
      variant: 'Citrus & Amber',
    ),
  ];

  // Add item to cart
  void addItem(CartItem item) {
    final existingIndex = state.items.indexWhere(
      (i) => i.productId == item.productId && i.size == item.size,
    );

    if (existingIndex >= 0) {
      // Update quantity if item exists
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + item.quantity,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // Add new item
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  // Update item quantity
  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  // Remove item from cart
  void removeItem(String itemId) {
    final updatedItems = state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: updatedItems);
  }

  // Clear cart
  void clearCart() {
    state = CartState();
  }

  // Apply promo code
  Future<void> applyPromoCode(String code) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Call API to validate promo code
      await Future.delayed(const Duration(seconds: 1));

      // Mock validation
      if (code.toUpperCase() == 'LUMINA10') {
        state = state.copyWith(
          promoCode: code,
          promoDiscount: 0.10, // 10% discount
          isLoading: false,
        );
      } else if (code.toUpperCase() == 'WELCOME20') {
        state = state.copyWith(
          promoCode: code,
          promoDiscount: 0.20, // 20% discount
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid promo code',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Remove promo code
  void removePromoCode() {
    state = state.copyWith(
      promoCode: null,
      promoDiscount: 0.0,
    );
  }
}

// Provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
