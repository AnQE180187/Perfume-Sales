import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';

class CheckoutPriceSection extends StatelessWidget {
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double discount;
  final double totalAmount;

  const CheckoutPriceSection({
    super.key,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.discount,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5D5C0).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepCharcoal.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _PriceRow(label: 'Giá trị sản phẩm', value: formatVND(subtotal)),
          const SizedBox(height: 14),
          if (discount > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1E5AC).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: AppTheme.accentGold, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ƯU ĐÃI ĐẶC QUYỀN',
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ),
                  Text(
                    '-${formatVND(discount)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          _PriceRow(
            label: 'Phí vận chuyển',
            value: shippingCost == 0 ? 'Miễn phí' : formatVND(shippingCost),
            highlight: shippingCost == 0,
          ),
          const SizedBox(height: 14),
          _PriceRow(label: 'Thuế (VAT)', value: formatVND(tax)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Color(0xFFE5D5C0), thickness: 0.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TỔNG THANH TOÁN',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppTheme.mutedSilver,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đã bao gồm các loại thuế',
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.mutedSilver.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                formatVND(totalAmount)
                    .replaceAll(RegExp(r'[^0-9.,]'), '')
                    .trim(),
                maxLines: 1,
                style: GoogleFonts.montserrat(
                  fontSize: 22, // Slightly smaller to avoid overflow
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: AppTheme.deepCharcoal,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 1),
                child: Text(
                  'đ',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _PriceRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.mutedSilver,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: highlight ? AppTheme.accentGold : AppTheme.deepCharcoal,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
