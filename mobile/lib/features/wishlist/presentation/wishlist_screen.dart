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
import '../../product/models/product.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

enum WishlistSort { newest, priceLow, priceHigh, name }
enum WishlistView { grid, list }

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen>
    with SingleTickerProviderStateMixin {
  WishlistSort _sort = WishlistSort.newest;
  WishlistView _viewMode = WishlistView.grid;
  late AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  List<Product> _sortProducts(List<Product> products) {
    final sorted = List<Product>.from(products);
    switch (_sort) {
      case WishlistSort.newest:
        return sorted; // API order = newest
      case WishlistSort.priceLow:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        return sorted;
      case WishlistSort.priceHigh:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        return sorted;
      case WishlistSort.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        return sorted;
    }
  }

  String _sortLabel(WishlistSort s) {
    final l10n = AppLocalizations.of(context)!;
    switch (s) {
      case WishlistSort.newest:
        return l10n.localeName == 'vi' ? 'Mới nhất' : 'Newest';
      case WishlistSort.priceLow:
        return l10n.localeName == 'vi' ? 'Giá tăng' : 'Price ↑';
      case WishlistSort.priceHigh:
        return l10n.localeName == 'vi' ? 'Giá giảm' : 'Price ↓';
      case WishlistSort.name:
        return l10n.localeName == 'vi' ? 'Tên A-Z' : 'Name A-Z';
    }
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.softTaupe.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                AppLocalizations.of(context)!.localeName == 'vi'
                    ? 'SẮP XẾP THEO' : 'SORT BY',
                style: GoogleFonts.montserrat(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppTheme.deepCharcoal.withValues(alpha: 0.6),
                ),
              ),
            ),
            ...WishlistSort.values.map((s) => ListTile(
              onTap: () {
                setState(() => _sort = s);
                Navigator.pop(ctx);
              },
              title: Text(
                _sortLabel(s),
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: _sort == s ? FontWeight.w600 : FontWeight.w400,
                  color: _sort == s ? AppTheme.accentGold : AppTheme.deepCharcoal,
                ),
              ),
              trailing: _sort == s
                  ? const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 20)
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 32),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _addToCart(Product product) {
    if (product.variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.localeName == 'vi'
                ? 'Sản phẩm chưa có phiên bản'
                : 'No variant available',
            style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppTheme.deepCharcoal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final variantId = product.variants.first.id;
    ref.read(cartProvider.notifier).addItemByVariant(variantId);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppTheme.accentGold, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.localeName == 'vi'
                    ? 'Đã thêm vào giỏ hàng'
                    : 'Added to cart',
                style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.deepCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _removeWithUndo(Product product) {
    ref.read(wishlistProvider.notifier).toggle(product);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white70, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.localeName == 'vi'
                    ? 'Đã xóa khỏi yêu thích'
                    : 'Removed from wishlist',
                style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.localeName == 'vi' ? 'HOÀN TÁC' : 'UNDO',
          textColor: AppTheme.accentGold,
          onPressed: () {
            ref.read(wishlistProvider.notifier).toggle(product);
          },
        ),
        backgroundColor: AppTheme.deepCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: SafeArea(
        child: AppAsyncWidget(
          value: ref.watch(wishlistProvider),
          onRetry: () => ref.invalidate(wishlistProvider),
          loadingBuilder: () => SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(l10n, 0),
                ShimmerProductGrid(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                ),
              ],
            ),
          ),
          dataBuilder: (wishlist) {
            if (wishlist.isEmpty) return _buildEmptyState(l10n);
            final sorted = _sortProducts(wishlist);
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(l10n, wishlist.length)),
                SliverToBoxAdapter(child: _buildToolbar(l10n)),
                if (_viewMode == WishlistView.grid)
                  _buildGridView(sorted)
                else
                  _buildListView(sorted),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, int count) {
    return FadeTransition(
      opacity: _entryController,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: AppTheme.deepCharcoal),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.wishlistTitle.toUpperCase(),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20, fontWeight: FontWeight.w700,
                      letterSpacing: 1.5, color: AppTheme.deepCharcoal,
                    ),
                  ),
                  if (count > 0)
                    Text(
                      l10n.localeName == 'vi'
                          ? '$count sản phẩm'
                          : '$count ${count == 1 ? 'item' : 'items'}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12, fontWeight: FontWeight.w500,
                        color: AppTheme.mutedSilver,
                      ),
                    ),
                ],
              ),
            ),
            // Animated heart icon
            _PulsingHeart(),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Sort button
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6, offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_vert_rounded, size: 16, color: AppTheme.accentGold),
                  const SizedBox(width: 6),
                  Text(
                    _sortLabel(_sort),
                    style: GoogleFonts.montserrat(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppTheme.deepCharcoal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // View toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.softTaupe.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ViewToggleButton(
                  icon: Icons.grid_view_rounded,
                  isActive: _viewMode == WishlistView.grid,
                  onTap: () => setState(() => _viewMode = WishlistView.grid),
                ),
                _ViewToggleButton(
                  icon: Icons.view_list_rounded,
                  isActive: _viewMode == WishlistView.list,
                  onTap: () => setState(() => _viewMode = WishlistView.list),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Product> products) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.49,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return _AnimatedEntry(
              index: index,
              child: ProductCard(
                product: product,
                variant: ProductCardVariant.grid,
                isFavorite: true,
                onTap: () => context.push('/product/${product.id}'),
                onFavoriteToggle: () => _removeWithUndo(product),
              ),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildListView(List<Product> products) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return _AnimatedEntry(
              index: index,
              child: Dismissible(
                key: ValueKey(product.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _removeWithUndo(product),
                background: Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade300.withValues(alpha: 0.0),
                        Colors.red.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline_rounded,
                          color: Colors.white, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.localeName == 'vi'
                            ? 'Xóa' : 'Remove',
                        style: GoogleFonts.montserrat(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                child: _WishlistListTile(
                  product: product,
                  onTap: () => context.push('/product/${product.id}'),
                  onAddToCart: () => _addToCart(product),
                  onRemove: () => _removeWithUndo(product),
                ),
              ),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return FadeTransition(
      opacity: _entryController,
      child: Column(
        children: [
          _buildHeader(l10n, 0),
          Expanded(
            child: EmptyStateWidget(
              icon: Icons.favorite_border,
              title: l10n.wishlistEmptyTitle,
              subtitle: l10n.wishlistEmptySubtitle,
              action: LuxuryButton(
                text: l10n.exploreFragrances,
                onPressed: () => context.go('/explore'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Entry ───────────────────────────────────────────────
class _AnimatedEntry extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedEntry({required this.index, required this.child});

  @override
  State<_AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<_AnimatedEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─── Wishlist List Tile ───────────────────────────────────────────
class _WishlistListTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onRemove;

  const _WishlistListTile({
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                product.imageUrl,
                width: 80, height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80, height: 80,
                  color: AppTheme.ivoryBackground,
                  child: const Icon(Icons.image_outlined,
                      size: 28, color: AppTheme.mutedSilver),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 9, fontWeight: FontWeight.w800,
                      letterSpacing: 1.4, color: AppTheme.deepCharcoal,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: AppTheme.deepCharcoal, height: 1.2,
                    ),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${_formatPrice(product.price)}₫',
                        style: GoogleFonts.montserrat(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: AppTheme.deepCharcoal,
                        ),
                      ),
                      if (product.rating != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.star, size: 11, color: AppTheme.accentGold),
                        const SizedBox(width: 2),
                        Text(
                          product.rating!.toStringAsFixed(1),
                          style: GoogleFonts.montserrat(
                            fontSize: 10, fontWeight: FontWeight.w500,
                            color: AppTheme.mutedSilver,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Action buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add to cart button
                GestureDetector(
                  onTap: onAddToCart,
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.3),
                          blurRadius: 8, offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.shopping_bag_outlined,
                        size: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                // Remove button
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.ivoryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Icon(Icons.favorite_rounded,
                        size: 18, color: Colors.red.shade400),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    final str = intPrice.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ─── View Toggle Button ───────────────────────────────────────────
class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.accentGold.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon, size: 20,
          color: isActive ? AppTheme.accentGold : AppTheme.mutedSilver,
        ),
      ),
    );
  }
}

// ─── Pulsing Heart Icon ───────────────────────────────────────────
class _PulsingHeart extends StatefulWidget {
  @override
  State<_PulsingHeart> createState() => _PulsingHeartState();
}

class _PulsingHeartState extends State<_PulsingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.accentGold.withValues(alpha: 0.15),
              AppTheme.accentGold.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentGold.withValues(alpha: 0.08),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.favorite_rounded,
            size: 22, color: AppTheme.accentGold),
      ),
    );
  }
}
