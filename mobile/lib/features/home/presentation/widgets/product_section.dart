import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../product/models/product.dart';
import '../../../profile/providers/ai_preferences_provider.dart';
import '../../../wishlist/providers/wishlist_provider.dart';

class ProductSection extends ConsumerWidget {
  final String title;
  final String? actionText;
  final AsyncValue<List<Product>> productsAsync;
  final bool isHorizontal;

  const ProductSection({
    super.key,
    required this.title,
    this.actionText,
    required this.productsAsync,
    this.isHorizontal = false,
  });

  int _calculateMatch(Product product, List<String> preferredNotes) {
    if (preferredNotes.isEmpty) return 0;
    final productNotes = product.notes.map((n) => n.toLowerCase()).toSet();
    int matches = 0;
    for (var note in preferredNotes) {
      if (productNotes.contains(note.toLowerCase())) matches++;
    }
    // Simple mock calculation for luxury feel: base 75% + bonus for each match
    if (matches == 0) return 0;
    return (75 + (matches * 10)).clamp(80, 99);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistProvider);
    final wishlistIds = wishlistAsync.value?.map((p) => p.id).toSet() ?? {};
    final aiPrefs = ref.watch(aiPreferencesProvider).value;
    final preferredNotes = aiPrefs?.preferredNotes ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: title,
            onViewAll: () => context.push('/explore'),
            showViewAll: actionText != null,
          ),
        ),
        productsAsync.when(
          loading: () => isHorizontal
              ? const _HorizontalShimmer()
              : SingleChildScrollView(
                  child: ShimmerProductGrid(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                ),
          error: (error, stack) => const SizedBox(
            height: 200,
            child: Center(child: Text('Không thể tải dữ liệu')),
          ),
          data: (products) {
            if (products.isEmpty) return const SizedBox();

            if (isHorizontal) {
              return SizedBox(
                height: 340,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isFav = wishlistIds.contains(product.id);
                    final match = _calculateMatch(product, preferredNotes);
                    
                    return ProductCard(
                      product: product,
                      variant: ProductCardVariant.featured,
                      matchPercent: match > 0 ? match : null,
                      isFavorite: isFav,
                      heroTag: 'horiz_${title.replaceAll(' ', '_')}_${product.id}',
                      onTap: () => context.push(
                        '/product/${product.id}?heroTag=horiz_${title.replaceAll(' ', '_')}_${product.id}',
                      ),
                      onFavoriteToggle: () {
                        ref.read(wishlistProvider.notifier).toggle(product);
                      },
                    );
                  },
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8),
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
                  final match = _calculateMatch(product, preferredNotes);

                  return ProductCard(
                    product: product,
                    variant: ProductCardVariant.grid,
                    matchPercent: match > 0 ? match : null,
                    heroTag: '${title.replaceAll(' ', '_')}_${product.id}',
                    onTap: () => context.push(
                      '/product/${product.id}?heroTag=${title.replaceAll(' ', '_')}_${product.id}',
                    ),
                    onFavoriteToggle: () {
                      ref.read(wishlistProvider.notifier).toggle(product);
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HorizontalShimmer extends StatelessWidget {
  const _HorizontalShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ShimmerBox(
            width: 200,
            height: 340,
            borderRadius: 20,
          ),
        ),
      ),
    );
  }
}
