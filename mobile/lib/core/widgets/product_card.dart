import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart';
import '../../features/product/models/product.dart';
import 'luxury_button.dart';
import 'tappable_card.dart';
import 'custom_shimmer.dart';

enum ProductCardVariant { featured, grid, list }

class ProductCard extends StatelessWidget {
  final Product product;
  final ProductCardVariant variant;
  final String? badge;
  final int? matchPercent;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final String? heroTag;

  const ProductCard({
    super.key,
    required this.product,
    this.variant = ProductCardVariant.grid,
    this.badge,
    this.matchPercent,
    this.onTap,
    this.onAdd,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case ProductCardVariant.featured:
        return _FeaturedCard(
          product: product,
          badge: badge,
          isFavorite: isFavorite,
          onTap: onTap,
          onFavoriteToggle: onFavoriteToggle,
          heroTag: heroTag,
        );
      case ProductCardVariant.grid:
        return _GridCard(
          product: product,
          badge: badge,
          matchPercent: matchPercent,
          isFavorite: isFavorite,
          onTap: onTap,
          onFavoriteToggle: onFavoriteToggle,
          heroTag: heroTag,
        );
      case ProductCardVariant.list:
        return _ListCard(
          product: product,
          matchPercent: matchPercent,
          isFavorite: isFavorite,
          onTap: onTap,
          onAdd: onAdd,
          onFavoriteToggle: onFavoriteToggle,
          heroTag: heroTag,
        );
    }
  }
}

class _FeaturedCard extends StatelessWidget {
  final Product product;
  final String? badge;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final String? heroTag;

