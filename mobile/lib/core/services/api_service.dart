import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Use the Web API URL from .env
  // For local development on Android emulator, use 10.0.2.2 instead of localhost
  static String get baseUrl {
    final url = dotenv.env['WEB_API_URL'] ?? 'http://localhost:3000';
    return url;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return response;
  }

  static Future<http.Response> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }
}
