/// Centralized API endpoint constants.
///
/// All backend routes are defined here so they can be referenced
/// from any service without duplicating strings.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';

  // ── Products ──────────────────────────────────────────────────────
  static const String products = '/products';
  static String productById(String id) => '/products/$id';

  // ── Cart ──────────────────────────────────────────────────────────
  static const String cart = '/cart';
  static String cartItem(String itemId) => '/cart/$itemId';

  // ── Orders ────────────────────────────────────────────────────────
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';

  // ── Payments ──────────────────────────────────────────────────────
  static const String payments = '/payments';
  static const String paymentVnpayCreate = '/payments/vnpay/create';
  static const String paymentMomoCreate = '/payments/momo/create';
  static const String paymentCodCreate = '/payments/cod/create';
  static const String paymentVnpayVerify = '/payments/vnpay/verify';
  static const String paymentMomoVerify = '/payments/momo/verify';

  // ── Catalog ───────────────────────────────────────────────────────
  static const String catalog = '/catalog';
  static const String categories = '/catalog/categories';
  static const String brands = '/catalog/brands';
}
