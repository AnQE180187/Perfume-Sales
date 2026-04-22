import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class RecentlyViewedNotifier extends StateNotifier<List<Product>> {
  RecentlyViewedNotifier() : super([]) {
    _loadFromPrefs();
  }

  static const _key = 'recently_viewed_products';

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key);
    if (data != null) {
      state = data.map((item) => Product.fromJson(jsonDecode(item))).toList();
    }
  }

  Future<void> addProduct(Product product) async {
    // Remove if already exists to move to top
    final newState = List<Product>.from(state)..removeWhere((p) => p.id == product.id);
    
    // Add to top
    newState.insert(0, product);
    
    // Keep only last 10
    if (newState.length > 10) {
      newState.removeLast();
    }
    
    state = newState;
    
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_key, data);
  }

  Future<void> clear() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final recentlyViewedProvider = StateNotifierProvider<RecentlyViewedNotifier, List<Product>>((ref) {
  return RecentlyViewedNotifier();
});
