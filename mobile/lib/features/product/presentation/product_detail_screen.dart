import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/product_size_selector.dart';
import '../../../core/widgets/ai_scent_analysis_card.dart';
import '../../../core/widgets/product_bottom_cta.dart';
import '../../../core/widgets/luxury_button.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/providers/cart_selection_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../../../core/widgets/product_price_section.dart';
import '../../../core/widgets/scent_structure_section.dart';
import 'scent_structure_detail_screen.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  final String? heroTag;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.heroTag,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isAIAnalysisExpanded = false;
  bool _isStoryExpanded = false;
  String _selectedSize = '100ml';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final PageController _pageController = PageController();
  int _currentImagePage = 0;
  Color? _dominantColor;
  String? _loadedImageUrl;

  // Size pricing map
  final Map<String, double> _sizePricing = {
    '10ml': 35.00,
    '20ml': 65.00,
    '50ml': 135.00,
    '100ml': 295.00,
  };

  ProductVariant? _findSelectedVariant(Product product, String selectedSize) {
    if (product.variants.isEmpty) return null;

    for (final variant in product.variants) {
      if (!variant.isActive) continue;
      if (variant.name.toLowerCase() == selectedSize.toLowerCase()) {
        return variant;
      }
    }

    for (final variant in product.variants) {
      if (variant.isActive) return variant;
    }

    return product.variants.first;
  }

  double _priceFor(Product product, String selectedSize) {
    final selectedVariant = _findSelectedVariant(product, selectedSize);
    if (selectedVariant != null) return selectedVariant.price;
    return _sizePricing[selectedSize] ?? product.price;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  Future<void> _extractColor(String imageUrl) async {
    if (_loadedImageUrl == imageUrl) return;
    _loadedImageUrl = imageUrl;
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        size: const Size(100, 100),
      );
      if (mounted) {
        setState(() {
          _dominantColor = palette.dominantColor?.color ?? palette.lightMutedColor?.color;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accentGold),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.mutedSilver,
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.failedLoadOrder, style: GoogleFonts.montserrat()),
            ],
          ),
        ),
        data: (product) {
          final images = (product.images != null && product.images!.isNotEmpty)
              ? product.images!
              : [product.imageUrl];
          final backendVariantSizes = product.variants
              .where((variant) => variant.isActive)
              .map((variant) => variant.name)
              .toList();
          final selectedSize = backendVariantSizes.contains(_selectedSize)
              ? _selectedSize
              : (backendVariantSizes.isNotEmpty
                    ? backendVariantSizes.first
                    : _selectedSize);
          final currentPrice = _priceFor(product, selectedSize);

          if (_dominantColor == null && _loadedImageUrl != images.first) {
            _extractColor(images.first);
          }

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // ================= HERO IMAGE =================
                  SliverAppBar(
                    expandedHeight: screenHeight * 0.55,
                    pinned: false,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: AppTheme.creamWhite, size: 22),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.share_outlined, color: AppTheme.creamWhite, size: 22),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 4),
                      Consumer(
                        builder: (context, ref, _) {
                          final isFav =
                              ref
                                  .watch(wishlistProvider)
                                  .valueOrNull
                                  ?.any((p) => p.id == product.id) ??
                              false;
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? const Color(0xFFD32F2F) : AppTheme.creamWhite,
                              size: 22,
                            ),
                            onPressed: () => ref
                                .read(wishlistProvider.notifier)
                                .toggle(product),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Hero(
                          tag: widget.heroTag ?? 'product-${product.id}',
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(32),
                              bottomRight: Radius.circular(32),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // gradient background
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        _dominantColor?.withValues(alpha: 0.15) ?? const Color(0xFFE8D5B7),
                                        _dominantColor?.withValues(alpha: 0.5) ?? const Color(0xFFF5F1ED),
                                      ],
                                    ),
                                  ),
                                ),
                                // swipeable image gallery
                                PageView.builder(
                                  controller: _pageController,
                                  onPageChanged: (i) =>
                                      setState(() => _currentImagePage = i),
                                  itemCount: images.length,
                                  itemBuilder: (_, i) => Image.network(
                                    images[i],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 64,
                                        color: AppTheme.mutedSilver,
                                      ),
                                    ),
                                  ),
                                ),
                                // dark gradient for icon visibility
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: 120,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppTheme.deepCharcoal.withValues(alpha: 0.45),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // indicator dots
                                if (images.length > 1)
                                  Positioned(
                                    bottom: 32,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        images.length,
                                        (i) => AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 3,
                                          ),
                                          width: i == _currentImagePage
                                              ? 20.0
                                              : 6.0,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: i == _currentImagePage
                                                ? AppTheme.creamWhite
                                                : AppTheme.creamWhite.withValues(
                                                    alpha: 0.4,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ================= PRODUCT INFO CARD =================
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      // Light overlap with hero bottom edge
                      offset: const Offset(0, -24),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                          decoration: BoxDecoration(
                            color: AppTheme.ivoryBackground,
                            borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.deepCharcoal.withValues(alpha: 0.10),
                                    blurRadius: 32,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: AppTheme.deepCharcoal.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // BRAND
                              Text(
                                product.brand.toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentGold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // NAME
                              Text(
                                product.name,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                  color: AppTheme.deepCharcoal,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // SUBTITLE
                              Text(
                                AppLocalizations.of(context)!.eauDeParfum,
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.mutedSilver,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // RATING + VIEW REVIEWS
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (product.rating != null)
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 14,
                                            color: AppTheme.accentGold,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${product.rating!.toStringAsFixed(1)}/5',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.deepCharcoal,
                                            ),
                                          ),
                                          if (product.reviews != null) ...[
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                '· ${product.reviews} ${AppLocalizations.of(context)!.rating}',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 11,
                                                  color: AppTheme.mutedSilver,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!.noReviews,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          color: AppTheme.mutedSilver,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => context.push(
                                      AppRoutes.reviewsWithProductId(
                                        product.id,
                                        productName: product.name,
                                      ),
                                    ),
                                    child: Text(
                                      '${AppLocalizations.of(context)!.viewReviews} →',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
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
                      ),
                    ),
                  ),

                  // ================= PRICE (above the fold) =================
                  SliverToBoxAdapter(
                    child: ProductPriceSection(price: currentPrice),
                  ),

                  // ================= SIZE SELECTOR =================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: ProductSizeSelector(
                        selectedSize: selectedSize,
                        sizes: backendVariantSizes.isEmpty
                            ? null
                            : backendVariantSizes,
                        onSizeChanged: (size) =>
                            setState(() => _selectedSize = size),
                      ),
                    ),
                  ),

                  // ================= AI SCENT ANALYSIS =================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: AIScentAnalysisCard(
                        isExpanded: _isAIAnalysisExpanded,
                        onToggle: () => setState(
                          () => _isAIAnalysisExpanded = !_isAIAnalysisExpanded,
                        ),
                        notes: product.notes,
                        scentAnalysis: product.scentAnalysis,
                      ),
                    ),
                  ),

                  // ================= SCENT STRUCTURE =================
                  SliverToBoxAdapter(
                    child: ScentStructureSection(
                      notes: product.notes,
                      topNotes: product.topNotes,
                      heartNotes: product.heartNotes,
                      baseNotes: product.baseNotes,
                      onViewAll: () {
                        if (!mounted) return;
                        Navigator.of(context, rootNavigator: true).push(
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 420,
                            ),
                            reverseTransitionDuration: const Duration(
                              milliseconds: 280,
                            ),
                            pageBuilder: (_, __, ___) =>
                                ScentStructureDetailScreen(
                                  productName: product.name,
                                  notes: product.notes,
                                  topNotes: product.topNotes,
                                  heartNotes: product.heartNotes,
                                  baseNotes: product.baseNotes,
                                ),
                            transitionsBuilder: (_, animation, __, child) {
                              final fade = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              );
                              final scale = Tween<double>(begin: 0.985, end: 1)
                                  .animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOut,
                                    ),
                                  );

                              return FadeTransition(
                                opacity: fade,
                                child: ScaleTransition(
                                  scale: scale,
                                  child: child,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // ================= TECHNICAL SPECS =================
                  SliverToBoxAdapter(
                    child: _TechnicalSpecsSection(
                      longevity: product.longevity,
                      concentration: product.concentration,
                    ),
                  ),

                  // ================= PRODUCT STORY =================
                  SliverToBoxAdapter(
                    child: _ProductStorySection(
                      product: product,
                      isExpanded: _isStoryExpanded,
                      onToggle: () => setState(() => _isStoryExpanded = !_isStoryExpanded),
                    ),
                  ),

                  // Bottom padding — space reserved for the sticky CTA overlay
                  const SliverToBoxAdapter(child: SizedBox(height: 110)),
                ],
              ),

              // ===================== STICKY CTA =====================
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ProductBottomCTA(
                  selectedSize: selectedSize,
                  price: currentPrice,
                  productName: product.name,
                  onAddToCart: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final variant = _findSelectedVariant(product, selectedSize);
                    if (variant == null || variant.id.isEmpty) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.variantNotFound,
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    try {
                      await ref
                          .read(cartProvider.notifier)
                          .addItemByVariant(variant.id, quantity: 1);

                      if (!context.mounted) return;
                      final l10nAfter = AppLocalizations.of(context)!;
                      messenger.clearSnackBars();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${l10nAfter.addedToCart} ${product.name}',
                                  style: const TextStyle(fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  messenger.hideCurrentSnackBar();
                                  if (context.mounted) {
                                    context.push('/cart');
                                  }
                                },
                                child: Text(
                                  l10nAfter.viewCart,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } catch (error) {
                      if (!context.mounted) return;
                      final l10nAfter = AppLocalizations.of(context)!;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('${l10nAfter.failedAddToCart}: $error'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  onBuyNow: () async {
                    final l10n = AppLocalizations.of(context)!;
                    final variant = _findSelectedVariant(product, selectedSize);
                    if (variant == null || variant.id.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.variantNotFound),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    try {
                      // 1) Add to cart (backend may merge quantities)
                      await ref
                          .read(cartProvider.notifier)
                          .addItemByVariant(variant.id, quantity: 1);

                      if (!mounted) return;

                      // 2) Select ONLY this product in checkout
                      final cart = ref.read(cartProvider);
                      final target = cart.items.firstWhere(
                        (it) {
                          final sameProduct = it.productId == product.id;
                          final sizeMatch = (it.size ?? '')
                              .toLowerCase()
                              .contains(selectedSize.toLowerCase());
                          return sameProduct && (sizeMatch || it.size == null);
                        },
                        orElse: () => cart.items.firstWhere(
                          (it) => it.productId == product.id,
                          orElse: () => cart.items.isNotEmpty
                              ? cart.items.first
                              : throw StateError('empty cart'),
                        ),
                      );

                      ref
                          .read(cartSelectionProvider.notifier)
                          .setSelection({target.id}, selectAll: false);

                      if (!context.mounted) return;
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.hideCurrentSnackBar();
                      context.push(AppRoutes.checkout);
                    } catch (e) {
                      if (!context.mounted) return;
                      final l10nAfter = AppLocalizations.of(context)!;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${l10nAfter.error}: $e'),
                          backgroundColor: const Color(0xFFD32F2F),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TechnicalSpecsSection extends StatelessWidget {
  final String? longevity;
  final String? concentration;

  const _TechnicalSpecsSection({this.longevity, this.concentration});

  @override
  Widget build(BuildContext context) {
    if (longevity == null && concentration == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.creamWhite.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THÔNG SỐ KỸ THUẬT',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppTheme.accentGold,
            ),
          ),
          const SizedBox(height: 16),
          _specRow(Icons.timer_outlined, 'Độ lưu hương', longevity ?? 'Đang cập nhật'),
          const Divider(height: 24, color: AppTheme.softTaupe),
          _specRow(Icons.water_drop_outlined, 'Nồng độ', concentration ?? 'Đang cập nhật'),
        ],
      ),
    );
  }

  Widget _specRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.mutedSilver),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: AppTheme.deepCharcoal.withOpacity(0.6),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.deepCharcoal,
          ),
        ),
      ],
    );
  }
}

class _ProductStorySection extends StatelessWidget {
  final Product product;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ProductStorySection({
    required this.product,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final story = product.story ?? product.description ?? '';
    if (story.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 1,
                color: AppTheme.accentGold,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.theStory.toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: AppTheme.accentGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            story,
            maxLines: isExpanded ? null : 4,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              height: 1.7,
              color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isExpanded ? 'Thu gọn' : 'Xem thêm',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentGold,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppTheme.accentGold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
