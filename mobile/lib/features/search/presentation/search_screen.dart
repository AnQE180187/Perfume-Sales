import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/search_provider.dart';
import '../../product/models/product.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final recentSearches = ref.watch(recentSearchesProvider);
    final hasResults = searchState.results.isNotEmpty;
    final isSearching = _searchController.text.isNotEmpty;
    // final l10n = AppLocalizations.of(context)!; // Uncomment when i18n added for search

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header & Search Input
            _buildSearchHeader(context),
            
            // Filter Chips
            if (isSearching) _buildFilters(context, ref, searchState),

            // Content
            Expanded(
              child: searchState.isLoading
                  ? _buildLoadingState(context)
                  : isSearching
                      ? (hasResults
                          ? _buildResultsGrid(context, searchState.results)
                          : _buildEmptyState(context))
                      : _buildRecentSearches(context, ref, recentSearches),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                autofocus: true,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search collection, notes...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchProvider.notifier).search('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  ref.read(searchProvider.notifier).search(value);
                  if (value.isNotEmpty) {
                    ref.read(recentSearchesProvider.notifier).add(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, WidgetRef ref, SearchState state) {
    final notes = ['Rose', 'Oud', 'Vanilla', 'Amber', 'Vetiver', 'Citrus'];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: notes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final note = notes[index];
          final isSelected = state.selectedNotes.contains(note);
          
          return FilterChip(
            label: Text(
              note,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: isSelected ? AppTheme.primaryDb : null,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => ref.read(searchProvider.notifier).toggleNote(note),
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedColor: AppTheme.champagneGold,
            checkmarkColor: AppTheme.primaryDb,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected 
                    ? Colors.transparent 
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          );
        },
      ),
    );
  }

  Widget _buildResultsGrid(BuildContext context, List<Product> results) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return _ProductSearchCard(product: product);
      },
    );
  }

  Widget _buildRecentSearches(BuildContext context, WidgetRef ref, List<String> recent) {
    if (recent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.manage_search,
              size: 48,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Discover your signature scent',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT SEARCHES',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
              ),
              GestureDetector(
                onTap: () => ref.read(recentSearchesProvider.notifier).clear(),
                child: Text(
                  'CLEAR',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 10,
                    color: AppTheme.accentGold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: recent.length,
            itemBuilder: (context, index) {
              final query = recent[index];
              return ListTile(
                leading: const Icon(Icons.history, size: 18),
                title: Text(
                  query,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => ref.read(recentSearchesProvider.notifier).remove(query),
                ),
                onTap: () {
                  _searchController.text = query;
                  ref.read(searchProvider.notifier).search(query);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.champagneGold,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No matches found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ProductSearchCard extends StatelessWidget {
  final Product product;

  const _ProductSearchCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: const Icon(Icons.image_not_supported, size: 30),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 8),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
