import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/payment.dart';

class OrderPaymentService {
  final ApiClient _client;

  OrderPaymentService({required ApiClient client}) : _client = client;

  Future<OrderPayment?> getPaymentByOrderId(String orderId) async {
    // Calling verify-sync instead of just order status ensures the backend 
    // checks with PayOS API for the latest truth.
    final response = await _client.get(ApiEndpoints.verifySyncPayment(orderId));
    final body = response.data;
    if (body == null) return null;
    if (body is! Map) return null;
    final map = body.map((k, v) => MapEntry(k.toString(), v));
    return OrderPayment.fromJson(map);
  }
}
