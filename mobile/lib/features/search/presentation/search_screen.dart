import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_card.dart';
import 'package:go_router/go_router.dart';
import '../../product/models/product.dart';
import '../providers/search_provider.dart';
import 'widgets/search_header.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Client-side filter state (scent/occasion/price are UI-only filters)
  String? _selectedScent;
  String? _selectedOccasion;
  String? _selectedPrice;

  static const _scentOptions = ['Woody', 'Floral', 'Fresh', 'Sweet', 'Spicy'];
  static const _occasionOptions = ['Daily', 'Office', 'Date', 'Party'];
  static const _priceOptions = ['<1M', '1-3M', '>3M'];

  bool get _hasActiveFilters =>
      _selectedScent != null ||
      _selectedOccasion != null ||
      _selectedPrice != null;

  @override
  void initState() {
    super.initState();
    // Load initial products through the provider
    Future.microtask(() => ref.read(searchProvider.notifier).loadInitial());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _applyClientFilters(List<Product> products) {
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
      case '1-3M':
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
    final searchState = ref.watch(searchProvider);
    final filteredResults = _applyClientFilters(searchState.results);

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
                    if (value.isNotEmpty) {
                      ref.read(searchProvider.notifier).search(value);
                    } else {
                      ref.read(searchProvider.notifier).loadInitial();
                    }
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
                    title: 'Dòng hương',
                    options: _scentOptions,
                    selected: _selectedScent,
                    onSelect: (v) => setState(
                      () => _selectedScent = _selectedScent == v ? null : v,
                    ),
                  ),
                  _buildDivider(),
                  _FilterSection(
                    title: 'Dịp sử dụng',
                    options: _occasionOptions,
                    selected: _selectedOccasion,
                    onSelect: (v) => setState(
                      () => _selectedOccasion = _selectedOccasion == v ? null : v,
                    ),
                  ),
                  _buildDivider(),
                  _FilterSection(
                    title: 'Khoảng giá',
                    options: _priceOptions,
                    selected: _selectedPrice,
                    onSelect: (v) => setState(
                      () => _selectedPrice = _selectedPrice == v ? null : v,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Results Title & Summary
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _searchController.text.isEmpty
                              ? 'Hương thơm nổi bật'
                              : 'Kết quả tìm kiếm',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepCharcoal,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (!searchState.isLoading)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              '(${filteredResults.length} sản phẩm)',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.mutedSilver,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (_hasActiveFilters)
                          GestureDetector(
                            onTap: _clearFilters,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                'Xóa lọc',
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
            child: const Text('Thu lại'),
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
          Text('Không tìm thấy sản phẩm phù hợp', style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.mutedSilver)),
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
