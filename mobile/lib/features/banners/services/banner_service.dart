import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

class BannerItem {
  final String id;
  final String? title;
  final String? subtitle;
  final String imageUrl;
  final String? linkUrl;
  final bool isActive;
  final DateTime createdAt;

  BannerItem({
    required this.id,
    this.title,
    this.subtitle,
    required this.imageUrl,
    this.linkUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'] as String,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      linkUrl: json['linkUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class BannerService {
  final ApiClient _apiClient;

  const BannerService(this._apiClient);

  Future<List<BannerItem>> getBanners() async {
    final response = await _apiClient.get<List<dynamic>>('/banners');
    final data = response.data ?? <dynamic>[];
    return (data as List)
        .map(
          (e) => BannerItem.fromJson(
            (e as Map).map((k, v) => MapEntry(k.toString(), v)),
          ),
        )
        .toList();
  }
}

final bannerServiceProvider = Provider<BannerService>((ref) {
  return BannerService(ref.watch(apiClientProvider));
});

final bannersProvider = FutureProvider<List<BannerItem>>((ref) async {
  final service = ref.watch(bannerServiceProvider);
  return service.getBanners();
});
