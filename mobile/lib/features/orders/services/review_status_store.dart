import 'package:shared_preferences/shared_preferences.dart';

class ReviewStatusStore {
  static const String _keyReviewedOrderIds = 'reviewed_order_ids_v1';

  Future<Set<String>> getReviewedOrderIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyReviewedOrderIds) ?? const <String>[];
    return list.where((e) => e.trim().isNotEmpty).toSet();
  }

  Future<void> markReviewed(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_keyReviewedOrderIds) ?? <String>[];
    if (!current.contains(orderId)) {
      current.add(orderId);
      await prefs.setStringList(_keyReviewedOrderIds, current);
    }
  }
}

