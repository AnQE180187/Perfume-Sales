import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class ReturnSuccessScreen extends StatefulWidget {
  final String returnId;
  const ReturnSuccessScreen({super.key, required this.returnId});

  @override
  State<ReturnSuccessScreen> createState() => _ReturnSuccessScreenState();
}

class _ReturnSuccessScreenState extends State<ReturnSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _particleController;
  late final Animation<double> _sealScale;
  late final Animation<double> _sealRotate;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  final List<_ParticleModel> _particles = List.generate(
    25,
    (index) => _ParticleModel(),
  );

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _sealScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.1), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _sealRotate = Tween<double>(begin: -0.2, end: 0.0).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    ));

    _contentFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
    ));

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(_particles, _particleController.value),
                );
              },
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  ScaleTransition(
                    scale: _sealScale,
                    child: RotationTransition(
                      turns: _sealRotate,
                      child: const Center(
                        child: _MetallicSuccessSeal(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          Text(
                            l10n.returnRequestSuccess,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: AppTheme.deepCharcoal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.returnSuccessSubtitle.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: AppTheme.mutedSilver,
                            ),
                          ),
                          const SizedBox(height: 40),
                          _ReturnInfoCard(
                            returnId: widget.returnId,
                          ),
                          const SizedBox(height: 48),
                          _ActionButton(
                            label: l10n.viewReturnDetails,
                            onPressed: () => context.push('/returns/${widget.returnId}'),
                            isPrimary: true,
                          ),
                          const SizedBox(height: 16),
                          _ActionButton(
                            label: l10n.returnToHome,
                            onPressed: () => context.go('/'),
                            isPrimary: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetallicSuccessSeal extends StatelessWidget {
  const _MetallicSuccessSeal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFF1E5AC),
            Color(0xFFD4AF37),
            Color(0xFFB8860B),
          ],
          stops: [0.2, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 64,
          ),
        ],
      ),
    );
  }
}

class _ReturnInfoCard extends StatelessWidget {
  final String returnId;

  const _ReturnInfoCard({required this.returnId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5D5C0).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepCharcoal.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppTheme.accentGold, size: 18),
                const SizedBox(width: 12),
                Text(
                  l10n.returnGuidanceTitle.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _InfoRow(
              label: l10n.returnIdLabel,
              value: '#${returnId.substring(returnId.length - 8).toUpperCase()}',
              icon: Icons.assignment_outlined,
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: l10n.timeUpper,
              value: l10n.returnProcessNotice,
              icon: Icons.timer_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.ivoryBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppTheme.mutedSilver),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppTheme.mutedSilver,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ] : null,
      ),
      child: isPrimary 
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          )
        : TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: AppTheme.softTaupe.withValues(alpha: 0.4)),
              ),
            ),
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: AppTheme.mutedSilver,
              ),
            ),
          ),
    );
  }
}

class _ParticleModel {
  late double x;
  late double y;
  late double size;
  late double speed;
  late double opacity;

  _ParticleModel() {
    _reset();
  }

  void _reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    size = math.Random().nextDouble() * 3 + 1;
    speed = math.Random().nextDouble() * 0.1 + 0.02;
    opacity = math.Random().nextDouble() * 0.5 + 0.1;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_ParticleModel> particles;
  final double animationValue;

  _ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.accentGold.withValues(alpha: 0.2);

    for (var p in particles) {
      double currentY = (p.y - (animationValue * p.speed)) % 1.0;
      canvas.drawCircle(
        Offset(p.x * size.width, currentY * size.height),
        p.size,
        paint..color = AppTheme.accentGold.withValues(alpha: p.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
