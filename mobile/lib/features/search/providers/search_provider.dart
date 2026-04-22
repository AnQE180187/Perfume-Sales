import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../product/data/product_repository.dart';
import '../../product/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchState {
  final String query;
  final int? categoryId;
  final String? categoryName;
  final int? scentFamilyId;
  final int? brandId;
  final String? brandName;
  final String? scentFamily;
  final String? selectedNote;
  final String? priceRange;
  final List<Product> results;
  final bool isLoading;
  final String? error;
  final String sortBy; // 'newest', 'price_asc', 'price_desc', 'rating'
  final String viewMode; // 'grid', 'list'
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  const SearchState({
    this.query = '',
    this.categoryId,
    this.categoryName,
    this.scentFamilyId,
    this.brandId,
    this.brandName,
    this.scentFamily,
    this.selectedNote,
    this.priceRange,
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.sortBy = 'newest',
    this.viewMode = 'grid',
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  SearchState copyWith({
    String? query,
    int? categoryId,
    String? categoryName,
    bool clearCategory = false,
    int? scentFamilyId,
    bool clearScentFamily = false,
    String? scentFamily,
    String? selectedNote,
    bool clearNote = false,
    int? brandId,
    String? brandName,
    bool clearBrand = false,
    String? priceRange,
    bool clearPriceRange = false,
    List<Product>? results,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? sortBy,
    String? viewMode,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return SearchState(
      query: query ?? this.query,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      categoryName: clearCategory ? null : (categoryName ?? this.categoryName),
      scentFamilyId:
          clearScentFamily ? null : (scentFamilyId ?? this.scentFamilyId),
      scentFamily: clearScentFamily ? null : (scentFamily ?? this.scentFamily),
      selectedNote: clearNote ? null : (selectedNote ?? this.selectedNote),
      brandId: clearBrand ? null : (brandId ?? this.brandId),
      brandName: clearBrand ? null : (brandName ?? this.brandName),
      priceRange: clearPriceRange ? null : (priceRange ?? this.priceRange),
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      sortBy: sortBy ?? this.sortBy,
      viewMode: viewMode ?? this.viewMode,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final ProductRepository _repository;

  SearchNotifier(this._repository) : super(const SearchState());

  Future<void> search(String query) async {
    state = state.copyWith(query: query, isLoading: true, clearError: true);
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final results = await _repository.getProducts(
        search: state.query.isEmpty ? null : state.query,
        categoryId: state.categoryId,
        scentFamilyId: state.scentFamilyId,
        brandId: state.brandId,
        notes: state.selectedNote,
        minPrice: _getMinPrice(state.priceRange),
        maxPrice: _getMaxPrice(state.priceRange),
        skip: 0,
        take: 20,
      );

      // Apply sorting on results
      List<Product> sortedResults = List.from(results);
      _applySort(sortedResults);

      state = state.copyWith(
        results: sortedResults, 
        isLoading: false,
        hasMore: results.length == 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tìm kiếm. Vui lòng thử lại.',
      );
    }
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true, page: 1, hasMore: true);
    await _fetch();
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;
    
    try {
      final results = await _repository.getProducts(
        skip: (nextPage - 1) * 20,
        take: 20,
        categoryId: state.categoryId,
        scentFamilyId: state.scentFamilyId,
        brandId: state.brandId,
        search: state.query,
        notes: state.selectedNote,
        minPrice: _getMinPrice(state.priceRange),
        maxPrice: _getMaxPrice(state.priceRange),
      );

      if (results.isEmpty) {
        state = state.copyWith(isLoadingMore: false, hasMore: false);
      } else {
        // Apply sorting on new results
        List<Product> newResults = List.from(state.results)..addAll(results);
        _applySort(newResults);
        
        state = state.copyWith(
          results: newResults,
          isLoadingMore: false,
          page: nextPage,
          hasMore: results.length == 20,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void _applySort(List<Product> results) {
    if (state.sortBy == 'price_asc') {
      results.sort((a, b) => a.price.compareTo(b.price));
    } else if (state.sortBy == 'price_desc') {
      results.sort((a, b) => b.price.compareTo(a.price));
    } else if (state.sortBy == 'rating') {
      results.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    }
  }

  int? _getMinPrice(String? range) {
    if (range == '1-3M') return 1000000;
    if (range == '>3M') return 3000000;
    return null;
  }

  int? _getMaxPrice(String? range) {
    if (range == '<1M') return 1000000;
    if (range == '1-3M') return 3000000;
    return null;
  }

  void reset() {
    state = SearchState(viewMode: state.viewMode, sortBy: state.sortBy);
    _fetch();
  }

  void setScentFamily(String? scent, {int? id}) {
    if (scent == state.scentFamily) {
      state = state.copyWith(clearScentFamily: true);
    } else {
      state = state.copyWith(scentFamily: scent, scentFamilyId: id);
    }
    _fetch();
  }

  void setNote(String? note) {
    if (note == state.selectedNote) {
      state = state.copyWith(clearNote: true);
    } else {
      state = state.copyWith(selectedNote: note);
    }
    _fetch();
  }

  void setBrand(String? brand, {int? id}) {
    if (id == state.brandId) {
      state = state.copyWith(clearBrand: true);
    } else {
      state = state.copyWith(brandId: id, brandName: brand);
    }
    _fetch();
  }

  void setPriceRange(String? range) {
    if (range == state.priceRange) {
      state = state.copyWith(clearPriceRange: true);
    } else {
      state = state.copyWith(priceRange: range);
    }
    _fetch();
  }

  void setCategory(String? name, {int? id}) {
    if (id == state.categoryId) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categoryId: id, categoryName: name);
    }
    _fetch();
  }

  void clearFilters() {
    state = SearchState(query: state.query, results: state.results, viewMode: state.viewMode, sortBy: state.sortBy);
    _fetch();
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
    _fetch();
  }

  void setViewMode(String mode) {
    state = state.copyWith(viewMode: mode);
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  final repository = ref.watch(productRepositoryProvider);
  return SearchNotifier(repository);
});

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
      return RecentSearchesNotifier();
    });

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  static const _key = 'recent_searches';

  RecentSearchesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_key) ?? [];
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state);
  }

  void add(String query) {
    if (query.trim().isEmpty) return;
    final trimmed = query.trim();
    List<String> newList = [trimmed, ...state.where((q) => q != trimmed)].take(10).toList();
    state = newList;
    _save();
  }

  void remove(String query) {
    state = state.where((q) => q != query).toList();
    _save();
  }

  void clear() {
    state = [];
    _save();
  }
}
