import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'package:perfume_gpt_app/l10n/app_localizations.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import 'package:go_router/go_router.dart';
import '../../product/models/product.dart';
import '../../scent/data/scent_repository.dart';
import '../../product/data/product_repository.dart';
import '../../scent/models/scent_family.dart';
import '../../product/models/brand.dart';
import '../../product/models/category.dart';
import '../providers/search_provider.dart';
import 'widgets/search_header.dart';
import '../../cart/providers/cart_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

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
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

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
    _initSpeech();
    _scrollController.addListener(_onScroll);
    
    bool hasInitial = widget.initialScent != null ||
        widget.initialBrand != null ||
        widget.initialNote != null;

    if (!hasInitial) {
      Future.microtask(() => ref.read(searchProvider.notifier).reset());
    } else {
      if (widget.initialScent != null) {
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
      Future.microtask(() => ref.read(searchProvider.notifier).loadInitial());
    }
    
    Future.microtask(() => ref.read(scentFamiliesProvider.future));
  }

  void _initSpeech() async {
    await _speech.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchProvider.notifier).loadMore();
    }
  }

  void _clearFilters() => ref.read(searchProvider.notifier).clearFilters();

  Future<void> _startListening() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (!status.isGranted) return;
    }

    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _searchController.text = result.recognizedWords;
              if (result.finalResult) {
                _isListening = false;
                ref.read(searchProvider.notifier).search(result.recognizedWords);
                ref.read(recentSearchesProvider.notifier).add(result.recognizedWords);
              }
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _onSearch(String value) {
    ref.read(searchProvider.notifier).search(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final searchState = ref.watch(searchProvider);
    final recentSearches = ref.watch(recentSearchesProvider);
    final wishlist = ref.watch(wishlistProvider).valueOrNull ?? [];
    
    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: SafeArea(
        child: Column(
          children: [
            SearchHeader(
              controller: _searchController,
              onChanged: _onSearch,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  ref.read(recentSearchesProvider.notifier).add(value);
                }
              },
              onClear: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).loadInitial();
              },
              onBack: () => Navigator.pop(context),
              onVoiceSearch: _startListening,
              showClearButton: _searchController.text.isNotEmpty,
            ),
            
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _buildFilterBar(l10n, searchState)),
                  if (_searchController.text.isEmpty && !_hasActiveFilters)
                    SliverToBoxAdapter(child: _buildInitialView(l10n, recentSearches)),
                  SliverToBoxAdapter(child: _buildResultInfo(l10n, searchState)),
                  _buildResults(searchState, l10n, wishlist),
                  if (searchState.isLoadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: searchState.viewMode == 'grid' 
                          ? const ShimmerProductGrid(itemCount: 2)
                          : const ShimmerProductList(itemCount: 1),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _isListening ? _buildListeningOverlay() : null,
    );
  }

  Widget _buildInitialView(AppLocalizations l10n, List<String> recentSearches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recentSearches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.localeName == 'vi' ? 'TÌM KIẾM GẦN ĐÂY' : 'RECENT SEARCHES',
                  style: GoogleFonts.montserrat(
                    fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2,
                    color: AppTheme.deepCharcoal.withOpacity(0.5),
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(recentSearchesProvider.notifier).clear(),
                  child: Text(
                    l10n.localeName == 'vi' ? 'Xóa hết' : 'Clear all',
                    style: GoogleFonts.montserrat(
                      fontSize: 12, color: AppTheme.accentGold, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: recentSearches.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final query = recentSearches[index];
                return _SearchChip(
                  label: query,
                  onTap: () {
                    _searchController.text = query;
                    _onSearch(query);
                  },
                  onDelete: () => ref.read(recentSearchesProvider.notifier).remove(query),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterBar(AppLocalizations l10n, SearchState state) {
    final scentFamiliesAsync = ref.watch(scentFamiliesProvider);
    final brandsAsync = ref.watch(brandsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final scentNotesAsync = ref.watch(scentNotesProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _DropdownChip(
            label: state.brandName ?? l10n.brand,
            isSelected: state.brandName != null,
            onTap: () {
              final brands = brandsAsync.maybeWhen(data: (d) => d, orElse: () => <Brand>[]);
              _showFilterPicker(context, title: l10n.brand, options: brands.map((b) => b.name).toList(),
                selected: state.brandName, onSelect: (name) {
                  final b = brands.firstWhere((b) => b.name == name);
                  ref.read(searchProvider.notifier).setBrand(b.name, id: b.id);
                }, isLoading: brandsAsync.isLoading);
            },
          ),
          const SizedBox(width: 10),
          _DropdownChip(
            label: state.scentFamily ?? l10n.scentFamily,
            isSelected: state.scentFamily != null,
            onTap: () {
              final families = scentFamiliesAsync.maybeWhen(data: (d) => d, orElse: () => <ScentFamily>[]);
              _showFilterPicker(context, title: l10n.scentFamily, options: families.map((f) => f.name).toList(),
                selected: state.scentFamily, onSelect: (name) {
                  final f = families.firstWhere((f) => f.name == name);
                  ref.read(searchProvider.notifier).setScentFamily(f.name, id: f.id);
                }, isLoading: scentFamiliesAsync.isLoading);
            },
          ),
          const SizedBox(width: 10),
          _DropdownChip(
            label: state.selectedNote ?? l10n.scentNotes,
            isSelected: state.selectedNote != null,
            onTap: () {
              final notes = scentNotesAsync.maybeWhen(data: (d) => d, orElse: () => <String>[]);
              _showFilterPicker(context, title: l10n.scentNotes, options: notes,
                selected: state.selectedNote, onSelect: (v) => ref.read(searchProvider.notifier).setNote(v),
                isLoading: scentNotesAsync.isLoading);
            },
          ),
          const SizedBox(width: 10),
          _DropdownChip(
            label: state.categoryName ?? l10n.category,
            isSelected: state.categoryName != null,
            onTap: () {
              final cats = categoriesAsync.maybeWhen(data: (d) => d, orElse: () => <Category>[]);
              _showFilterPicker(context, title: l10n.category, options: cats.map((c) => c.name).toList(),
                selected: state.categoryName, onSelect: (name) {
                  final c = cats.firstWhere((c) => c.name == name);
                  ref.read(searchProvider.notifier).setCategory(c.name, id: c.id);
                }, isLoading: categoriesAsync.isLoading);
            },
          ),
          const SizedBox(width: 10),
          _DropdownChip(
            label: state.priceRange ?? l10n.priceRange,
            isSelected: state.priceRange != null,
            onTap: () => _showFilterPicker(context, title: l10n.priceRange, options: _priceOptions,
              selected: state.priceRange, onSelect: (v) => ref.read(searchProvider.notifier).setPriceRange(v)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultInfo(AppLocalizations l10n, SearchState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                state.results.length.toString(),
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: AppTheme.deepCharcoal),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.productsFound,
                style: GoogleFonts.montserrat(color: AppTheme.mutedSilver, fontSize: 13),
              ),
              const Spacer(),
              _SortButton(
                currentSort: state.sortBy,
                onSortChanged: (val) => ref.read(searchProvider.notifier).setSortBy(val),
              ),
              const SizedBox(width: 12),
              _ViewModeToggle(
                mode: state.viewMode,
                onChanged: (val) => ref.read(searchProvider.notifier).setViewMode(val),
              ),
            ],
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.filter_list_rounded, size: 14, color: AppTheme.accentGold),
                const SizedBox(width: 6),
                Text(
                  l10n.localeName == 'vi' ? 'Đã áp dụng bộ lọc' : 'Filters applied',
                  style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.accentGold),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _clearFilters,
                  child: Text(
                    l10n.clearFilter,
                    style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.accentGold, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResults(SearchState state, AppLocalizations l10n, List<Product> wishlist) {
    if (state.isLoading) {
      return SliverToBoxAdapter(
        child: state.viewMode == 'grid' 
          ? const ShimmerProductGrid(padding: EdgeInsets.symmetric(horizontal: 20))
          : const ShimmerProductList(padding: EdgeInsets.symmetric(horizontal: 20)),
      );
    }
    
    if (state.error != null) {
      return SliverFillRemaining(child: _buildErrorState(state.error!));
    }
    
    if (state.results.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    if (state.viewMode == 'grid') {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.49, crossAxisSpacing: 18, mainAxisSpacing: 20,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = state.results[index];
              final isFavorite = wishlist.any((p) => p.id == product.id);
              return ProductCard(
                product: product,
                isFavorite: isFavorite,
                onFavoriteToggle: () => ref.read(wishlistProvider.notifier).toggle(product),
                onTap: () => context.push('/product/${product.id}'),
              );
            },
            childCount: state.results.length,
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = state.results[index];
              final isFavorite = wishlist.any((p) => p.id == product.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ProductCard(
                  product: product,
                  variant: ProductCardVariant.list,
                  isFavorite: isFavorite,
                  onFavoriteToggle: () => ref.read(wishlistProvider.notifier).toggle(product),
                  onTap: () => context.push('/product/${product.id}'),
                  onAdd: () {
                    if (product.variants.isNotEmpty) {
                      ref.read(cartProvider.notifier).addItemByVariant(product.variants.first.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.localeName == 'vi' ? 'Đã thêm vào giỏ hàng' : 'Added to cart'),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: l10n.localeName == 'vi' ? 'XEM' : 'VIEW',
                            onPressed: () => context.push('/cart'),
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
            childCount: state.results.length,
          ),
        ),
      );
    }
  }

  Widget _buildListeningOverlay() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mic_rounded, size: 48, color: AppTheme.accentGold),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.localeName == 'vi' ? 'Đang lắng nghe...' : 'Listening...',
            style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(_searchController.text, style: GoogleFonts.montserrat(color: AppTheme.mutedSilver)),
        ],
      ),
    );
  }

  void _showFilterPicker(BuildContext context, {required String title, required List<String> options,
    required String? selected, required ValueChanged<String> onSelect, bool isLoading = false}) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.softTaupe.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.all(20), child: Text(title.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppTheme.deepCharcoal.withOpacity(0.6)))),
        if (isLoading) const Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator(color: AppTheme.accentGold))
        else Flexible(child: ConstrainedBox(constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
          child: ListView.separated(shrinkWrap: true, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: options.length, separatorBuilder: (_, __) => Divider(color: AppTheme.softTaupe.withOpacity(0.1), height: 1),
            itemBuilder: (context, index) {
              final opt = options[index]; final isSel = opt == selected;
              return ListTile(onTap: () { onSelect(opt); Navigator.pop(context); },
                title: Text(opt, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: isSel ? FontWeight.w600 : FontWeight.w400, color: isSel ? AppTheme.accentGold : AppTheme.deepCharcoal)),
                trailing: isSel ? const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 20) : null);
            }))),
        const SizedBox(height: 12),
      ])));
  }

  Widget _buildErrorState(String error) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.error_outline, size: 48, color: AppTheme.mutedSilver), const SizedBox(height: 12),
    Text(error, style: GoogleFonts.montserrat(fontSize: 13, color: AppTheme.mutedSilver)), const SizedBox(height: 16),
    TextButton(onPressed: () => ref.read(searchProvider.notifier).loadInitial(), child: Text(AppLocalizations.of(context)!.retry))
  ]));

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.search_off_rounded, size: 64, color: AppTheme.mutedSilver.withValues(alpha: 0.4)), const SizedBox(height: 16),
    Text(AppLocalizations.of(context)!.noProductsFound, style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.mutedSilver))
  ]));
}

