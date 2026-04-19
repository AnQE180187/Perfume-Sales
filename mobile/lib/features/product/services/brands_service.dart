import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/brand.dart';

class BrandsService {
  final ApiClient _apiClient;

  BrandsService(this._apiClient);

  Future<List<Brand>> getBrands() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.brands);
      if (response.data is List) {
        return (response.data as List)
            .map((e) => Brand.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      // For development, if API fails, return some mock data
      return [
        const Brand(id: 1, name: 'Chanel', description: 'Timeless luxury and elegance.'),
        const Brand(id: 2, name: 'Dior', description: 'Sophisticated and modern fragrances.'),
        const Brand(id: 3, name: 'Tom Ford', description: 'Bold, provocative, and glamorous.'),
        const Brand(id: 4, name: 'Byredo', description: 'Artistic and unique scent compositions.'),
        const Brand(id: 5, name: 'Le Labo', description: 'Hand-crafted and soul-filled scents.'),
      ];
    }
  }
}
