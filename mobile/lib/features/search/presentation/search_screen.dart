import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';
import '../../product/services/product_service.dart';
import '../../product/models/product.dart';
import 'widgets/search_header.dart';
import 'widgets/filter_chips.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  List<Product> _searchResults = [];
  bool _isSearching = false;
  String _selectedFilter = 'MOOD';

  final List<String> _filters = ['MOOD', 'OCCASION', 'SEASON'];

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
    final products = await _productService.getAllProducts();
    if (mounted) {
      setState(() {
        _searchResults = products;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    final results = await _productService.searchProducts(query);
    
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: SafeArea(
        child: Column(
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

            // Results Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    _searchController.text.isEmpty
                        ? 'Trending Scents'
                        : 'Results for "${_searchController.text}"',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.deepCharcoal,
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            FilterChips(
              filters: _filters,
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),

            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.champagneGold),
                    )
                  : _searchResults.isEmpty
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
                                'No results found',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.mutedSilver,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final product = _searchResults[index];
                            final matchPercent = product.rating != null && product.rating! >= 4.8
                                ? (product.rating! * 20).toInt()
                                : null;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ProductCard(
                                product: product,
                                variant: ProductCardVariant.list,
                                matchPercent: matchPercent,
                                onTap: () => context.push('/product/${product.id}'),
                                onAdd: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} added to cart'),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
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