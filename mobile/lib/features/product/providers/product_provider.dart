import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../data/product_repository.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../../profile/providers/ai_preferences_provider.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  // Watch preferences to trigger re-fetch when they change
  ref.watch(aiPreferencesProvider);

  if (AppConfig.useRealAPI) {
    final repository = ref.watch(productRepositoryProvider);
    // Tăng giới hạn lên 100 để lấy toàn bộ sản phẩm
    final rawList = await repository.getProducts(take: 100);
    return rawList;
  }

  final service = ref.watch(productServiceProvider);
  return await service.getAllProducts();
});

final personalizedProductsProvider = FutureProvider<List<Product>>((ref) async {
  // Watch preferences to trigger re-fetch when they change
  ref.watch(aiPreferencesProvider);

  if (AppConfig.useRealAPI) {
    final repository = ref.watch(productRepositoryProvider);
    // Request a fresh list which will be filtered/sorted by the backend AI logic
    return await repository.getProducts(take: 12);
  }

  final service = ref.watch(productServiceProvider);
  return await service.getPersonalizedProducts();
});

final recommendedProductsProvider = FutureProvider<List<Product>>((ref) async {
  if (AppConfig.useRealAPI) {
    final products = await ref.watch(productsProvider.future);
    // Show top matches first (already sorted by backend)
    if (products.length <= 8) return products;
    return products.take(12).toList();
  }

  final service = ref.watch(productServiceProvider);
  return await service.getRecommendedProducts();
});

final productDetailProvider = FutureProvider.family<Product, String>((
  ref,
  productId,
) async {
  if (AppConfig.useRealAPI) {
    final repository = ref.watch(productRepositoryProvider);
    return await repository.getProductById(productId);
  }

  final service = ref.watch(productServiceProvider);
  return await service.getProductById(productId);
});
