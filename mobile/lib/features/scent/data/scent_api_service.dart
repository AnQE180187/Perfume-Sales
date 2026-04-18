import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class ScentApiService {
  final ApiClient _client;

  ScentApiService({required ApiClient client}) : _client = client;

  Future<List<dynamic>> getScentFamilies() async {
    final response = await _client.get(ApiEndpoints.scentFamilies);
    return response.data as List<dynamic>;
  }
}
