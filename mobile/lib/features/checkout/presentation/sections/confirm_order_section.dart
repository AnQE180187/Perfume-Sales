import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/luxury_button.dart';

class ConfirmOrderSection extends StatelessWidget {
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double totalAmount;
  final bool isSubmitting;
  final bool canConfirm;
  final VoidCallback? onConfirm;

  const ConfirmOrderSection({
    super.key,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.totalAmount,
    this.isSubmitting = false,
    this.canConfirm = false,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepCharcoal.withValues(alpha: 0.06),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _PriceRow(
            label: 'SUBTOTAL',
            value: '\$${subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _PriceRow(
            label: 'SHIPPING',
            value: shippingCost == 0
                ? 'COMPLIMENTARY'
                : '\$${shippingCost.toStringAsFixed(2)}',
            valueColor: shippingCost == 0 ? AppTheme.accentGold : null,
          ),
          const SizedBox(height: 8),
          _PriceRow(
            label: 'TAX',
            value: '\$${tax.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          Divider(
            color: AppTheme.softTaupe.withValues(alpha: 0.5),
            thickness: 0.5,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.deepCharcoal,
                ),
              ),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LuxuryButton(
            text: 'Confirm Order - \$${totalAmount.toStringAsFixed(2)}',
            onPressed: canConfirm && !isSubmitting ? onConfirm : null,
            isLoading: isSubmitting,
            height: 52,
          ),
          const SizedBox(height: 12),
          Text(
            'You won\'t be charged until payment is confirmed',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppTheme.mutedSilver.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 13,
                color: AppTheme.mutedSilver.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                'Secure checkout powered by Stripe',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.mutedSilver.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppTheme.mutedSilver,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.deepCharcoal,
          ),
        ),
      ],
    );
  }
}
