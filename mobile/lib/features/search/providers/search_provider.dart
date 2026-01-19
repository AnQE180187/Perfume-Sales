import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../product/models/product.dart';

// Mock data for search
final List<Product> _allProducts = [
  Product(
    id: 'prod_1',
    name: 'NOIR ÉLIXIR',
    brand: 'LUMINA',
    price: 280.0,
    imageUrl: 'https://images.unsplash.com/photo-1541643600914-78b084683601?q=80&w=1000&auto=format&fit=crop',
    description: 'A mysterious blend of dark woods and spiced amber.',
    rating: 4.8,
    reviews: 124,
    notes: ['Oud', 'Black Pepper', 'Amber'],
  ),
  Product(
    id: 'prod_2',
    name: 'ROSE POUDRÉE',
    brand: 'LUMINA',
    price: 240.0,
    imageUrl: 'https://images.unsplash.com/photo-1594035910387-fea4779426e9?q=80&w=1000&auto=format&fit=crop',
    description: 'Elegant powdery rose with a touch of vanilla.',
    rating: 4.9,
    reviews: 89,
    notes: ['Damask Rose', 'Vanilla', 'Iris'],
  ),
  Product(
    id: 'prod_3',
    name: 'VÉTIVER FRAÎCHE',
    brand: 'LUMINA',
    price: 210.0,
    imageUrl: 'https://images.unsplash.com/photo-1523293188086-b520e57197dd?q=80&w=1000&auto=format&fit=crop',
    description: 'Crisp citrus notes dancing over earthy vetiver.',
    rating: 4.7,
    reviews: 56,
    notes: ['Bergamot', 'Vetiver', 'Cedrat'],
  ),
  // Add more minimal data for testing search
  Product(
    id: 'prod_4',
    name: 'OCEANIC MIST',
    brand: 'LUMINA',
    price: 195.0,
    imageUrl: 'https://images.unsplash.com/photo-1519669576417-c8c325dcf944?q=80&w=1000&auto=format&fit=crop',
    rating: 4.6,
    reviews: 42,
    notes: ['Sea Salt', 'Sage', 'Driftwood'], description: '',
  ),
  Product(
    id: 'prod_5',
    name: 'GOLDEN AMBER',
    brand: 'LUMINA',
    price: 310.0,
    imageUrl: 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?q=80&w=1000&auto=format&fit=crop',
    rating: 5.0,
    reviews: 210,
    notes: ['Amber', 'Gold Musk', 'Sandalwood'], description: '',
  ),
];

class SearchState {
  final String query;
  final List<String> selectedNotes;
  final RangeValues priceRange;
  final List<Product> results;
  final bool isLoading;

  SearchState({
    this.query = '',
    this.selectedNotes = const [],
    this.priceRange = const RangeValues(0, 500),
    this.results = const [],
    this.isLoading = false,
  });

  SearchState copyWith({
    String? query,
    List<String>? selectedNotes,
    RangeValues? priceRange,
    List<Product>? results,
    bool? isLoading,
  }) {
    return SearchState(
      query: query ?? this.query,
      selectedNotes: selectedNotes ?? this.selectedNotes,
      priceRange: priceRange ?? this.priceRange,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(SearchState());

  void search(String query) async {
    state = state.copyWith(query: query, isLoading: true);
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final filtered = _allProducts.where((p) {
      final matchesQuery = p.name.toLowerCase().contains(query.toLowerCase());
      final matchesNotes = state.selectedNotes.isEmpty || 
          p.notes.any((n) => state.selectedNotes.contains(n));
      final matchesPrice = p.price >= state.priceRange.start && 
          p.price <= state.priceRange.end;
      
      return matchesQuery && matchesNotes && matchesPrice;
    }).toList();

    state = state.copyWith(results: filtered, isLoading: false);
  }

  void toggleNote(String note) {
    final current = [...state.selectedNotes];
    if (current.contains(note)) {
      current.remove(note);
    } else {
      current.add(note);
    }
    state = state.copyWith(selectedNotes: current);
    search(state.query); // Re-search with new filters
  }

  void updatePriceRange(RangeValues range) {
    state = state.copyWith(priceRange: range);
    search(state.query); // Re-search with new filters
  }

  void clearFilters() {
    state = SearchState(query: state.query, results: state.results); // Keep query
    search(state.query);
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

final recentSearchesProvider = StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
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
