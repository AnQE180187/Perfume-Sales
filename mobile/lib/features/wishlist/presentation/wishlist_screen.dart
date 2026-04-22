import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_async_widget.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/luxury_button.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/wishlist_provider.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.wishlistTitle,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.deepCharcoal,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepCharcoal),
          onPressed: () => context.pop(),
        ),
      ),
      body: AppAsyncWidget(
        value: ref.watch(wishlistProvider),
        onRetry: () => ref.invalidate(wishlistProvider),
        loadingBuilder: () => SingleChildScrollView(
          child: ShimmerProductGrid(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          ),
        ),
        dataBuilder: (wishlist) => wishlist.isNotEmpty
            ? GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.49, // Updated for consistency with other grids
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: wishlist.length,
                itemBuilder: (context, index) {
                  final product = wishlist[index];
                  return ProductCard(
                    product: product,
                    variant: ProductCardVariant.grid,
                    isFavorite: true,
                    onTap: () => context.push('/product/${product.id}'),
                    onFavoriteToggle: () {
                      ref.read(wishlistProvider.notifier).toggle(product);
                    },
                  );
                },
              )
            : EmptyStateWidget(
                icon: Icons.favorite_border,
                title: l10n.wishlistEmptyTitle,
                subtitle: l10n.wishlistEmptySubtitle,
                action: LuxuryButton(
                  text: l10n.exploreFragrances,
                  onPressed: () => context.go('/explore'),
                ),
              ),
      ),
    );
  }
}
