import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../product/models/product.dart';
import '../../../../core/widgets/product_card.dart';
import 'package:go_router/go_router.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wishlist/providers/wishlist_provider.dart';

class RecentlyViewedSection extends ConsumerWidget {
  final List<Product> products;

  const RecentlyViewedSection({super.key, required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final wishlistAsync = ref.watch(wishlistProvider);
    final wishlistIds = wishlistAsync.value?.map((p) => p.id).toSet() ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            l10n.recentlyViewed,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppTheme.deepCharcoal.withValues(alpha: 0.5),
            ),
          ),
        ),
        SizedBox(
          height: 285,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = products[index];
              final isFav = wishlistIds.contains(product.id);
              
              return SizedBox(
                width: 140,
                child: ProductCard(
                  product: product,
                  variant: ProductCardVariant.grid,
                  isFavorite: isFav,
                  onTap: () => context.push('/product/${product.id}'),
                  onFavoriteToggle: () {
                    ref.read(wishlistProvider.notifier).toggle(product);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
