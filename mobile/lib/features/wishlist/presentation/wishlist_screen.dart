import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/wishlist_provider.dart';
import '../../product/models/product.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'WISHLIST',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            letterSpacing: 4,
            fontSize: 12,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: wishlist.isNotEmpty
          ? GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
              ),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final product = wishlist[index];
                return _WishlistProductCard(product: product);
              },
            )
          : _buildEmptyState(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 48,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'YOUR WISHLIST IS EMPTY',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Discover scents that speak to your soul',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => context.go('/home'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              side: BorderSide(color: AppTheme.champagneGold, width: 0.5),
            ),
            child: Text(
              'EXPLORE COLLECTION',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistProductCard extends ConsumerWidget {
  final Product product;

  const _WishlistProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(wishlistProvider.notifier).toggle(product);
                      },
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            color: Colors.black.withValues(alpha: 0.2),
                            child: const Icon(
                              Icons.favorite,
                              size: 16,
                              color: AppTheme.champagneGold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 8,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.w500,
                    ),
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
