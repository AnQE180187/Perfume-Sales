import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

class Store {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final double? lat;
  final double? lng;

  const Store({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.lat,
    this.lng,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return Store(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng']),
    );
  }
}

class StoresService {
  final ApiClient _client;

  const StoresService(this._client);

  /// Attempts to fetch a public list of boutiques from backend.
  /// Falls back to mock data on error to allow UI development.
  Future<List<Store>> getPublicStores() async {
    try {
      final resp = await _client.get<dynamic>('/stores/public');
      final body = resp.data;
      final items = (body is List)
          ? body
          : (body is Map && body['items'] is List)
          ? body['items']
          : <dynamic>[];
      return (items as List)
          .whereType<Map<String, dynamic>>()
          .map((m) => Store.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (e) {
      // Fallback mock data for development / until backend exposes a public endpoint
      return _mockStores();
    }
  }

  List<Store> _mockStores() {
    return const [
      Store(
        id: 'st_1',
        name: 'Aura Boutique - Hồ Chí Minh',
        address: '45 Nguyễn Huệ, Quận 1',
        phone: '0909 111 111',
        lat: 10.77653,
        lng: 106.70098,
      ),
      Store(
        id: 'st_2',
        name: 'Aura Boutique - Hà Nội',
        address: '12 Hàng Bông, Hoàn Kiếm',
        phone: '0909 222 222',
        lat: 21.02776,
        lng: 105.83416,
      ),
      Store(
        id: 'st_3',
        name: 'Aura Boutique - Đà Nẵng',
        address: '5 Bạch Đằng, Sơn Trà',
        phone: '0909 333 333',
        lat: 16.05441,
        lng: 108.20216,
      ),
    ];
  }
}

final storesServiceProvider = Provider<StoresService>((ref) {
  final client = ref.read(apiClientProvider);
  return StoresService(client);
});

final publicStoresProvider = FutureProvider.autoDispose<List<Store>>((
  ref,
) async {
  return ref.read(storesServiceProvider).getPublicStores();
});
