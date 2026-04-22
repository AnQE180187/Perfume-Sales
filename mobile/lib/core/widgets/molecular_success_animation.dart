import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MolecularSuccessAnimation extends StatefulWidget {
  final VoidCallback onFinish;

  const MolecularSuccessAnimation({super.key, required this.onFinish});

  @override
  State<MolecularSuccessAnimation> createState() => _MolecularSuccessAnimationState();
}

class _MolecularSuccessAnimationState extends State<MolecularSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Molecule> _molecules = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Create molecules
    for (int i = 0; i < 15; i++) {
      _molecules.add(_Molecule(
        offset: Offset(_rng.nextDouble(), _rng.nextDouble()),
        radius: _rng.nextDouble() * 4 + 2,
        speed: _rng.nextDouble() * 0.5 + 0.5,
      ));
    }

    _controller.forward().then((_) => widget.onFinish());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(400, 400),
          painter: _MolecularPainter(
            molecules: _molecules,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Molecule {
  final Offset offset;
  final double radius;
  final double speed;
  _Molecule({required this.offset, required this.radius, required this.speed});
}

class _MolecularPainter extends CustomPainter {
  final List<_Molecule> molecules;
  final double progress;

  _MolecularPainter({required this.molecules, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentGold.withOpacity((1 - progress).clamp(0, 1))
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppTheme.accentGold.withOpacity((1 - progress).clamp(0, 0.2))
      ..strokeWidth = 0.5;

    final center = Offset(size.width / 2, size.height / 2);
    final maxDist = size.width / 2;

    for (int i = 0; i < molecules.length; i++) {
      final m = molecules[i];
      // Expand from center
      final currentDist = progress * maxDist * m.speed;
      final angle = (i / molecules.length) * 2 * pi;
      
      final pos = Offset(
        center.dx + cos(angle) * currentDist,
        center.dy + sin(angle) * currentDist,
      );

      canvas.drawCircle(pos, m.radius * (1 - progress), paint);

      // Lines between nearby molecules
      for (int j = i + 1; j < molecules.length; j++) {
        final m2 = molecules[j];
        final angle2 = (j / molecules.length) * 2 * pi;
        final pos2 = Offset(
          center.dx + cos(angle2) * (progress * maxDist * m2.speed),
          center.dy + sin(angle2) * (progress * maxDist * m2.speed),
        );

        if ((pos - pos2).distance < 100) {
          canvas.drawLine(pos, pos2, linePaint);
        }
      }
    }
    
    // Success Checkmark in middle
    if (progress > 0.4) {
      final checkPaint = Paint()
        ..color = AppTheme.accentGold.withOpacity(((progress - 0.4) * 2).clamp(0, 1))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(center.dx - 20, center.dy);
      path.lineTo(center.dx - 5, center.dy + 15);
      path.lineTo(center.dx + 25, center.dy - 20);
      
      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
