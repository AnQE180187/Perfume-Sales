import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../product/models/product.dart';
import '../../../../core/widgets/product_card.dart';
import 'package:go_router/go_router.dart';

class RecentlyViewedSection extends StatelessWidget {
  final List<Product> products;

  const RecentlyViewedSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'SẢN PHẨM VỪA XEM',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppTheme.deepCharcoal.withOpacity(0.5),
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 140,
                child: ProductCard(
                  product: product,
                  variant: ProductCardVariant.grid,
                  onTap: () => context.push('/product/${product.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
