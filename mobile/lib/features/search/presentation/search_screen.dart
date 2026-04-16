import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../../core/widgets/product_card.dart';
import 'package:go_router/go_router.dart';
import '../../product/models/product.dart';
import '../providers/search_provider.dart';
import 'widgets/search_header.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialScent;
  const SearchScreen({super.key, this.initialScent});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Client-side filter state (scent/occasion/price are UI-only filters)
  String? _selectedScent;
  String? _selectedOccasion;
  String? _selectedPrice;

  static const _scentOptions = [
    'Woody',
    'Floral',
    'Fresh',
    'Sweet',
    'Spicy',
    'Gourmand',
    'Citrus',
    'Musk',
    'Amber',
  ];
  static const _occasionOptions = ['Daily', 'Office', 'Date', 'Party'];
  static const _priceOptions = ['<1M', '1-3M', '>3M'];

  bool get _hasActiveFilters {
    final state = ref.read(searchProvider);
    return state.scentFamily != null ||
        state.occasion != null ||
        state.priceRange != null;
  }

  @override
  void initState() {
    super.initState();
    // Initialize filter from widget if provided
    if (widget.initialScent != null) {
      // Normalize: find match in options (case-insensitive)
      final match = _scentOptions.firstWhere(
        (o) => o.toLowerCase() == widget.initialScent!.toLowerCase(),
        orElse: () => widget.initialScent!,
      );
      Future.microtask(() => ref.read(searchProvider.notifier).setScentFamily(match));
    }

    // Load initial products through the provider
    Future.microtask(() => ref.read(searchProvider.notifier).loadInitial());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() => ref.read(searchProvider.notifier).clearFilters();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final searchState = ref.watch(searchProvider);
    final filteredResults = searchState.results;

    final selectedScent = searchState.scentFamily;
    final selectedOccasion = searchState.occasion;
    final selectedPrice = searchState.priceRange;

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Collapsing Header with Search Bar
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppTheme.ivoryBackground,
              elevation: 0,
              expandedHeight: 64,
              toolbarHeight: 64,
              flexibleSpace: FlexibleSpaceBar(
                background: SearchHeader(
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(searchProvider.notifier).search(value);
                  },
                  onClear: () {
                    _searchController.clear();
                    ref.read(searchProvider.notifier).loadInitial();
                  },
                  onBack: () => Navigator.pop(context),
                  showClearButton: _searchController.text.isNotEmpty,
                ),
              ),
            ),

            // Compact Filter Sections
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FilterSection(
                    title: l10n.scentFamily,
                    options: _scentOptions,
                    selected: selectedScent,
                    onSelect: (v) => ref.read(searchProvider.notifier).setScentFamily(v),
                  ),
                  _buildDivider(),
                  _FilterSection(
                    title: l10n.usageOccasion,
                    options: _occasionOptions,
                    selected: selectedOccasion,
                    onSelect: (v) => ref.read(searchProvider.notifier).setOccasion(v),
                  ),
                  _buildDivider(),
                  _FilterSection(
                    title: l10n.priceRange,
                    options: _priceOptions,
                    selected: selectedPrice,
                    onSelect: (v) => ref.read(searchProvider.notifier).setPriceRange(v),
                  ),
                  const SizedBox(height: 12),
                  
                  // Results Title & Summary
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  _searchController.text.isEmpty
                                      ? l10n.featuredScents
                                      : l10n.searchResults,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.deepCharcoal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (!searchState.isLoading)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    '(${filteredResults.length} ${l10n.productsFound})',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.mutedSilver,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_hasActiveFilters) ...[
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _clearFilters,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                l10n.clearFilter,
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.accentGold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Results Grid
            if (searchState.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.accentGold),
                ),
              )
            else if (searchState.error != null)
              SliverFillRemaining(
                child: _buildErrorState(searchState.error!),
              )
            else if (filteredResults.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.52,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 20,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = filteredResults[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push('/product/${product.id}'),
                      );
                    },
                    childCount: filteredResults.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        color: AppTheme.softTaupe.withValues(alpha: 0.2),
        thickness: 0.8,
        height: 1,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.mutedSilver),
          const SizedBox(height: 12),
          Text(error, style: GoogleFonts.montserrat(fontSize: 13, color: AppTheme.mutedSilver)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => ref.read(searchProvider.notifier).loadInitial(),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppTheme.mutedSilver.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.noProductsFound, style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.mutedSilver)),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _FilterSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppTheme.deepCharcoal.withValues(alpha: 0.4),
            ),
          ),
        ),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final option = options[index];
              final isSelected = option == selected;
              return GestureDetector(
                onTap: () => onSelect(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentGold : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accentGold
                          : AppTheme.softTaupe.withValues(alpha: 0.3),
                      width: 0.6,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.accentGold.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    option,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : AppTheme.deepCharcoal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
