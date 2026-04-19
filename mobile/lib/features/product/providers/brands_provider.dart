import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../services/brands_service.dart';
import '../models/brand.dart';

final brandsServiceProvider = Provider<BrandsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BrandsService(apiClient);
});

final brandsProvider = FutureProvider<List<Brand>>((ref) async {
  final service = ref.watch(brandsServiceProvider);
  final brands = await service.getBrands();
  // Sort alphabetically by name
  brands.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return brands;
});
