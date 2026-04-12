import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';

class PriceSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double total;
  final double shipping;

  const PriceSummary({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.total,
    this.shipping = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHI TIẾT ĐƠN HÀNG',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppTheme.mutedSilver,
            ),
          ),
          const SizedBox(height: 18),
          _PriceRow(label: 'Tạm tính', value: formatVND(subtotal)),
          if (discount > 0) ...[
            const SizedBox(height: 10),
            _PriceRow(
              label: 'Giảm giá hội viên',
              value: '-${formatVND(discount)}',
              valueColor: const Color(0xffb8860b),
            ),
          ],
          const SizedBox(height: 10),
          _PriceRow(
            label: 'Phí vận chuyển',
            value: shipping == 0 ? 'Chưa tính' : formatVND(shipping),
            valueColor: shipping == 0 ? AppTheme.mutedSilver.withValues(alpha: 0.5) : null,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: List.generate(
                30,
                (index) => Expanded(
                  child: Container(
                    height: 1,
                    color: index % 2 == 0 
                      ? AppTheme.softTaupe.withValues(alpha: 0.15) 
                      : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'TỔNG CỘNG'.toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.deepCharcoal,
                  letterSpacing: 2,
                ),
              ),
              Text(
                formatVND(total),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.deepCharcoal,
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
  final Color? valueColor;

  const _PriceRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: AppTheme.deepCharcoal.withValues(alpha: 0.65),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppTheme.deepCharcoal,
          ),
        ),
      ],
    );
  }
}
