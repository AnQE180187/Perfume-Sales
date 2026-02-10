import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/cart_provider.dart';

class PriceSummary extends StatelessWidget {
  final CartState cartState;

  const PriceSummary({
    super.key,
    required this.cartState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPriceRow(context, 'Subtotal', '\$${cartState.subtotal.toStringAsFixed(2)}'),
        if (cartState.promoDiscount > 0) ...[
          const SizedBox(height: 12),
          _buildPriceRow(
            context,
            'Discount',
            '-\$${cartState.discount.toStringAsFixed(2)}',
            isDiscount: true,
          ),
        ],
        const SizedBox(height: 12),
        Divider(color: Theme.of(context).colorScheme.outline, thickness: 0.5),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 14),
            ),
            Text(
              '\$${cartState.total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 24,
                color: AppTheme.champagneGold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 14,
            color: isDiscount ? AppTheme.accentGold : null,
          ),
        ),
      ],
    );
  }
}
