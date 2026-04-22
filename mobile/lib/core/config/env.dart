import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for API base URLs.
///
/// Reads from .env file in production, falls back to hardcoded defaults.
/// Switch [environment] to toggle between dev and production.
enum Environment { development, production }

class EnvConfig {
  static Environment environment = Environment.development;

  /// Base URL for the NestJS backend API.
  static String get apiBaseUrl {
    // Safely read from dotenv. Returns null if not loaded or key missing.
    final envUrl = dotenv.maybeGet('API_BASE_URL');
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;

    // Fallback based on environment
    switch (environment) {
      case Environment.development:
        return 'http://10.0.2.2:3000'; // Local backend for testing
      case Environment.production:
        return 'https://api.perfumegpt.site'; // Deployed server
    }
  }

  /// API version prefix applied to all endpoints.
  static const String apiPrefix = '/api/v1';

  /// Full base URL including the API prefix.
  static String get fullBaseUrl => '$apiBaseUrl$apiPrefix';

  /// Google Web Client ID for social login.
  static String get googleWebClientId {
    final clientId = dotenv.maybeGet('GOOGLE_WEB_CLIENT_ID');
    if (clientId != null && clientId.isNotEmpty) return clientId;
    return '703366728616-2vgef2fv3561b3aohkvbo0hmt44969ps.apps.googleusercontent.com';
  }

  /// Connection timeout in milliseconds.
  static const int connectTimeout = 60000;

  /// Receive timeout in milliseconds.
  static const int receiveTimeout = 60000;
}
