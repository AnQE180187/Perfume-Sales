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
