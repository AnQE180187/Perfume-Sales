import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/returns_service.dart';

class StaffReturnNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final StaffReturnsService _service;
  StaffReturnNotifier(this._service) : super(const AsyncValue.loading()) {
    loadReturns();
  }

  Future<void> loadReturns({String? status}) async {
    state = const AsyncValue.loading();
    try {
      final list = await _service.listAll(status: status);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> receiveReturn(String id, {
    required List<Map<String, dynamic>> items,
    required String receivedLocation,
    String? note,
  }) async {
    try {
      await _service.receiveReturn(id, items: items, receivedLocation: receivedLocation, note: note);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> triggerRefund(String id, {
    required String method,
    required double amount,
    String? note,
  }) async {
    try {
      await _service.triggerRefund(id, method: method, amount: amount, note: note);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final staffReturnsProvider = StateNotifierProvider<StaffReturnNotifier, AsyncValue<List<dynamic>>>((ref) {
  final service = ref.watch(staffReturnsServiceProvider);
  return StaffReturnNotifier(service);
});

final returnStatusFilterProvider = StateProvider<String>((ref) => 'ALL');

final returnDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  return ref.watch(staffReturnsServiceProvider).getDetails(id);
});

final suggestedRefundProvider = FutureProvider.family<double, String>((ref, id) async {
  return ref.watch(staffReturnsServiceProvider).getSuggestedRefund(id);
});
