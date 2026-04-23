import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import '../../../core/api/api_client.dart';

/// Service layer for PATCH /users/me and GET /users/me
class ProfileService {
  final ApiClient _apiClient;

  const ProfileService(this._apiClient);

  /// Fetch full user profile from the backend (richer than /auth/profile).
  Future<Map<String, dynamic>> getMe() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/users/me');
    return response.data!;
  }

  /// Update mutable profile fields.
  ///
  /// Only non-null values are sent to the backend, so callers can pass only
  /// the fields they want to change.
  Future<Map<String, dynamic>> updateMe({
    String? fullName,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? address,
    String? city,
    String? country,
    double? minBudget,
    double? maxBudget,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (phone != null) body['phone'] = phone;
    if (gender != null) body['gender'] = gender;
    if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth;
    if (address != null) body['address'] = address;
    if (city != null) body['city'] = city;
    if (country != null) body['country'] = country;
    if (minBudget != null) body['budgetMin'] = minBudget.toInt();
    if (maxBudget != null) body['budgetMax'] = maxBudget.toInt();

    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/users/me',
      data: body,
    );
    return response.data!;
  }

  /// Upload avatar file.
  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    final fileName = p.basename(filePath);
    final ext = p.extension(filePath).replaceAll('.', '');
    
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: MediaType('image', ext.isEmpty ? 'jpeg' : ext),
      ),
    });

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/users/me/avatar',
      data: formData,
    );
    return response.data!;
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.read(apiClientProvider));
});
