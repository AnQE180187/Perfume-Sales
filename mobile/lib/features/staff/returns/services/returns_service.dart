import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StaffReturnsService {
  final ApiClient _client;
  StaffReturnsService(this._client);

  Future<List<dynamic>> listAll({String? status, int skip = 0, int take = 50}) async {
    final response = await _client.get(
      '/returns/admin/all',
      queryParameters: {
        if (status != null && status != 'ALL') 'status': status,
        'skip': skip,
        'take': take,
      },
    );
    final data = response.data;
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  Future<Map<String, dynamic>> getDetails(String id) async {
    final response = await _client.get('/returns/admin/$id');
    return response.data;
  }

  Future<void> receiveReturn(String id, {
    required List<Map<String, dynamic>> items,
    required String receivedLocation,
    String? note,
  }) async {
    await _client.post(
      '/returns/admin/$id/receive',
      data: {
        'items': items,
        'receivedLocation': receivedLocation,
        'note': note,
      },
    );
  }

  Future<void> triggerRefund(String id, {
    required String method,
    required double amount,
    String? transactionId,
    String? note,
    String? receiptImage,
  }) async {
    await _client.post(
      '/returns/admin/$id/refund',
      data: {
        'method': method,
        'amount': amount,
        'transactionId': transactionId,
        'note': note,
        'receiptImage': receiptImage,
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
