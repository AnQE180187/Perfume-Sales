import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/banners/services/banner_service.dart';
import '../../../../core/widgets/tappable_card.dart';
import '../../../../core/widgets/custom_shimmer.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Actions
          Row(
            children: [
              Builder(
                builder: (context) => _IconButton(
                  icon: Icons.menu,
                  onTap: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const Spacer(),
              _IconButton(
                icon: Icons.favorite_border,
                onTap: () => context.push('/wishlist'),
              ),
              const SizedBox(width: 12),
              _IconButton(
                icon: Icons.shopping_bag_outlined,
                onTap: () => context.push('/cart'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search Bar - Upgraded to Hero & TappableCard
          Hero(
            tag: 'search_bar_hero',
            child: Material(
              color: Colors.transparent,
              child: TappableCard(
                onTap: () => context.push('/search'),
                scaleDownFactor: 0.98,
                borderRadius: BorderRadius.circular(28),
                useGlassmorphism: true,
                glassOpacity: 0.98,
                backgroundColor: AppTheme.creamWhite,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepCharcoal.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    blurRadius: 8,
                    offset: Offset(-2, -2),
                  ),
                ],
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: AppTheme.mutedSilver.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.searchExploreHintHome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.mutedSilver.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Banners (fetched from backend) - Upgraded with Shimmer & Glassmorphism
          const BannerCarousel(),
          const SizedBox(height: 20),

          // Headline
          RichText(
            text: TextSpan(
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                height: 1.3,
                color: AppTheme.deepCharcoal,
              ),
              children: [
                TextSpan(text: l10n.headlineElevate),
                TextSpan(
                  text: l10n.headlineSignature,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.accentGold,
                  ),
                ),
                TextSpan(text: l10n.headlineUniqueScent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TappableCard(
      onTap: onTap,
      scaleDownFactor: 0.85,
      borderRadius: BorderRadius.circular(16),
      useGlassmorphism: true,
      glassOpacity: 0.7,
      backgroundColor: Colors.white,
      boxShadow: [
        BoxShadow(
          color: AppTheme.deepCharcoal.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(2, 2),
        ),
      ],
      padding: const EdgeInsets.all(10),
      child: Icon(icon, color: AppTheme.deepCharcoal, size: 22),
    );
  }
}

class BannerCarousel extends ConsumerStatefulWidget {
  const BannerCarousel({super.key});

  @override
  ConsumerState<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<BannerCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _current = 0;

  static const _autoPlaySeconds = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: _autoPlaySeconds), (_) {
      final bannersAsync = ref.read(bannersProvider);
      final count = bannersAsync.asData?.value.length ?? 0;
      if (count == 0) return;
      final next = (_current + 1) % count;
      if (mounted && _pageController.hasClients) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
        setState(() => _current = next);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _placeholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.creamWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          color: AppTheme.mutedSilver,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(bannersProvider);
    return bannersAsync.when(
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();
        final height = 185.0;
        return SizedBox(
          height: height + 20, // Extra space for dots
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: banners.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (context, index) {
                    final b = banners[index];
                    return TappableCard(
                      onTap: () {
                        if (b.linkUrl != null && b.linkUrl!.startsWith('/')) {
                          context.push(b.linkUrl!);
                        }
                      },
                      scaleDownFactor: 0.96,
                      margin: const EdgeInsets.only(right: 14, bottom: 8, top: 4),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepCharcoal.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image with Shimmer loading fallback
                            Image.network(
                              b.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const CustomShimmer(
                                  width: double.infinity,
                                  height: double.infinity,
                                );
                              },
                              errorBuilder: (_, __, ___) => _placeholder(
                                MediaQuery.of(context).size.width * 0.85,
                                height,
                              ),
                            ),

                            // Glassmorphism overlay + title/subtitle
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(24),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.35),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (b.title != null && b.title!.isNotEmpty)
                                          Text(
                                            b.title!,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        if (b.subtitle != null && b.subtitle!.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            b.subtitle!,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Animated Dots
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(banners.length, (i) {
                  final selected = i == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCirc,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.accentGold
                          : AppTheme.mutedSilver.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      // Subtle glow for active dot
                      boxShadow: selected ? [
                        BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ] : null,
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: CustomShimmer(width: double.infinity, height: 185),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
