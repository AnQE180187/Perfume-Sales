import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/scent_family.dart';
import 'scent_api_service.dart';

class ScentRepository {
  final ScentApiService _apiService;

  ScentRepository({required ScentApiService apiService}) : _apiService = apiService;

  Future<List<ScentFamily>> getScentFamilies() async {
    final rawList = await _apiService.getScentFamilies();
    return rawList.map((j) => ScentFamily.fromJson(j as Map<String, dynamic>)).toList();
  }

  // Helper to get visual info based on name
  Map<String, dynamic> getVisuals(String name) {
    final n = name.toLowerCase();
    if (n.contains('hoa') || n.contains('floral')) {
      return {'icon': Icons.local_florist_outlined, 'color': const Color(0xFF8A7BD6)};
    }
    if (n.contains('gỗ') || n.contains('woody')) {
      return {'icon': Icons.park_outlined, 'color': const Color(0xFFB07A5A)};
    }
    if (n.contains('biển') || n.contains('aquatic') || n.contains('tươi')) {
      return {'icon': Icons.water_drop_outlined, 'color': const Color(0xFF6FA6A0)};
    }
    if (n.contains('oriental')) {
      return {'icon': Icons.auto_awesome_outlined, 'color': const Color(0xFFC98B7E)};
    }
    if (n.contains('ngọt') || n.contains('gourmand')) {
      return {'icon': Icons.icecream_outlined, 'color': const Color(0xFFC98B7E)};
    }
    if (n.contains('cay') || n.contains('spicy')) {
      return {'icon': Icons.local_fire_department_outlined, 'color': const Color(0xFFB96D63)};
    }
    if (n.contains('cam') || n.contains('citrus')) {
      return {'icon': Icons.wb_sunny_outlined, 'color': const Color(0xFFC7A86A)};
    }
    if (n.contains('xạ') || n.contains('musk')) {
      return {'icon': Icons.blur_on_outlined, 'color': const Color(0xFF6C7A89)};
    }
    if (n.contains('hổ phách') || n.contains('amber')) {
      return {'icon': Icons.auto_awesome_outlined, 'color': const Color(0xFF8E5E2A)};
    }
    if (n.contains('da') || n.contains('leather')) {
      return {'icon': Icons.work_outline_rounded, 'color': const Color(0xFF6C4F3D)};
    }
    if (n.contains('dương xỉ') || n.contains('fougere')) {
      return {'icon': Icons.grass_rounded, 'color': const Color(0xFF4A6741)};
    }
    return {'icon': Icons.bubble_chart_outlined, 'color': const Color(0xFF9E9E9E)};
  }
}

final scentApiServiceProvider = Provider<ScentApiService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ScentApiService(client: client);
});

final scentRepositoryProvider = Provider<ScentRepository>((ref) {
  return ScentRepository(apiService: ref.watch(scentApiServiceProvider));
});

final scentFamiliesProvider = FutureProvider<List<ScentFamily>>((ref) {
  return ref.watch(scentRepositoryProvider).getScentFamilies();
});
