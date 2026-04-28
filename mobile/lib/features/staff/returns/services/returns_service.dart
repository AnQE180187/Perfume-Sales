import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StaffReturnsService {
  final ApiClient _client;
  StaffReturnsService(this._client);

  Future<List<String>> uploadImages(List<File> images) async {
    if (images.isEmpty) return [];

    final formData = FormData();
    for (var image in images) {
      formData.files.add(
        MapEntry('images', await MultipartFile.fromFile(image.path)),
      );
    }

    final response = await _client.post(
      '/returns/upload-images',
      data: formData,
    );

    final body = response.data;
    if (body is Map && body['urls'] is List) {
      return (body['urls'] as List).map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<List<dynamic>> listAll({
    String? status,
    int skip = 0,
    int take = 50,
    String? startDate,
    String? endDate,
  }) async {
    final response = await _client.get(
      '/returns/admin/all',
      queryParameters: {
        if (status != null && status != 'ALL') 'status': status,
        'skip': skip,
        'take': take,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      },
    );
    final data = response.data;
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  Future<Map<String, dynamic>> getDetails(String id) async {
    final response = await _client.get(
      '/returns/admin/$id',
      queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
    );
    return response.data;
  }

  Future<void> receiveReturn(String id, {
    required List<Map<String, dynamic>> items,
    required String receivedLocation,
    String? note,
    List<String>? evidenceImages,
  }) async {
    await _client.post(
      '/returns/admin/$id/receive',
      data: {
        'items': items,
        'receivedLocation': receivedLocation,
        'note': note,
        'evidenceImages': evidenceImages,
      },
    );
  }

  Future<Map<String, dynamic>> shipBackAutomated(String id) async {
    final response = await _client.post('/returns/admin/$id/ship-back-automated');
    return response.data;
  }

  Future<void> shipBackManual(String id, {
    String? courier,
    required String trackingNumber,
  }) async {
    await _client.post(
      '/returns/admin/$id/ship-back-manual',
      data: {
        'courier': courier,
        'trackingNumber': trackingNumber,
      },
    );
  }

  Future<void> triggerRefund(String id, {
    required String method,
    String? transactionId,
    String? note,
    String? receiptImage,
  }) async {
    await _client.post(
      '/returns/admin/$id/refund',
      data: {
        'method': method,
        if (transactionId != null) 'transactionId': transactionId,
        if (note != null) 'note': note,
        if (receiptImage != null) 'receiptImage': receiptImage,
      },
      options: Options(
        headers: {
          'x-idempotency-key': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      ),
    );
  }

  Future<double> getSuggestedRefund(String id) async {
    final response = await _client.get('/returns/admin/$id/suggested-refund');
    return (response.data['suggestedAmount'] ?? 0).toDouble();
  }
}

final staffReturnsServiceProvider = Provider<StaffReturnsService>((ref) {
  final client = ref.watch(apiClientProvider);
  return StaffReturnsService(client);
});
