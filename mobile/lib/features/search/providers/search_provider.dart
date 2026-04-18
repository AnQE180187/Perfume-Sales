import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../product/data/product_repository.dart';
import '../../product/models/product.dart';

class SearchState {
  final String query;
  final int? categoryId;
  final int? scentFamilyId;
  final int? brandId;
  final String? brandName;
  final String? scentFamily;
  final String? occasion;
  final String? priceRange;
  final List<Product> results;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.query = '',
    this.categoryId,
    this.scentFamilyId,
    this.brandId,
    this.brandName,
    this.scentFamily,
    this.occasion,
    this.priceRange,
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    int? categoryId,
    bool clearCategory = false,
    int? scentFamilyId,
    bool clearScentFamily = false,
    String? scentFamily,
    int? brandId,
    String? brandName,
    bool clearBrand = false,
    String? occasion,
    bool clearOccasion = false,
    String? priceRange,
    bool clearPriceRange = false,
    List<Product>? results,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      scentFamilyId:
          clearScentFamily ? null : (scentFamilyId ?? this.scentFamilyId),
      scentFamily: clearScentFamily ? null : (scentFamily ?? this.scentFamily),
      brandId: clearBrand ? null : (brandId ?? this.brandId),
      brandName: clearBrand ? null : (brandName ?? this.brandName),
      occasion: clearOccasion ? null : (occasion ?? this.occasion),
      priceRange: clearPriceRange ? null : (priceRange ?? this.priceRange),
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
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
    int? minPrice;
    int? maxPrice;

    if (state.priceRange == '<1M') {
      maxPrice = 1000000;
    } else if (state.priceRange == '1-3M') {
      minPrice = 1000000;
      maxPrice = 3000000;
    } else if (state.priceRange == '>3M') {
      minPrice = 3000000;
    }

    try {
      final results = await _repository.getProducts(
        search: state.query.isEmpty ? null : state.query,
        categoryId: state.categoryId,
        scentFamilyId: state.scentFamilyId,
        brandId: state.brandId,
        notes: state.scentFamily,
        occasion: state.occasion,
        minPrice: minPrice,
        maxPrice: maxPrice,
        take: 50,
      );
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tìm kiếm. Vui lòng thử lại.',
      );
    }
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _fetch();
  }

  void setScentFamily(String? scent, {int? id}) {
    if (scent == state.scentFamily) {
      state = state.copyWith(clearScentFamily: true);
    } else {
      state = state.copyWith(scentFamily: scent, scentFamilyId: id);
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

  void setOccasion(String? occasion) {
    if (occasion == state.occasion) {
      state = state.copyWith(clearOccasion: true);
    } else {
      state = state.copyWith(occasion: occasion);
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

  void setCategory(int? categoryId) {
    if (categoryId == state.categoryId) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categoryId: categoryId);
    }
    _fetch();
  }

  void clearFilters() {
    state = SearchState(query: state.query, results: state.results);
    _fetch();
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
  RecentSearchesNotifier() : super([]);

  void add(String query) {
    if (query.isEmpty) return;
    if (!state.contains(query)) {
      state = [query, ...state].take(5).toList();
    }
  }

  void remove(String query) {
    state = state.where((q) => q != query).toList();
  }

  void clear() {
    state = [];
  }
}
