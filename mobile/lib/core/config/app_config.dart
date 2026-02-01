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
