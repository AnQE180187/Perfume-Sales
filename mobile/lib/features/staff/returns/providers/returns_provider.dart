import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/returns_service.dart';

class StaffReturnNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final StaffReturnsService _service;
  StaffReturnNotifier(this._service) : super(const AsyncValue.loading()) {
    loadReturns();
  }

  Future<List<String>> uploadImages(List<File> images) async {
    try {
      return await _service.uploadImages(images);
    } catch (e) {
      return [];
    }
  }

  Future<void> loadReturns({
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final list = await _service.listAll(
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> receiveReturn(String id, {
    required List<Map<String, dynamic>> items,
    required String receivedLocation,
    String? note,
    List<String>? evidenceImages,
  }) async {
    try {
      await _service.receiveReturn(id, items: items, receivedLocation: receivedLocation, note: note, evidenceImages: evidenceImages);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> shipBackAutomated(String id) async {
    try {
      final res = await _service.shipBackAutomated(id);
      return res;
    } catch (e) {
      return null;
    }
  }

  Future<bool> shipBackManual(String id, {
    String? courier,
    required String trackingNumber,
  }) async {
    try {
      await _service.shipBackManual(id, courier: courier, trackingNumber: trackingNumber);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> triggerRefund(String id, {
    required String method,
    required double amount,
    String? note,
    String? receiptImage,
  }) async {
    try {
      await _service.triggerRefund(id, method: method, amount: amount, note: note, receiptImage: receiptImage);
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
final returnsDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final returnDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  return ref.watch(staffReturnsServiceProvider).getDetails(id);
});

final suggestedRefundProvider = FutureProvider.family<double, String>((ref, id) async {
  return ref.watch(staffReturnsServiceProvider).getSuggestedRefund(id);
});
