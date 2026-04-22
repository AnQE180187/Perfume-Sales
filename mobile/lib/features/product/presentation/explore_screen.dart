import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_async_widget.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../providers/product_provider.dart';
import '../providers/product_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final wishlistAsync = ref.watch(wishlistProvider);
    final wishlistIds = wishlistAsync.value?.map((p) => p.id).toSet() ?? {};

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar (arrow moved to the left)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.creamWhite,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.deepCharcoal.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: AppTheme.deepCharcoal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/search'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.creamWhite,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.deepCharcoal.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: AppTheme.mutedSilver.withValues(
                                alpha: 0.6,
                              ),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.searchExploreHint,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.mutedSilver.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Luxury Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.navExplore,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
              ),
            ),

            // Products Grid
            Expanded(
              child: AppAsyncWidget(
                value: productsAsync,
                onRetry: () => ref.invalidate(productsProvider),
                loadingBuilder: () => SingleChildScrollView(
                  child: ShimmerProductGrid(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                ),
                dataBuilder: (products) => LiquidPullToRefresh(
                  onRefresh: () async {
                    ref.invalidate(productsProvider);
                    // Minimal delay to let animation finish fully
                    await Future.delayed(const Duration(milliseconds: 1000));
                  },
                  color: AppTheme.creamWhite,
                  backgroundColor: AppTheme.accentGold,
                  animSpeedFactor: 2,
                  showChildOpacityTransition: false,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.49,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isFav = wishlistIds.contains(product.id);
                      return ProductCard(
                        product: product,
                        variant: ProductCardVariant.grid,
                        badge: (product.rating ?? 0) >= 4.9
                            ? AppLocalizations.of(context)!.topRated
                            : null,
                        isFavorite: isFav,
                        heroTag: 'explore_${product.id}',
                        onTap: () => context.push('/product/${product.id}?heroTag=explore_${product.id}'),
                        onFavoriteToggle: () {
                          ref.read(wishlistProvider.notifier).toggle(product);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
