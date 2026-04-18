import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

/// Low-level API service for product endpoints.
///
/// Handles raw HTTP communication with the NestJS backend.
class ProductApiService {
  final ApiClient _client;

  ProductApiService({required ApiClient client}) : _client = client;

  /// GET /products
  Future<List<dynamic>> getProducts({
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
    final queryParams = <String, dynamic>{
      if (skip != null) 'skip': skip,
      if (take != null) 'take': take,
      if (categoryId != null) 'categoryId': categoryId,
      if (scentFamilyId != null) 'scentFamilyId': scentFamilyId,
      if (brandId != null) 'brandId': brandId,
      if (search != null) 'search': search,
      if (notes != null) 'notes': notes,
      if (occasion != null) 'occasion': occasion,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
    };

    final response = await _client.get(
      ApiEndpoints.products,
      queryParameters: queryParams,
    );

    // Backend supports { items: [...], total, skip, take }.
    // Keep compatibility with legacy envelopes as fallback.
    final body = response.data;
    if (body is List) return body;
    if (body is Map && body.containsKey('items')) return body['items'] as List;
    if (body is Map && body.containsKey('data')) return body['data'] as List;
    return [];
  }

  /// GET /products/:id
  Future<Map<String, dynamic>> getProductById(String id) async {
    final response = await _client.get(ApiEndpoints.productById(id));
    return response.data as Map<String, dynamic>;
  }

  /// GET /catalog/brands
  Future<List<dynamic>> getBrands() async {
    final response = await _client.get(ApiEndpoints.brands);
    return response.data as List<dynamic>;
  }
}
