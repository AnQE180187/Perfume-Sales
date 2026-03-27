import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';
import '../../product/data/product_repository.dart';
import '../../product/models/product.dart';
import '../../product/services/product_service.dart';
import 'widgets/search_header.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Keep mock service for non-real-API mode
  final ProductService _mockService = ProductService();
  List<Product> _allResults = [];
  bool _isSearching = false;

  // Filter state — null means no filter selected
  String? _selectedScent;
  String? _selectedOccasion;
  String? _selectedPrice;

  static const _scentOptions = ['Woody', 'Floral', 'Fresh', 'Sweet', 'Spicy'];
  static const _occasionOptions = ['Daily', 'Office', 'Date', 'Party'];
  static const _priceOptions = ['<1M', '1–3M', '>3M'];

  List<Product> get _filteredResults => _applyFilters(_allResults);

  bool get _hasActiveFilters =>
      _selectedScent != null ||
      _selectedOccasion != null ||
      _selectedPrice != null;

  @override
  void initState() {
    super.initState();
    _loadInitialProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialProducts() async {
    try {
      List<Product> products;
      if (AppConfig.useRealAPI) {
        final repository = ref.read(productRepositoryProvider);
        products = await repository.getProducts(take: 20);
      } else {
        products = await _mockService.getAllProducts();
      }
      if (mounted) setState(() => _allResults = products);
    } catch (_) {
      // Fallback to mock on network error
      final products = await _mockService.getAllProducts();
      if (mounted) setState(() => _allResults = products);
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    try {
      List<Product> results;
      if (AppConfig.useRealAPI) {
        final repository = ref.read(productRepositoryProvider);
        results = await repository.getProducts(search: query, take: 50);
      } else {
        results = await _mockService.searchProducts(query);
      }
      if (mounted) {
        setState(() {
          _allResults = results;
          _isSearching = false;
        });
      }
    } catch (_) {
      // Fallback to mock on network error
      final results = await _mockService.searchProducts(query);
      if (mounted) {
        setState(() {
          _allResults = results;
          _isSearching = false;
        });
      }
    }
  }

  List<Product> _applyFilters(List<Product> products) {
    return products.where((p) {
      if (_selectedScent != null && !_matchesScent(p, _selectedScent!)) {
        return false;
      }
      if (_selectedOccasion != null &&
          !_matchesOccasion(p, _selectedOccasion!)) {
        return false;
      }
      if (_selectedPrice != null && !_matchesPrice(p, _selectedPrice!)) {
        return false;
      }
      return true;
    }).toList();
  }

  bool _matchesScent(Product p, String scent) {
    final allNotes = [
      ...p.notes,
      ...p.topNotes,
      ...p.heartNotes,
      ...p.baseNotes,
    ].map((n) => n.toLowerCase());
    final desc = (p.description ?? '').toLowerCase();
    switch (scent) {
      case 'Woody':
        return allNotes.any(
              (n) => [
                'sandalwood',
                'cedar',
                'wood',
                'oud',
                'vetiver',
                'patchouli',
              ].any((k) => n.contains(k)),
            ) ||
            desc.contains('wood') ||
            desc.contains('cedar');
      case 'Floral':
        return allNotes.any(
          (n) => [
            'rose',
            'jasmine',
            'lily',
            'iris',
            'peony',
            'violet',
            'floral',
          ].any((k) => n.contains(k)),
        );
      case 'Fresh':
        return allNotes.any(
          (n) => [
            'bergamot',
            'lemon',
            'fresh',
            'citrus',
            'green',
            'mint',
            'aqua',
          ].any((k) => n.contains(k)),
        );
      case 'Sweet':
        return allNotes.any(
          (n) => [
            'vanilla',
            'sweet',
            'caramel',
            'honey',
            'amber',
            'musk',
          ].any((k) => n.contains(k)),
        );
      case 'Spicy':
        return allNotes.any(
          (n) => [
            'pepper',
            'spice',
            'cardamom',
            'ginger',
            'clove',
            'cinnamon',
          ].any((k) => n.contains(k)),
        );
      default:
        return true;
    }
  }

  bool _matchesOccasion(Product p, String occasion) {
    final text = '${p.name} ${p.description ?? ''} ${p.notes.join(' ')}'
        .toLowerCase();
    switch (occasion) {
      case 'Daily':
        return text.contains('fresh') ||
            text.contains('light') ||
            text.contains('green');
      case 'Office':
        return text.contains('clean') ||
            text.contains('iris') ||
            text.contains('subtle');
      case 'Date':
        return text.contains('rose') ||
            text.contains('jasmine') ||
            text.contains('sensual');
      case 'Party':
        return text.contains('bold') ||
            text.contains('oud') ||
            text.contains('intense');
      default:
        return true;
    }
  }

  bool _matchesPrice(Product p, String priceRange) {
    switch (priceRange) {
      case '<1M':
        return p.price < 1000000;
      case '1–3M':
        return p.price >= 1000000 && p.price <= 3000000;
      case '>3M':
        return p.price > 3000000;
      default:
        return true;
    }
  }

  void _clearFilters() => setState(() {
    _selectedScent = null;
    _selectedOccasion = null;
    _selectedPrice = null;
  });

  @override
  Widget build(BuildContext context) {
    final filteredResults = _filteredResults;

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Header
            SearchHeader(
              controller: _searchController,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _performSearch(value);
                } else {
                  _loadInitialProducts();
                }
              },
              onClear: () {
                _searchController.clear();
                _loadInitialProducts();
              },
              onBack: () => Navigator.pop(context),
              showClearButton: _searchController.text.isNotEmpty,
            ),

            // Results title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(
                _searchController.text.isEmpty
                    ? 'Hương thơm nổi bật'
                    : 'Kết quả cho "${_searchController.text}"',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Filter row — Scent
            _FilterChipRow(
              options: _scentOptions,
              selected: _selectedScent,
              onSelect: (v) => setState(
                () => _selectedScent = _selectedScent == v ? null : v,
              ),
            ),
            const SizedBox(height: 6),

            // Filter row — Occasion
            _FilterChipRow(
              options: _occasionOptions,
              selected: _selectedOccasion,
              onSelect: (v) => setState(
                () => _selectedOccasion = _selectedOccasion == v ? null : v,
              ),
            ),
            const SizedBox(height: 6),

            // Filter row — Price
            _FilterChipRow(
              options: _priceOptions,
              selected: _selectedPrice,
              onSelect: (v) => setState(
                () => _selectedPrice = _selectedPrice == v ? null : v,
              ),
            ),

            // Active filter summary
            if (_hasActiveFilters)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        [
                          _selectedScent,
                          _selectedOccasion,
                          _selectedPrice,
                        ].whereType<String>().join(' • '),
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearFilters,
                      child: Text(
                        'Xóa bộ lọc',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mutedSilver,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.mutedSilver,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // Results grid
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.champagneGold,
                      ),
                    )
                  : filteredResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppTheme.mutedSilver,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không tìm thấy kết quả',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.mutedSilver,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.60,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: filteredResults.length,
                      itemBuilder: (context, index) {
                        final product = filteredResults[index];
                        final matchPercent =
                            product.rating != null && product.rating! >= 4.8
                            ? (product.rating! * 20).toInt()
                            : null;
                        return ProductCard(
                          product: product,
                          variant: ProductCardVariant.grid,
                          matchPercent: matchPercent,
                          onTap: () => context.push('/product/${product.id}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _FilterChipRow({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = selected == option;
          return GestureDetector(
            onTap: () => onSelect(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.deepCharcoal : AppTheme.creamWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.deepCharcoal
                      : AppTheme.softTaupe,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(
                      Icons.check,
                      size: 10,
                      color: AppTheme.champagneGold,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    option,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: isSelected
                          ? AppTheme.creamWhite
                          : AppTheme.mutedSilver,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
