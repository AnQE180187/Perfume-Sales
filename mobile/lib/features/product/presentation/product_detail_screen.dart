import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/floating_icon_button.dart';
import '../../../core/widgets/product_size_selector.dart';
import '../../../core/widgets/ai_scent_analysis_card.dart';
import '../../../core/widgets/scent_structure_section.dart';
import '../../../core/widgets/product_story_section.dart';
import '../../../core/widgets/product_bottom_cta.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  bool _isBookmarked = false;
  bool _isAIAnalysisExpanded = true;
  String _selectedSize = '100ml';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Size pricing map
  final Map<String, double> _sizePricing = {
    '10ml': 35.00,
    '20ml': 65.00,
    '50ml': 135.00,
    '100ml': 295.00,
  };

  double get _currentPrice => _sizePricing[_selectedSize] ?? 295.00;

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

  @override
  void dispose() {
    _animationController.dispose();
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
              Text('Failed to load product', style: GoogleFonts.montserrat()),
            ],
          ),
        ),
        data: (product) {
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
                    leading: FloatingIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => context.pop(),
                    ),
                    actions: [
                      FloatingIconButton(
                        icon: _isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        onTap: () =>
                            setState(() => _isBookmarked = !_isBookmarked),
                        isActive: _isBookmarked,
                      ),
                      const SizedBox(width: 8),
                      FloatingIconButton(
                        icon: _isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        onTap: () => setState(() => _isFavorite = !_isFavorite),
                        isActive: _isFavorite,
                      ),
                      const SizedBox(width: 16),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Hero(
                          tag: 'product-${product.id}',
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(32),
                              bottomRight: Radius.circular(32),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFE8D5B7),
                                    Color(0xFFF5F1ED),
                                  ],
                                ),
                              ),
                              child: Image.network(
                                product.imageUrl,
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
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ================= FLOATING PRODUCT INFO CARD =================
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -50),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
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
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  height: 1.15,
                                  color: AppTheme.deepCharcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // SUBTITLE
                              Text(
                                'Eau de Parfum',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: AppTheme.mutedSilver,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // RATING
                              if (product.rating != null)
                                GestureDetector(
                                  onTap: () {
                                    context.push(
                                      AppRoutes.reviewsWithProductId(
                                        product.id,
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: AppTheme.accentGold,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${product.rating}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.deepCharcoal,
                                        ),
                                      ),
                                      if (product.reviews != null) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          '(${product.reviews} reviews)',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            color: AppTheme.mutedSilver,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                      const Spacer(),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: AppTheme.mutedSilver,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ================= SIZE SELECTOR =================
                  SliverToBoxAdapter(
                    child: ProductSizeSelector(
                      selectedSize: _selectedSize,
                      onSizeChanged: (size) =>
                          setState(() => _selectedSize = size),
                    ),
                  ),

                  // ================= AI SCENT ANALYSIS =================
                  SliverToBoxAdapter(
                    child: AIScentAnalysisCard(
                      isExpanded: _isAIAnalysisExpanded,
                      onToggle: () => setState(
                        () => _isAIAnalysisExpanded = !_isAIAnalysisExpanded,
                      ),
                      notes: product.notes,
                    ),
                  ),

                  // ================= SCENT STRUCTURE =================
                  SliverToBoxAdapter(
                    child: ScentStructureSection(notes: product.notes),
                  ),

                  // ================= THE STORY =================
                  SliverToBoxAdapter(
                    child: ProductStorySection(
                      description: product.description,
                      productId: product.id,
                      productName: product.name,
                      imageUrl: product.imageUrl,
                    ),
                  ),

                  // ================= BOTTOM CTA =================
                  SliverToBoxAdapter(
                    child: ProductBottomCTA(
                      selectedSize: _selectedSize,
                      price: _currentPrice,
                      productName: product.name,
                    ),
                  ),

                  // Final padding
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
