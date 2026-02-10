import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checkout_state.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/providers/cart_provider.dart';
import '../../payment/models/payment_method.dart';

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier() : super(const CheckoutState());

  void initialize(List<CartItem> cartItems) {
    final subtotal = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    state = state.copyWith(
      orderItems: cartItems,
      subtotal: subtotal,
      shippingCost: 0,
      tax: subtotal * 0.1,
      selectedAddress: const CheckoutAddress(
        name: 'EVELYN VANCE',
        address: '221B BAKER STREET, LONDON',
        isDefault: true,
      ),
      selectedPaymentMethod: PaymentMethod(
        type: PaymentMethodType.cod,
        isDefault: true,
      ),
    );
  }

  void selectAddress(CheckoutAddress address) {
    state = state.copyWith(selectedAddress: address);
  }

  void selectPaymentMethod(PaymentMethod method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  Future<bool> confirmOrder() async {
    if (!state.canConfirm) return false;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  final notifier = CheckoutNotifier();
  final cartState = ref.watch(cartProvider);
  notifier.initialize(cartState.items);
  return notifier;
});
