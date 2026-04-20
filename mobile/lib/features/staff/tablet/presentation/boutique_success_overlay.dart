import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_spacing.dart';

class BoutiqueSuccessOverlay extends StatelessWidget {
  final String title;
  final VoidCallback onDismiss;

  const BoutiqueSuccessOverlay({
    super.key,
    required this.title,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Glass Background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Molecular Icon
                _SuccessIcon(),
                
                const SizedBox(height: 48),
                
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.accentGold,
                    letterSpacing: 4,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  "TRANSACTION FINALIZED SECURELY",
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white24,
                    letterSpacing: 4,
                  ),
                ),
                
                const SizedBox(height: 80),
                
                // Fine-line Button
                InkWell(
                  onTap: onDismiss,
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        "DISMISS",
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentGold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessIcon extends StatefulWidget {
  @override
  State<_SuccessIcon> createState() => _SuccessIconState();
}

class _SuccessIconState extends State<_SuccessIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, child) => Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.accentGold.withOpacity(0.2), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentGold.withOpacity(0.1),
              blurRadius: 40,
              spreadRadius: 10 * _ctrl.value,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.check_rounded, color: AppTheme.accentGold, size: 60),
            CircularProgressIndicator(
              value: _ctrl.value,
              strokeWidth: 0.5,
              color: AppTheme.accentGold.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
