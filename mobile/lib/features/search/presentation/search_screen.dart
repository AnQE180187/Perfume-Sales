import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../../core/widgets/product_card.dart';
import 'package:go_router/go_router.dart';
import '../../product/models/product.dart';
import '../../scent/data/scent_repository.dart';
import '../../product/data/product_repository.dart';
import '../../scent/models/scent_family.dart';
import '../../product/models/brand.dart';
import '../../product/models/category.dart';
import '../providers/search_provider.dart';
import 'widgets/search_header.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialScent;
  final int? initialScentId;
  final String? initialBrand;
  final int? initialBrandId;
  final String? initialNote;
  const SearchScreen({
    super.key,
    this.initialScent,
    this.initialScentId,
    this.initialBrand,
    this.initialBrandId,
    this.initialNote,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Client-side filter state (scent/occasion/price are UI-only filters)
  String? _selectedScent;
  String? _selectedCategory;
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

  static const _priceOptions = ['<1M', '1-3M', '>3M'];

  bool get _hasActiveFilters {
    final state = ref.read(searchProvider);
    return state.scentFamily != null ||
        state.selectedNote != null ||
        state.brandId != null ||
        state.categoryId != null ||
        state.priceRange != null;
  }

  @override
  void initState() {
    super.initState();
    // Initialize filter from widget if provided
    if (widget.initialScent != null) {
      _selectedScent = widget.initialScent;
      _searchController.text = widget.initialScent!;
      Future.microtask(() => ref.read(searchProvider.notifier).setScentFamily(
            widget.initialScent,
            id: widget.initialScentId,
          ));
    }

    if (widget.initialBrand != null) {
      Future.microtask(() => ref.read(searchProvider.notifier).setBrand(
            widget.initialBrand!,
            id: widget.initialBrandId,
          ));
    }

    if (widget.initialNote != null) {
      _searchController.text = widget.initialNote!;
      Future.microtask(
        () => ref.read(searchProvider.notifier).setNote(widget.initialNote),
      );
    }

    // Load initial products through the provider
    Future.microtask(() => ref.read(searchProvider.notifier).loadInitial());
    // Also ensure scent families are loaded
    Future.microtask(() => ref.read(scentFamiliesProvider.future));
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
    final scentFamiliesAsync = ref.watch(scentFamiliesProvider);
    final brandsAsync = ref.watch(brandsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final scentNotesAsync = ref.watch(scentNotesProvider);
    
    final filteredResults = searchState.results;

    final selectedBrand = searchState.brandName;
    final selectedScent = searchState.scentFamily;
    final selectedNote = searchState.selectedNote;
    final selectedCategory = searchState.categoryName;
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

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        _DropdownChip(
                          label: selectedBrand ?? l10n.brand,
                          isSelected: selectedBrand != null,
                          onTap: () {
                            final brands = brandsAsync.maybeWhen(
                              data: (data) => data,
                              orElse: () => <Brand>[],
                            );
                            _showFilterPicker(
                              context,
                              title: l10n.brand,
                              options: brands.map((b) => b.name).toList(),
                              selected: selectedBrand,
                              onSelect: (name) {
                                final b = brands.firstWhere((b) => b.name == name);
                                ref.read(searchProvider.notifier).setBrand(b.name, id: b.id);
                              },
                              isLoading: brandsAsync.isLoading,
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        _DropdownChip(
                          label: selectedScent ?? l10n.scentFamily,
                          isSelected: selectedScent != null,
                          onTap: () {
                            final dynamicScentOptions = scentFamiliesAsync.maybeWhen(
                              data: (families) => families,
                              orElse: () => _scentOptions.map((name) => ScentFamily(id: -1, name: name)).toList(),
                            );
                            _showFilterPicker(
                              context,
                              title: l10n.scentFamily,
                              options: dynamicScentOptions.map((f) => f.name).toList(),
                              selected: selectedScent,
                              onSelect: (name) {
                                final family = dynamicScentOptions.firstWhere((f) => f.name == name);
                                ref.read(searchProvider.notifier).setScentFamily(
                                      family.name,
                                      id: family.id == -1 ? null : family.id,
                                    );
                              },
                              isLoading: scentFamiliesAsync.isLoading,
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        _DropdownChip(
                          label: selectedNote ?? l10n.scentNotes,
                          isSelected: selectedNote != null,
                          onTap: () {
                            final notes = scentNotesAsync.maybeWhen(
                              data: (data) => data,
                              orElse: () => <String>[],
                            );
                            _showFilterPicker(
                              context,
                              title: l10n.scentNotes,
                              options: notes,
                              selected: selectedNote,
                              onSelect: (v) => ref.read(searchProvider.notifier).setNote(v),
                              isLoading: scentNotesAsync.isLoading,
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        _DropdownChip(
                          label: selectedCategory ?? l10n.category,
                          isSelected: selectedCategory != null,
                          onTap: () {
                            final categories = categoriesAsync.maybeWhen(
                              data: (data) => data,
                              orElse: () => <Category>[],
                            );
                            _showFilterPicker(
                              context,
                              title: l10n.category,
                              options: categories.map((c) => c.name).toList(),
                              selected: selectedCategory,
                              onSelect: (name) {
                                final c = categories.firstWhere((c) => c.name == name);
                                ref.read(searchProvider.notifier).setCategory(c.name, id: c.id);
                              },
                              isLoading: categoriesAsync.isLoading,
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        _DropdownChip(
                          label: selectedPrice ?? l10n.priceRange,
                          isSelected: selectedPrice != null,
                          onTap: () => _showFilterPicker(
                            context,
                            title: l10n.priceRange,
                            options: _priceOptions,
                            selected: selectedPrice,
                            onSelect: (v) => ref.read(searchProvider.notifier).setPriceRange(v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Results Title & Summary
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            _searchController.text.isEmpty
                                ? l10n.featuredScents
                                : l10n.searchResults,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.deepCharcoal,
                            ),
                          ),
                        ),
                        if (!searchState.isLoading) ...[
                          const SizedBox(width: 10),
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
                    childAspectRatio: 0.49,
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

  void _showFilterPicker(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelect,
    bool isLoading = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.softTaupe.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppTheme.deepCharcoal.withOpacity(0.6),
                  ),
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: AppTheme.accentGold),
                )
              else
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: options.length,
                      separatorBuilder: (_, __) => Divider(
                        color: AppTheme.softTaupe.withOpacity(0.1),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final isSelected = option == selected;
                        return ListTile(
                          onTap: () {
                            onSelect(option);
                            Navigator.pop(context);
                          },
                          title: Text(
                            option,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? AppTheme.accentGold : AppTheme.deepCharcoal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 20)
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
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

class _DropdownChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DropdownChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGold.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : AppTheme.softTaupe.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accentGold.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.accentGold : AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isSelected ? AppTheme.accentGold : AppTheme.mutedSilver,
            ),
          ],
        ),
      ),
    );
  }
}
