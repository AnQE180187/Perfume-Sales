/// App Configuration
///
/// Chứa các cấu hình môi trường và feature flags
class AppConfig {
  /// Development Mode
  /// Set = true để sử dụng mock data và bypass authentication
  static const bool isDevelopmentMode = true;

  /// Mock Authentication
  /// Set = true để sử dụng mock auth provider thay vì Supabase Auth
  /// Hữu ích khi phát triển UI mà chưa setup Supabase
  static const bool useMockAuth = true;

  /// Mock Orders
  /// Set = true để sử dụng mock order data thay vì Supabase
  /// UI sẽ hoạt động bình thường với fake orders
  static const bool useMockOrders = true;

  /// API Configuration
  static const bool useRealAPI = false;

  /// Logging
  static const bool enableDebugLogs = true;
}

/// App configuration for development
class AppConfig {
  /// Set this to true to bypass authentication and onboarding
  /// Useful for UI/UX development without needing to login
  static const bool bypassAuth = true;

  /// Set this to true to skip onboarding screen
  static const bool skipOnboarding = true;

  /// Mock user for development (when bypassAuth is true)
  static const mockUser = {
    'id': 'dev-user-123',
    'email': 'dev@example.com',
    'fullName': 'Developer User',
    'role': 'CUSTOMER',
  };
}
