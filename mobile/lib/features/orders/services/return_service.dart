import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class ReturnService {
  final ApiClient _client;

  ReturnService({required ApiClient client}) : _client = client;

  Future<List<String>> uploadImages(List<File> images) async {
    if (images.isEmpty) return [];

    final formData = FormData();
    for (var image in images) {
      formData.files.add(MapEntry(
        'images',
        await MultipartFile.fromFile(image.path),
      ));
    }

    final response = await _client.post(
      ApiEndpoints.uploadReturnImages,
      data: formData,
    );
    
    final body = response.data;
    if (body is Map && body['urls'] is List) {
      return (body['urls'] as List).map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<String?> uploadVideo(File video) async {
    final formData = FormData.fromMap({
      'video': await MultipartFile.fromFile(video.path),
    });

    final response = await _client.post(
      ApiEndpoints.uploadReturnVideo,
      data: formData,
    );

    final body = response.data;
    if (body is Map && body['url'] != null) {
      return body['url'].toString();
    }
    return null;
  }

  Future<void> createReturn(Map<String, dynamic> payload, {String? idempotencyKey}) async {
    await _client.post(
      ApiEndpoints.returns,
      data: payload,
      options: Options(
        headers: {
          if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
        },
      ),
    );
  }

  Future<List<dynamic>> getMyReturns() async {
    final response = await _client.get(ApiEndpoints.returns);
    return response.data is List ? response.data as List : [];
  }

  Future<Map<String, dynamic>> getReturnById(String id) async {
    final response = await _client.get(ApiEndpoints.returnById(id));
    return response.data as Map<String, dynamic>;
  }

  Future<void> cancelReturn(String id, String? reason) async {
    await _client.patch(
      ApiEndpoints.cancelReturn(id),
      data: {'reason': reason},
    );
  }

  Future<void> confirmHandover(String id) async {
    await _client.patch(ApiEndpoints.handoverReturn(id));
  }
}
