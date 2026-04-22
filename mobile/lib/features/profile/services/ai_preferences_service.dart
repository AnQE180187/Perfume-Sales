import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/ai_preferences.dart';

class AiPreferencesService {
  final ApiClient _apiClient;

  const AiPreferencesService(this._apiClient);

  Future<AiPreferences> getPreferences() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/ai-preferences');
    return AiPreferences.fromJson(response.data!);
  }

  Future<AiPreferences> updatePreferences(Map<String, dynamic> data) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/ai-preferences',
      data: data,
    );
    return AiPreferences.fromJson(response.data!);
  }

  Future<AiPreferences> resetPreferences() async {
    final response = await _apiClient.patch<Map<String, dynamic>>('/ai-preferences/reset');
    return AiPreferences.fromJson(response.data!);
  }

  Future<List<String>> listScentNotes() async {
    final response = await _apiClient.get<List<dynamic>>('/catalog/scent-notes');
    return response.data!.map((e) => e.toString()).toList();
  }
}

final aiPreferencesServiceProvider = Provider<AiPreferencesService>((ref) {
  return AiPreferencesService(ref.read(apiClientProvider));
});
