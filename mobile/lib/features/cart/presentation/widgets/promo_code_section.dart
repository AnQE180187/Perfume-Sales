import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/cart_provider.dart';

class PromoCodeSection extends ConsumerWidget {
  final TextEditingController controller;
  final bool hasPromoCode;
  final String? promoCode;
  final double promoDiscount;
  final bool isLoading;

  const PromoCodeSection({
    super.key,
    required this.controller,
    required this.hasPromoCode,
    this.promoCode,
    required this.promoDiscount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hasPromoCode && promoCode != null) {
      return _buildAppliedPromoCode(context, ref);
    }
    return _buildPromoCodeInput(context, ref);
  }

  Widget _buildAppliedPromoCode(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.champagneGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.champagneGold.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, color: AppTheme.accentGold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promoCode!.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.accentGold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${(promoDiscount * 100).toInt()}% discount applied',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => ref.read(cartProvider.notifier).removePromoCode(),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCodeInput(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'PROMO CODE',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 0.5,
                ),
              ),
            ),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              ref.read(cartProvider.notifier).applyPromoCode(controller.text);
            }
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            side: BorderSide(color: Theme.of(context).primaryColor, width: 0.5),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'APPLY',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                ),
        ),
      ],
    );
  }
}
