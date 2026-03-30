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
  static const String cartItems = '/cart/items';
  static String cartItem(int itemId) => '/cart/items/$itemId';

  // ── Orders ────────────────────────────────────────────────────────
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String shipmentsByOrderId(String orderId) =>
      '/shipping/orders/$orderId';

  // ── Addresses ─────────────────────────────────────────────────────
  static const String addresses = '/addresses';
  static String addressById(String id) => '/addresses/$id';
  static String addressDefault(String id) => '/addresses/$id/default';

  // ── GHN ───────────────────────────────────────────────────────────
  static const String ghnProvinces = '/ghn/provinces';
  static const String ghnDistricts = '/ghn/districts';
  static const String ghnWards = '/ghn/wards';
  static const String ghnServices = '/ghn/services';
  static const String ghnCalculateFee = '/ghn/calculate-fee';

  // ── Payments ──────────────────────────────────────────────────────
  static const String payments = '/payments';
  static const String createPayosPayment = '/payments/create-payment';
  static String paymentByOrderId(String orderId) => '/payments/order/$orderId';
  static const String paymentMethods = '/payment-methods';
  static String paymentMethodDefaultById(String id) =>
      '/payment-methods/$id/default';
  // Legacy (unused)
  static const String paymentVnpayCreate = '/payments/vnpay/create';
  static const String paymentMomoCreate = '/payments/momo/create';
  static const String paymentCodCreate = '/payments/cod/create';
  static const String paymentVnpayVerify = '/payments/vnpay/verify';
  static const String paymentMomoVerify = '/payments/momo/verify';

  // ── Catalog ───────────────────────────────────────────────────────
  static const String catalog = '/catalog';
  static const String categories = '/catalog/categories';
  static const String brands = '/catalog/brands';

  // ── Reviews ───────────────────────────────────────────────────────
  static String reviewsByProduct(String productId) =>
      '/reviews/product/$productId';
  static String reviewStatsByProduct(String productId) =>
      '/reviews/product/$productId/stats';
  static String reviewSummaryByProduct(String productId) =>
      '/reviews/product/$productId/summary';
}
