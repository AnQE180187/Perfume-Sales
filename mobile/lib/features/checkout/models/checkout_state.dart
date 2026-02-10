import '../../cart/models/cart_item.dart';
import '../../payment/models/payment_method.dart';

class CheckoutAddress {
  final String name;
  final String address;
  final bool isDefault;

  const CheckoutAddress({
    required this.name,
    required this.address,
    this.isDefault = false,
  });
}

class CheckoutState {
  final CheckoutAddress? selectedAddress;
  final PaymentMethod? selectedPaymentMethod;
  final List<CartItem> orderItems;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final bool isSubmitting;
  final String? errorMessage;

  const CheckoutState({
    this.selectedAddress,
    this.selectedPaymentMethod,
    this.orderItems = const [],
    this.subtotal = 0,
    this.shippingCost = 0,
    this.tax = 0,
    this.isSubmitting = false,
    this.errorMessage,
  });

  double get totalAmount => subtotal + shippingCost + tax;

  bool get canConfirm =>
      selectedAddress != null &&
      selectedPaymentMethod != null &&
      orderItems.isNotEmpty &&
      !isSubmitting;

  CheckoutState copyWith({
    CheckoutAddress? selectedAddress,
    PaymentMethod? selectedPaymentMethod,
    List<CartItem>? orderItems,
    double? subtotal,
    double? shippingCost,
    double? tax,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return CheckoutState(
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      orderItems: orderItems ?? this.orderItems,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      tax: tax ?? this.tax,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}