  const _FeaturedCard({
    required this.product,
    this.badge,
    required this.isFavorite,
    this.onTap,
    this.onFavoriteToggle,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return TappableCard(
      onTap: onTap,
      margin: const EdgeInsets.only(right: 16),
      useGlassmorphism: true,
      glassOpacity: 0.95,
      backgroundColor: AppTheme.creamWhite,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppTheme.deepCharcoal.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      child: SizedBox(
        width: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: heroTag ?? 'product-${product.id}',
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const CustomShimmer(
                            width: double.infinity,
                            height: double.infinity,
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF5F1ED),
                          child: const Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: AppTheme.mutedSilver,
                          ),
                        ),
                      ),
                    ),
                    // Gradient overlay for better icon visibility
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              AppTheme.deepCharcoal.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (badge != null)
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: _LuxuryBadge(text: badge!),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _FavoriteButton(
                        isFavorite: isFavorite,
                        onTap: onFavoriteToggle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppTheme.deepCharcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.scentFamily != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.scentFamily!,
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.accentGold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 34,
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          formatVND(product.price),
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.deepCharcoal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (product.rating != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 11,
                              color: AppTheme.accentGold,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.rating!.toStringAsFixed(1),
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.mutedSilver,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final Product product;
  final String? badge;
  final int? matchPercent;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final String? heroTag;

  const _GridCard({
    required this.product,
    this.badge,
    this.matchPercent,
    required this.isFavorite,
    this.onTap,
    this.onFavoriteToggle,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return TappableCard(
      onTap: onTap,
      backgroundColor: AppTheme.creamWhite,
      borderRadius: BorderRadius.circular(24),
      useGlassmorphism: true,
      glassOpacity: 0.95,
      boxShadow: [
        BoxShadow(
          color: AppTheme.deepCharcoal.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag ?? 'product-${product.id}',
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const CustomShimmer(
                          width: double.infinity,
                          height: double.infinity,
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF5F1ED),
                        child: const Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: AppTheme.mutedSilver,
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay for better icon visibility
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            AppTheme.deepCharcoal.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: _LuxuryBadge(text: badge!),
                    ),
                  if (matchPercent != null)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Text(
                              '$matchPercent%',
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _FavoriteButton(
                      isFavorite: isFavorite,
                      onTap: onFavoriteToggle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: AppTheme.deepCharcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.scentFamily != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.scentFamily!,
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentGold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 32, // Fixed height for 2 lines
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                  ),
                  if (product.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 20, // Fixed height for tags
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: product.notes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 4),
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () => context.push('/search?note=${product.notes[i]}'),
                          child: _ScentTag(text: product.notes[i]),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          formatVND(product.price),
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.deepCharcoal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.rating != null) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.star,
                          size: 11,
                          color: AppTheme.accentGold,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating!.toStringAsFixed(1),
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.mutedSilver,
                          ),
                        ),
                      ],
                    ],
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

class _ListCard extends StatelessWidget {
  final Product product;
  final int? matchPercent;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final VoidCallback? onFavoriteToggle;
  final String? heroTag;

  const _ListCard({
    required this.product,
    this.matchPercent,
    required this.isFavorite,
    this.onTap,
    this.onAdd,
    this.onFavoriteToggle,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return TappableCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      backgroundColor: AppTheme.creamWhite,
      borderRadius: BorderRadius.circular(16),
      useGlassmorphism: true,
      glassOpacity: 0.95,
      boxShadow: [
        BoxShadow(
          color: AppTheme.deepCharcoal.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      child: SizedBox(
        height: 106, // Height adjusts via constraints
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Hero(
                tag: heroTag ?? 'product-${product.id}',
                child: Image.network(
                  product.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const CustomShimmer(width: 90, height: 90);
                  },
                  errorBuilder: (_, __, ___) => Container(
                    width: 90,
                    height: 90,
                    color: const Color(0xFFF5F1ED),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 32,
                      color: AppTheme.mutedSilver,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: AppTheme.deepCharcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color: AppTheme.deepCharcoal,
                    ),
                  ),
                  if (product.description != null && product.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: AppTheme.mutedSilver,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        formatVND(product.price),
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                      if (matchPercent != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
                          ),
                          child: Text(
                            '$matchPercent% Match',
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentGold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 85,
              height: 38,
              child: LuxuryButton(
                text: 'ADD',
                height: 38,
                onPressed: onAdd,
                trailingIcon: Icons.arrow_forward,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScentTag extends StatelessWidget {
  final String text;
  const _ScentTag({required this.text});

  Color _getTagColor(String scent) {
    final s = scent.toLowerCase();
    if (s.contains('bergamot') || s.contains('lemon') || s.contains('citrus')) return const Color(0xFFFDF7E7);
    if (s.contains('jasmine') || s.contains('rose') || s.contains('floral') || s.contains('lavender')) return const Color(0xFFF5EEFD);
    if (s.contains('wood') || s.contains('cedar') || s.contains('sandalwood')) return const Color(0xFFEFEBE9);
    if (s.contains('vanilla') || s.contains('amber') || s.contains('musk')) return const Color(0xFFFDF2F0);
    return const Color(0xFFE8F5E9);
  }

  Color _getTextColor(String scent) {
    final s = scent.toLowerCase();
    if (s.contains('bergamot') || s.contains('lemon') || s.contains('citrus')) return const Color(0xFF8B7310);
    if (s.contains('jasmine') || s.contains('rose') || s.contains('floral') || s.contains('lavender')) return const Color(0xFF6A1B9A);
    if (s.contains('wood') || s.contains('cedar') || s.contains('sandalwood')) return const Color(0xFF5D4037);
    if (s.contains('vanilla') || s.contains('amber') || s.contains('musk')) return const Color(0xFFC62828);
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getTagColor(text);
    final textColor = _getTextColor(text);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.montserrat(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.1,
          height: 1.1,
        ),
      ),
    );
  }
}

class _LuxuryBadge extends StatelessWidget {
  final String text;
  const _LuxuryBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppTheme.creamWhite.withOpacity(0.6),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentGold.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.2),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 14,
            color: AppTheme.accentGold,
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback? onTap;

  const _FavoriteButton({required this.isFavorite, this.onTap});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      if (!widget.isFavorite) {
        _controller.forward(from: 0.0);
        _showFavoriteNotification(context);
      }
      widget.onTap!();
    }
  }

  void _showFavoriteNotification(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: Color(0xFFD32F2F), size: 16),
            const SizedBox(width: 10),
            Text(
              'Đã thêm vào mục yêu thích',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.creamWhite,
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        margin: const EdgeInsets.fromLTRB(40, 0, 40, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: AppTheme.softTaupe.withOpacity(0.1)),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Icon(
                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: widget.isFavorite ? const Color(0xFFD32F2F) : AppTheme.creamWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
