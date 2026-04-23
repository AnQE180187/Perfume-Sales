import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../models/cart_item.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final bool isSelected;
  final ValueChanged<bool> onSelectChanged;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final VoidCallback? onLimitReached;

  const CartItemTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onSelectChanged,
    required this.onQuantityChanged,
    required this.onRemove,
    this.onLimitReached,
  });

  bool get isSample => item.price == 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key('cart-item-${item.id}'),
        direction: DismissDirection.endToStart,
        background: _SwipeBg(),
        onDismissed: (_) {
          HapticFeedback.mediumImpact();
          onRemove();
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.creamWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.deepCharcoal.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Checkbox(
                isSelected: isSelected,
                isEnabled: !item.isOutOfStock,
                onTap: item.isOutOfStock ? null : () => onSelectChanged(!isSelected),
              ),
              const SizedBox(width: 10),
              _ProductImage(
                imageUrl: item.productImage,
                isOutOfStock: item.isOutOfStock,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProductDetails(
                  item: item,
                  isSample: isSample,
                  onQuantityChanged: onQuantityChanged,
                  onRemove: onRemove,
                  onLimitReached: onLimitReached,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4444),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
          SizedBox(height: 4),
          Text(
            'Xóa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _Checkbox({
    required this.isSelected,
    this.isEnabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.4,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentGold : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppTheme.accentGold : AppTheme.softTaupe,
              width: 1.5,
            ),
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final bool isOutOfStock;
  const _ProductImage({required this.imageUrl, this.isOutOfStock = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ColorFiltered(
          colorFilter: isOutOfStock
              ? const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]) // Grayscale
              : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
          child: Opacity(
            opacity: isOutOfStock ? 0.6 : 1.0,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.spa_outlined,
                  color: AppTheme.softTaupe,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductDetails extends StatelessWidget {
  final CartItem item;
  final bool isSample;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final VoidCallback? onLimitReached;

  const _ProductDetails({
    required this.item,
    required this.isSample,
    required this.onQuantityChanged,
    required this.onRemove,
    this.onLimitReached,
  });

  bool get _hasVariantInfo =>
      (item.variant ?? '').isNotEmpty || (item.size ?? '').isNotEmpty;

  String get _variantInfo {
    final parts = <String>[];
    final v = item.variant ?? '';
    final s = item.size ?? '';

    if (v.isNotEmpty) parts.add(v);
    if (s.isNotEmpty && s != v) parts.add(s);

    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.productName,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepCharcoal,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSample) ...[const SizedBox(width: 8), const _SampleBadge()],
          ],
        ),
        if (_hasVariantInfo) ...[
          const SizedBox(height: 4),
          Text(
            _variantInfo.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppTheme.mutedSilver.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (item.isOutOfStock) ...[
          const SizedBox(height: 4),
          Text(
            'HẾT HÀNG',
            style: GoogleFonts.montserrat(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFD92D20), // Red 600
              letterSpacing: 0.5,
            ),
          ),
        ] else if (item.hasInsufficientStock) ...[
          const SizedBox(height: 4),
          Text(
            'CHỈ CÒN ${item.stock} SẢN PHẨM',
            style: GoogleFonts.montserrat(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF79009), // Orange 600
              letterSpacing: 0.5,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSample ? 'FREE GIFT' : 'PRICE',
                  style: GoogleFonts.montserrat(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.mutedSilver.withValues(alpha: 0.4),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isSample ? 'Miễn phí' : formatVND(item.price),
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
              ],
            ),
            const Spacer(),
            _InlineQty(
              quantity: item.quantity,
              canDecrease: item.quantity > 1,
              canIncrease: (!isSample || item.quantity < 1) && item.quantity < item.stock,
              onDecrease: () => onQuantityChanged(item.quantity - 1),
              onIncrease: () {
                if (!isSample && item.quantity >= item.stock) {
                  onLimitReached?.call();
                } else if (!isSample || item.quantity < 1) {
                  onQuantityChanged(item.quantity + 1);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _SampleBadge extends StatelessWidget {
  const _SampleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'MẪU THỬ',
        style: GoogleFonts.montserrat(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppTheme.accentGold,
        ),
      ),
    );
  }
}

class _InlineQty extends StatelessWidget {
  final int quantity;
  final bool canDecrease;
  final bool canIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _InlineQty({
    required this.quantity,
    required this.canDecrease,
    required this.canIncrease,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepCharcoal.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyBtn(
            icon: Icons.remove_rounded,
            active: canDecrease,
            onTap: canDecrease ? onDecrease : null,
          ),
          Container(
            width: 28,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.deepCharcoal,
              ),
            ),
          ),
          _QtyBtn(
            icon: Icons.add_rounded,
            active: canIncrease,
            onTap: onIncrease, // Make it clickable even if limit reached to trigger callback
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  const _QtyBtn({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 14,
            color: active
                ? AppTheme.deepCharcoal
                : AppTheme.mutedSilver.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}
