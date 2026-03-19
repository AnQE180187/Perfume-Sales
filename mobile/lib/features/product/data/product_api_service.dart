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
    int? page,
    int? limit,
    String? category,
    String? brand,
    String? sortBy,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (category != null) 'category': category,
      if (brand != null) 'brand': brand,
      if (sortBy != null) 'sortBy': sortBy,
      if (search != null) 'search': search,
    };

    final response = await _client.get(
      ApiEndpoints.products,
      queryParameters: queryParams,
    );

    // Backend may return { data: [...], meta: {...} } or plain [...]
    final body = response.data;
    if (body is List) return body;
    if (body is Map && body.containsKey('data')) return body['data'] as List;
    return [];
  }

  /// GET /products/:id
  Future<Map<String, dynamic>> getProductById(String id) async {
    final response = await _client.get(ApiEndpoints.productById(id));
    return response.data as Map<String, dynamic>;
  }
}