class _SearchChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  const _SearchChip({required this.label, required this.onTap, this.onDelete});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.softTaupe.withOpacity(0.5))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.deepCharcoal)),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            GestureDetector(onTap: onDelete, child: const Icon(Icons.close_rounded, size: 14, color: AppTheme.mutedSilver)),
          ],
        ]),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSortChanged;
  const _SortButton({required this.currentSort, required this.onSortChanged});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSortSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.softTaupe.withOpacity(0.5))),
        child: const Icon(Icons.swap_vert_rounded, size: 18, color: AppTheme.accentGold),
      ),
    );
  }
  void _showSortSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = {
      'newest': l10n.localeName == 'vi' ? 'Mới nhất' : 'Newest',
      'price_asc': l10n.localeName == 'vi' ? 'Giá thấp đến cao' : 'Price: Low to High',
      'price_desc': l10n.localeName == 'vi' ? 'Giá cao đến thấp' : 'Price: High to Low',
      'rating': l10n.localeName == 'vi' ? 'Đánh giá cao nhất' : 'Highest Rated',
    };
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        ...options.entries.map((e) => ListTile(onTap: () { onSortChanged(e.key); Navigator.pop(context); },
          title: Text(e.value, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: currentSort == e.key ? FontWeight.w600 : FontWeight.w400, color: currentSort == e.key ? AppTheme.accentGold : AppTheme.deepCharcoal)),
          trailing: currentSort == e.key ? const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 20) : null)),
        const SizedBox(height: 12),
      ])));
  }
}

