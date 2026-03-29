import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../product/models/product.dart';

// Mock data for initial wishlist
final List<Product> _mockWishlist = [
  Product(
    id: 'prod_1',
    name: 'NOIR ÉLIXIR',
    brand: 'LUMINA',
    price: 280.0,
    imageUrl:
        'https://images.unsplash.com/photo-1541643600914-78b084683601?q=80&w=1000&auto=format&fit=crop',
    rating: 4.8,
    reviews: 124,
    notes: ['Oud', 'Black Pepper', 'Amber'],
    description: '',
  ),
  Product(
    id: 'prod_2',
    name: 'ROSE POUDRÉE',
    brand: 'LUMINA',
    price: 240.0,
    imageUrl:
        'https://images.unsplash.com/photo-1594035910387-fea4779426e9?q=80&w=1000&auto=format&fit=crop',
    rating: 4.9,
    reviews: 89,
    notes: ['Damask Rose', 'Vanilla', 'Iris'],
    description: '',
  ),
];

class WishlistNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    // Simulates an API call; replace with real service call in production
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_mockWishlist);
  }

  Future<void> toggle(Product product) async {
    final current = state.value ?? [];
    if (current.any((p) => p.id == product.id)) {
      state = AsyncData(current.where((p) => p.id != product.id).toList());
    } else {
      state = AsyncData([...current, product]);
    }
  }

  bool contains(String productId) {
    return state.value?.any((p) => p.id == productId) ?? false;
  }

  void remove(String productId) {
    final current = state.value ?? [];
    state = AsyncData(current.where((p) => p.id != productId).toList());
  }
}

final wishlistProvider = AsyncNotifierProvider<WishlistNotifier, List<Product>>(
  WishlistNotifier.new,
);
