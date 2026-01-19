import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../product/models/product.dart';

// Mock data for initial wishlist
final List<Product> _mockWishlist = [
  Product(
    id: 'prod_1',
    name: 'NOIR ÉLIXIR',
    brand: 'LUMINA',
    price: 280.0,
    imageUrl: 'https://images.unsplash.com/photo-1541643600914-78b084683601?q=80&w=1000&auto=format&fit=crop',
    rating: 4.8,
    reviews: 124,
    notes: ['Oud', 'Black Pepper', 'Amber'], description: '',
  ),
  Product(
    id: 'prod_2',
    name: 'ROSE POUDRÉE',
    brand: 'LUMINA',
    price: 240.0,
    imageUrl: 'https://images.unsplash.com/photo-1594035910387-fea4779426e9?q=80&w=1000&auto=format&fit=crop',
    rating: 4.9,
    reviews: 89,
    notes: ['Damask Rose', 'Vanilla', 'Iris'], description: '',
  ),
];

class WishlistNotifier extends StateNotifier<List<Product>> {
  WishlistNotifier() : super([]);

  // Initialize with optional mock data
  void init([List<Product>? initialData]) {
    state = initialData ?? [];
  }

  void toggle(Product product) {
    if (state.any((p) => p.id == product.id)) {
      // Remove
      state = state.where((p) => p.id != product.id).toList();
    } else {
      // Add
      state = [...state, product];
    }
  }

  bool contains(String productId) {
    return state.any((p) => p.id == productId);
  }

  void remove(String productId) {
    state = state.where((p) => p.id != productId).toList();
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<Product>>((ref) {
  final notifier = WishlistNotifier();
  // Initialize with some mock data for demo
  notifier.init(_mockWishlist);
  return notifier;
});
