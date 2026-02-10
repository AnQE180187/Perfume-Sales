import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return await service.getAllProducts();
});

final personalizedProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return await service.getPersonalizedProducts();
});

final recommendedProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(productServiceProvider);
  return await service.getRecommendedProducts();
});

final productDetailProvider = FutureProvider.family<Product, String>((ref, productId) async {
  final service = ref.watch(productServiceProvider);
  return await service.getProductById(productId);
});
