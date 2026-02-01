import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ProductBottomCTA extends StatelessWidget {
  final String selectedSize;
  final double price;
  final String productName;

  const ProductBottomCTA({
    super.key,
    required this.selectedSize,
    required this.price,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedSize.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: AppTheme.mutedSilver,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                    ],
                  ),
                ),
                _AnimatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$productName added to bag'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  isPrimary: true,
                  child: Text(
                    'Add to Bag',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _AnimatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Proceeding to checkout'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  isPrimary: false,
                  child: Text(
                    'Buy',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Free returns within 14 days',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: AppTheme.mutedSilver,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isPrimary;

  const _AnimatedButton({
    required this.onPressed,
    required this.child,
    required this.isPrimary,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        height: 44,
        child: widget.isPrimary
            ? ElevatedButton(
                onPressed: () async {
                  await _controller.forward();
                  await _controller.reverse();
                  widget.onPressed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: widget.child,
              )
            : OutlinedButton(
                onPressed: () async {
                  await _controller.forward();
                  await _controller.reverse();
                  widget.onPressed();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentGold,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  side: const BorderSide(
                    color: AppTheme.accentGold,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: widget.child,
              ),
      ),
    );
  }
}
