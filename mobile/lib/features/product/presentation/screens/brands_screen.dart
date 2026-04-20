import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/brands_provider.dart';

class BrandsScreen extends ConsumerWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(brandsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.ivoryBackground,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                l10n.brand.toUpperCase(),
                style: GoogleFonts.playfairDisplay(
                  color: AppTheme.deepCharcoal,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  fontSize: 16,
                ),
              ),
              background: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.champagneGold.withValues(alpha: 0.15),
                            AppTheme.ivoryBackground,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 1,
                        color: AppTheme.accentGold.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          brandsAsync.when(
            data: (brands) {
              // Group brands by first letter
              final Map<String, List<dynamic>> groupedBrands = {};
              for (final brand in brands) {
                final firstLetter = brand.name[0].toUpperCase();
                groupedBrands.putIfAbsent(firstLetter, () => []).add(brand);
              }
              final sortedKeys = groupedBrands.keys.toList()..sort();

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final key = sortedKeys[index];
                      final brandsInGroup = groupedBrands[key]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 40, 0, 16),
                            child: Row(
                              children: [
                                Text(
                                  key,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.accentGold.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    height: 0.5,
                                    color: AppTheme.softTaupe.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...brandsInGroup.map((brand) => _BrandTile(brand: brand)),
                        ],
                      );
                    },
                    childCount: sortedKeys.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.accentGold, strokeWidth: 2)),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandTile extends StatelessWidget {
  final dynamic brand;
  const _BrandTile({required this.brand});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final encodedBrand = Uri.encodeComponent(brand.name);
        context.push('/search?brand=$encodedBrand&brandId=${brand.id}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brand.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.deepCharcoal.withValues(alpha: 0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (brand.description != null && brand.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      brand.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: AppTheme.mutedSilver.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppTheme.mutedSilver.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
