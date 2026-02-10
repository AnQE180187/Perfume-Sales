import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ProductSizeSelector extends StatefulWidget {
  final String selectedSize;
  final ValueChanged<String> onSizeChanged;

  const ProductSizeSelector({
    super.key,
    required this.selectedSize,
    required this.onSizeChanged,
  });

  @override
  State<ProductSizeSelector> createState() => _ProductSizeSelectorState();
}

class _ProductSizeSelectorState extends State<ProductSizeSelector> {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Size',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SizeOption(
                    size: '10ml',
                    label: 'TRIAL SIZE',
                    isSelected: widget.selectedSize == '10ml',
                    onTap: () => widget.onSizeChanged('10ml'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SizeOption(
                    size: '20ml',
                    isSelected: widget.selectedSize == '20ml',
                    onTap: () => widget.onSizeChanged('20ml'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SizeOption(
                    size: '50ml',
                    isSelected: widget.selectedSize == '50ml',
                    onTap: () => widget.onSizeChanged('50ml'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SizeOption(
                    size: '100ml',
                    label: 'BEST VALUE',
                    isSelected: widget.selectedSize == '100ml',
                    onTap: () => widget.onSizeChanged('100ml'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeOption extends StatefulWidget {
  final String size;
  final String? label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SizeOption({
    required this.size,
    this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SizeOption> createState() => _SizeOptionState();
}

class _SizeOptionState extends State<_SizeOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _scaleController.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 56,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.accentGold.withValues(alpha: 0.08)
                : Colors.white,
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.accentGold
                  : const Color(0xFFE8E8E8),
              width: widget.isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.label != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.label!,
                    style: GoogleFonts.montserrat(
                      fontSize: 6,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                widget.size,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.isSelected
                      ? AppTheme.accentGold
                      : AppTheme.deepCharcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
