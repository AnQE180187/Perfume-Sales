import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/review.dart';

class ReviewApiService {
  final ApiClient _client;

  ReviewApiService({required ApiClient client}) : _client = client;

  /// GET /reviews/product/:productId?skip=&take=
  Future<ReviewListResponse> getReviews(
    String productId, {
    int skip = 0,
    int take = 20,
  }) async {
    final response = await _client.get(
      ApiEndpoints.reviewsByProduct(productId),
      queryParameters: {'skip': skip, 'take': take},
    );
    return ReviewListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /reviews/product/:productId/stats
  Future<ReviewStats> getStats(String productId) async {
    final response = await _client.get(
      ApiEndpoints.reviewStatsByProduct(productId),
    );
    return ReviewStats.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /reviews/product/:productId/summary
  Future<ReviewSummaryModel?> getSummary(String productId) async {
    final response = await _client.get(
      ApiEndpoints.reviewSummaryByProduct(productId),
    );
    if (response.data == null) return null;
    return ReviewSummaryModel.fromJson(response.data as Map<String, dynamic>);
  }
}
