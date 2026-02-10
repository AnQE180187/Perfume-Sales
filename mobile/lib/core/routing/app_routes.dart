/// Centralized Route Definitions
/// 
/// Single source of truth for all app routes.
/// Eliminates hardcoded route strings and ensures consistency.
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // ============================================
  // AUTH ROUTES
  // ============================================
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';

  // ============================================
  // MAIN NAVIGATION (Bottom Tabs)
  // ============================================
  static const String home = '/home';
  static const String explore = '/explore';
  static const String aiConsultation = '/consultation';
  static const String alerts = '/alerts';
  static const String profile = '/profile';

  // ============================================
  // PRODUCT ROUTES
  // ============================================
  static const String productDetail = '/product';
  static const String productStory = '/product/story';
  static const String reviews = '/reviews';
  static const String collection = '/collection';

  // ============================================
  // SHOPPING ROUTES
  // ============================================
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String wishlist = '/wishlist';

  // ============================================
  // ORDER ROUTES
  // ============================================
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';

  // ============================================
  // SEARCH & DISCOVERY
  // ============================================
  static const String search = '/search';

  // ============================================
  // PAYMENT ROUTES
  // ============================================
  static const String paymentMethod = '/payment-method';
  static const String paymentResult = '/payment-result';

  // ============================================
  // PROFILE & SETTINGS
  // ============================================
  static const String rewards = '/rewards';
  static const String quiz = '/quiz';

  // ============================================
  // HELPER METHODS
  // ============================================
  
  /// Build product detail route with ID
  static String productDetailWithId(String productId) {
    return '/product?id=$productId';
  }

  /// Build order detail route with ID
  static String orderDetailWithId(String orderId) {
    return '/orders/$orderId';
  }

  /// Build product story route with ID
  static String productStoryWithId(String productId) {
    return '/product/story?id=$productId';
  }

  /// Build reviews route with product ID
  static String reviewsWithProductId(String productId) {
    return '/reviews?productId=$productId';
  }
}