class _ViewModeToggle extends StatelessWidget {
  final String mode;
  final ValueChanged<String> onChanged;
  const _ViewModeToggle({required this.mode, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.softTaupe.withOpacity(0.5))),
      child: Row(children: [
        _ToggleIcon(icon: Icons.grid_view_rounded, isActive: mode == 'grid', onTap: () => onChanged('grid')),
        _ToggleIcon(icon: Icons.view_list_rounded, isActive: mode == 'list', onTap: () => onChanged('list')),
      ]),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon; final bool isActive; final VoidCallback onTap;
  const _ToggleIcon({required this.icon, required this.isActive, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: isActive ? AppTheme.accentGold.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 18, color: isActive ? AppTheme.accentGold : AppTheme.mutedSilver)));
  }
}

class _DropdownChip extends StatelessWidget {
  final String label; final bool isSelected; final VoidCallback onTap;
  const _DropdownChip({required this.label, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 250), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: isSelected ? AppTheme.accentGold.withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? AppTheme.accentGold : AppTheme.softTaupe.withOpacity(0.5), width: 1)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? AppTheme.accentGold : AppTheme.deepCharcoal)),
        const SizedBox(width: 4),
        Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: isSelected ? AppTheme.accentGold : AppTheme.mutedSilver),
      ])));
  }
}
