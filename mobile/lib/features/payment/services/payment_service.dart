import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_method.dart';

/// Payment Service - Calls backend API for payment processing
/// Backend handles VNPay, Momo, and COD integration
class PaymentService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get authorization header
  Future<Map<String, String>> _getHeaders() async {
    final session = _supabase.auth.currentSession;
    return {
      'Content-Type': 'application/json',
      if (session != null) 'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  /// Create payment for VNPay
  /// Returns payment URL to redirect user
  Future<Map<String, dynamic>> createVNPayPayment({
    required String orderId,
    required double amount,
    required String orderInfo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/payment/vnpay/create'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'orderId': orderId,
          'amount': amount,
          'orderInfo': orderInfo,
          'returnUrl': 'perfumegpt://payment/vnpay/return',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('VNPay payment creation failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('VNPay payment error: $e');
    }
  }

  /// Create payment for Momo
  /// Returns payment URL to redirect user
  Future<Map<String, dynamic>> createMomoPayment({
    required String orderId,
    required double amount,
    required String orderInfo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/payment/momo/create'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'orderId': orderId,
          'amount': amount,
          'orderInfo': orderInfo,
          'returnUrl': 'perfumegpt://payment/momo/return',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Momo payment creation failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Momo payment error: $e');
    }
  }

  /// Create COD order
  /// No payment URL needed, just confirm order
  Future<Map<String, dynamic>> createCODOrder({
    required String orderId,
    required double amount,
    required String shippingAddress,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/payment/cod/create'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'orderId': orderId,
          'amount': amount,
          'shippingAddress': shippingAddress,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('COD order creation failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('COD order error: $e');
    }
  }

  /// Verify payment callback from VNPay/Momo
  /// Backend validates the signature and updates order status
  Future<Map<String, dynamic>> verifyPaymentCallback({
    required PaymentMethodType method,
    required Map<String, dynamic> params,
  }) async {
    try {
      final endpoint = method == PaymentMethodType.vnpay
          ? '/api/payment/vnpay/verify'
          : '/api/payment/momo/verify';

      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(params),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Payment verification failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment verification error: $e');
    }
  }

  /// Get payment status
  Future<PaymentTransaction?> getPaymentStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/payment/status/$orderId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentTransaction.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get payment status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment status error: $e');
    }
  }

  /// Cancel payment
  Future<bool> cancelPayment(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/payment/cancel'),
        headers: await _getHeaders(),
        body: jsonEncode({'orderId': orderId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Payment cancellation error: $e');
    }
  }

  /// Get payment history
  Future<List<PaymentTransaction>> getPaymentHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/payment/history'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PaymentTransaction.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get payment history: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment history error: $e');
    }
  }
}
