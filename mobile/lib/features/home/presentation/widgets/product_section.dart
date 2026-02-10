import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../product/models/product.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final String? actionText;
  final AsyncValue<List<Product>> productsAsync;

  const ProductSection({
    super.key,
    required this.title,
    this.actionText,
    required this.productsAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: title,
            onViewAll: () => context.push('/explore'),
            showViewAll: actionText != null,
          ),
        ),
        productsAsync.when(
          loading: () => const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => const SizedBox(
            height: 200,
            child: Center(child: Text('Failed to load')),
          ),
          data: (products) => SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  variant: ProductCardVariant.featured,
                  badge: 'AI CURATED',
                  onTap: () => context.push('/product/${product.id}'),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
