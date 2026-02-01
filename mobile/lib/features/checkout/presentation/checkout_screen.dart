import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routing/app_routes.dart';
import '../providers/checkout_provider.dart';
import 'sections/payment_header_section.dart';
import 'sections/shipping_address_section.dart';
import 'sections/payment_method_section.dart';
import 'sections/order_summary_section.dart';
import 'sections/confirm_order_section.dart';

/// Refactored Checkout Screen
/// 
/// Architecture:
/// - Screen orchestrates layout only
/// - Business logic delegated to CheckoutProvider
/// - UI sections extracted into modular widgets
/// - State-driven validation & submission
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutProvider);

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepCharcoal),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const PaymentHeaderSection(),
          const SizedBox(height: 24),
          ShippingAddressSection(
            address: checkoutState.selectedAddress,
            onChangeAddress: () {
              // Navigate to address selection
            },
          ),
          const SizedBox(height: 24),
          PaymentMethodSection(
            paymentMethod: checkoutState.selectedPaymentMethod,
            onEdit: () {
              // Navigate to payment method selection
            },
          ),
          const SizedBox(height: 24),
          OrderSummarySection(
            items: checkoutState.orderItems,
            maxVisibleItems: 2,
          ),
          const SizedBox(height: 24),
          ConfirmOrderSection(
            subtotal: checkoutState.subtotal,
            shippingCost: checkoutState.shippingCost,
            tax: checkoutState.tax,
            totalAmount: checkoutState.totalAmount,
            isSubmitting: checkoutState.isSubmitting,
            canConfirm: checkoutState.canConfirm,
            onConfirm: () => _handleConfirmOrder(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirmOrder(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(checkoutProvider.notifier);
    final success = await notifier.confirmOrder();

    if (success && context.mounted) {
      context.go(AppRoutes.orderSuccess);
    } else if (context.mounted) {
      final errorMessage = ref.read(checkoutProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Failed to confirm order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
