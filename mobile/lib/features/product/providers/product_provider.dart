import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../data/product_repository.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../../profile/providers/ai_preferences_provider.dart';
import '../../../core/utils/perfume_utils.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final aiPrefs = ref.watch(aiPreferencesProvider).value;
  final preferredNotes = aiPrefs?.preferredNotes ?? [];
  final avoidedNotes = aiPrefs?.avoidedNotes ?? [];

  List<Product> products;
  if (AppConfig.useRealAPI) {
    final repository = ref.watch(productRepositoryProvider);
    products = await repository.getProducts(take: 100);
  } else {
    final service = ref.watch(productServiceProvider);
    products = await service.getAllProducts();
  }

  // Sort by match percentage if DNA is present, otherwise sort by "Best Selling" (reviews/rating)
  products.sort((a, b) {
    if (preferredNotes.isNotEmpty || avoidedNotes.isNotEmpty) {
      final matchA = calculateMatchPercentage(a, preferredNotes, avoidedNotes);
      final matchB = calculateMatchPercentage(b, preferredNotes, avoidedNotes);
      if (matchA != matchB) return matchB.compareTo(matchA);
    }
    
    // Default / Secondary sort: Best selling (most reviews, then highest rating)
    final reviewCompare = (b.reviews ?? 0).compareTo(a.reviews ?? 0);
    if (reviewCompare != 0) return reviewCompare;
    
    return (b.rating ?? 0).compareTo(a.rating ?? 0);
  });

  return products;
});

final personalizedProductsProvider = FutureProvider<List<Product>>((ref) async {
  // Use the main products list which is already sorted by AI match
  final products = await ref.watch(productsProvider.future);
  
  if (AppConfig.useRealAPI) {
    // If we want more variety, we could filter by high match scores only here
    return products.where((p) {
      final aiPrefs = ref.watch(aiPreferencesProvider).value;
      if (aiPrefs == null) return true;
      
      // If no DNA preferences, show as best sellers (all pass filter)
      if (aiPrefs.preferredNotes.isEmpty && aiPrefs.avoidedNotes.isEmpty) return true;
      
      final match = calculateMatchPercentage(p, aiPrefs.preferredNotes, aiPrefs.avoidedNotes);
      return match >= 70; // Only show excellent matches in personalized section
    }).take(12).toList();
  }

  final service = ref.watch(productServiceProvider);
  return await service.getPersonalizedProducts();
});

final recommendedProductsProvider = FutureProvider<List<Product>>((ref) async {
  if (AppConfig.useRealAPI) {
    final products = await ref.watch(productsProvider.future);
    // Show top matches first
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
