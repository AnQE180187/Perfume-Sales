import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TappableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressScaleFactor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final bool useGlassmorphism;
  final double glassOpacity;
  final double blurSigma;

  const TappableCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressScaleFactor = 1.02,
    this.borderRadius,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.boxShadow,
    this.useGlassmorphism = false,
    this.glassOpacity = 0.8,
    this.blurSigma = 10.0,
  });

  @override
  State<TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<TappableCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150), reverseDuration: const Duration(milliseconds: 300));
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.pressScaleFactor).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact(); // Micro-interaction haptics
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap!();
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = widget.borderRadius ?? BorderRadius.circular(24);
    
    Widget content = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.useGlassmorphism 
            ? (widget.backgroundColor ?? Colors.white).withOpacity(widget.glassOpacity)
            : widget.backgroundColor,
        borderRadius: defaultBorderRadius,
        boxShadow: widget.boxShadow,
        border: widget.useGlassmorphism ? Border.all(color: Colors.white.withOpacity(0.3), width: 1.5) : null,
      ),
      child: widget.child,
    );

    if (widget.useGlassmorphism) {
      content = ClipRRect(
        borderRadius: defaultBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
          child: content,
        ),
      );
    }

    return Container(
      margin: widget.margin,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onLongPress: widget.onLongPress != null ? () {
          HapticFeedback.heavyImpact();
          widget.onLongPress!();
        } : null,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            children: [
              content,
              if (_isPressed)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: defaultBorderRadius,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
