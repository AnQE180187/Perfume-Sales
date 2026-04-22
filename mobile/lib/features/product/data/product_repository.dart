import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/product.dart';
import '../models/brand.dart';
import 'product_api_service.dart';

/// Repository that maps raw API data to domain [Product] objects.
///
/// The UI should depend on this repository (via Riverpod providers)
/// instead of calling the API service directly.
class ProductRepository {
  final ProductApiService _apiService;

  ProductRepository({required ProductApiService apiService})
    : _apiService = apiService;

  /// Fetch all products, optionally filtered.
  Future<List<Product>> getProducts({
    int? skip,
    int? take,
    int? categoryId,
    int? scentFamilyId,
    int? brandId,
    String? search,
    String? notes,
    String? occasion,
    int? minPrice,
    int? maxPrice,
  }) async {
    final rawList = await _apiService.getProducts(
      skip: skip,
      take: take,
      categoryId: categoryId,
      scentFamilyId: scentFamilyId,
      brandId: brandId,
      search: search,
      notes: notes,
      occasion: occasion,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
    return rawList.map((json) {
      try {
        return Product.fromJson(json as Map<String, dynamic>);
      } catch (e) {
        // Log error and skip this product instead of failing the whole list
        print('Error parsing product: $e');
        return null;
      }
    }).whereType<Product>().toList();
  }

  /// Fetch a single product by its ID.
  Future<Product> getProductById(String id) async {
    final json = await _apiService.getProductById(id);
    return Product.fromJson(json);
  }

  /// Fetch all brands.
  Future<List<Brand>> getBrands() async {
    final rawList = await _apiService.getBrands();
    return rawList.map((j) => Brand.fromJson(j as Map<String, dynamic>)).toList();
  }
}

// ── Riverpod Providers ────────────────────────────────────────────────

final productApiServiceProvider = Provider<ProductApiService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductApiService(client: client);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(apiService: ref.watch(productApiServiceProvider));
});

final brandsProvider = FutureProvider<List<Brand>>((ref) {
  return ref.watch(productRepositoryProvider).getBrands();
});
