import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class ScentApiService {
  final ApiClient _client;

  ScentApiService({required ApiClient client}) : _client = client;

  Future<List<dynamic>> getScentFamilies() async {
    final response = await _client.get(ApiEndpoints.scentFamilies);
    return response.data as List<dynamic>;
  }

  Future<List<String>> getScentNotes() async {
    final response = await _client.get(ApiEndpoints.scentNotes);
    if (response.data is List) {
      return (response.data as List).map((e) => e.toString()).toList();
    }
    return [];
  }
}
