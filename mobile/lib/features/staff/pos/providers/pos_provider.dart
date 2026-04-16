import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../models/staff_store.dart';
import '../models/pos_models.dart';
import '../services/pos_service.dart';

// ── Service Provider ────────────────────────────────────────────────

final staffPosServiceProvider = Provider<StaffPosService>((ref) {
  final client = ref.watch(apiClientProvider);
  return StaffPosService(client: client);
});

// ── Store List ──────────────────────────────────────────────────────

final posStoresProvider = FutureProvider<List<StaffStore>>((ref) async {
  final service = ref.watch(staffPosServiceProvider);
  return service.getMyStores();
});

// ── Selected Store ──────────────────────────────────────────────────

final posSelectedStoreIdProvider = StateProvider<String?>((ref) => null);

// ── Product Search ──────────────────────────────────────────────────

final posSearchQueryProvider = StateProvider<String>((ref) => '');

final posSelectedFamilyProvider = StateProvider<String>((ref) => 'All');

final posProductsProvider = FutureProvider<List<PosProduct>>((ref) async {
  final service = ref.watch(staffPosServiceProvider);
  final storeId = ref.watch(posSelectedStoreIdProvider);
  final query = ref.watch(posSearchQueryProvider);
  final family = ref.watch(posSelectedFamilyProvider);
  
  if (storeId == null) return const [];
  final products = await service.searchProducts(query: query, storeId: storeId);
  
  if (family == 'All') return products;
  return products.where((p) => p.family == family).toList();
});

// ── POS Order State ─────────────────────────────────────────────────

class PosState {
  /// Server-side order (used for edit mode or after checkout).
  final PosOrder? currentOrder;

  /// Local cart items (new order mode — no backend draft).
  final List<LocalCartItem> localCart;

  /// Attached customer phone (before checkout).
  final String? customerPhone;

  /// Full customer details (if found via lookup).
  final LoyaltyResult? customerInfo;

  final bool isLoading;
  final String? error;
  final String? successMessage;
  final bool isReturnLoading;
  final String? returnError;
  final String? returnSuccessMessage;
  final List<LoyaltyResult> customerSuggestions;

  const PosState({
    this.currentOrder,
    this.localCart = const [],
    this.customerPhone,
    this.customerInfo,
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.isReturnLoading = false,
    this.returnError,
    this.returnSuccessMessage,
    this.customerSuggestions = const [],
  });

  /// Whether we're editing a server-side order (from Orders tab).
  bool get isEditMode => currentOrder != null && !currentOrder!.isPaid;

  /// Whether we're in local-cart new-order mode.
  bool get isNewOrderMode => currentOrder == null;

  double get localCartTotal =>
      localCart.fold(0.0, (sum, item) => sum + item.totalPrice);

  PosState copyWith({
    PosOrder? currentOrder,
    List<LocalCartItem>? localCart,
    String? customerPhone,
    LoyaltyResult? customerInfo,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool? isReturnLoading,
    String? returnError,
    String? returnSuccessMessage,
    List<LoyaltyResult>? customerSuggestions,
    bool clearOrder = false,
    bool clearCustomer = false,
  }) {
    return PosState(
      currentOrder: clearOrder ? null : (currentOrder ?? this.currentOrder),
      localCart: localCart ?? this.localCart,
      customerPhone: clearCustomer
          ? null
          : (customerPhone ?? this.customerPhone),
      customerInfo: clearCustomer
          ? null
          : (customerInfo ?? this.customerInfo),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      isReturnLoading: isReturnLoading ?? this.isReturnLoading,
      returnError: returnError,
      returnSuccessMessage: returnSuccessMessage,
      customerSuggestions: customerSuggestions ?? this.customerSuggestions,
    );
  }
}

class PosNotifier extends StateNotifier<PosState> {
  final StaffPosService _service;

  PosNotifier(this._service) : super(const PosState());

  // ── Local Cart Operations (new order mode) ────────────────────

  void addToCart(PosVariant variant, String productName) {
    final cart = List<LocalCartItem>.from(state.localCart);
    final idx = cart.indexWhere((c) => c.variantId == variant.id);
    if (idx >= 0) {
      if (cart[idx].quantity < variant.stock) {
        cart[idx].quantity++;
      }
    } else {
      cart.add(
        LocalCartItem(
          variantId: variant.id,
          variantName: variant.name,
          productName: productName,
          price: variant.price,
          stock: variant.stock,
        ),
      );
    }
    state = state.copyWith(localCart: cart);
  }

  void updateCartQuantity(String variantId, int quantity) {
    final cart = List<LocalCartItem>.from(state.localCart);
    if (quantity <= 0) {
      cart.removeWhere((c) => c.variantId == variantId);
    } else {
      final idx = cart.indexWhere((c) => c.variantId == variantId);
      if (idx >= 0) {
        cart[idx].quantity = quantity;
      }
    }
    state = state.copyWith(localCart: cart);
  }

  void removeFromCart(String variantId) {
    final cart = List<LocalCartItem>.from(state.localCart);
    cart.removeWhere((c) => c.variantId == variantId);
    state = state.copyWith(localCart: cart);
  }

  void setCustomerPhone(String phone) {
    if (phone.isEmpty) {
      state = state.copyWith(clearCustomer: true);
    } else {
      state = state.copyWith(customerPhone: phone);
    }
  }

  // ── Checkout (one-shot create + pay) ──────────────────────────

  Future<Map<String, dynamic>?> checkoutCash(String storeId) async {
    if (state.localCart.isEmpty) return null;
    final oldOrderId = state.currentOrder?.id;
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final result = await _service.checkout(
        storeId: storeId,
        items: state.localCart.map((c) => c.toCheckoutJson()).toList(),
        paymentMethod: 'CASH',
        customerPhone: state.customerPhone,
      );
      if (oldOrderId != null) {
        try {
          await _service.cancelOrder(oldOrderId);
        } catch (_) {}
      }
      final order = PosOrder.fromJson(result);
      state = PosState(
        currentOrder: order,
        successMessage: 'Thanh toán thành công!',
      );
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkoutQr(String storeId) async {
    if (state.localCart.isEmpty) return null;
    final oldOrderId = state.currentOrder?.id;
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final result = await _service.checkout(
        storeId: storeId,
        items: state.localCart.map((c) => c.toCheckoutJson()).toList(),
        paymentMethod: 'QR',
        customerPhone: state.customerPhone,
      );
      if (oldOrderId != null) {
        try {
          await _service.cancelOrder(oldOrderId);
        } catch (_) {}
      }
      // QR returns { order: {...}, checkoutUrl: "..." }
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> saveAsDraft(String storeId) async {
    if (state.localCart.isEmpty) return false;
    final oldOrderId = state.currentOrder?.id;
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final order = await _service.saveAsDraft(
        storeId: storeId,
        items: state.localCart.map((c) => c.toCheckoutJson()).toList(),
        customerPhone: state.customerPhone,
      );
      if (oldOrderId != null && oldOrderId != order.id) {
        try {
          await _service.cancelOrder(oldOrderId);
        } catch (_) {}
      }
      state = PosState(
        currentOrder: order,
        successMessage: 'Đơn đã được lưu vào quản lý!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> lookupLoyalty(String phone) async {
    if (phone.isEmpty) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _service.lookupLoyalty(phone);
      if (result != null) {
        final loyalty = LoyaltyResult.fromJson(result);
        state = state.copyWith(
          isLoading: false,
          customerPhone: phone,
          customerInfo: loyalty,
          successMessage: 'Đã tìm thấy thành viên: ${loyalty.fullName ?? phone}',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Không tìm thấy thông tin thành viên.',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> autoSearchCustomers(String phone) async {
    if (phone.length < 3) {
      state = state.copyWith(customerSuggestions: []);
      return;
    }
    try {
      final results = await _service.searchCustomers(phone);
      final suggestions = results.map((e) => LoyaltyResult.fromJson(e)).toList();
      state = state.copyWith(customerSuggestions: suggestions);
    } catch (_) {
      state = state.copyWith(customerSuggestions: []);
    }
  }

  void selectCustomerSuggestion(LoyaltyResult suggestion) {
    state = state.copyWith(
      customerPhone: suggestion.phone,
      customerInfo: suggestion,
      customerSuggestions: [],
    );
  }

  // ── Edit-mode operations (existing server-side order) ─────────

  Future<void> createDraft(String storeId) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final order = await _service.createDraftOrder(storeId: storeId);
      state = PosState(currentOrder: order);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addItem(String variantId, int quantity) async {
    final order = state.currentOrder;
    if (order == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _service.upsertItem(
        orderId: order.id,
        variantId: variantId,
        quantity: quantity,
      );
      state = PosState(currentOrder: updated);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateItemQuantity(String variantId, int quantity) async {
    final order = state.currentOrder;
    if (order == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _service.upsertItem(
        orderId: order.id,
        variantId: variantId,
        quantity: quantity,
      );
      state = PosState(currentOrder: updated);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> removeItem(String variantId) async {
    await updateItemQuantity(variantId, 0);
  }

  Future<void> setCustomer(String phone) async {
    final order = state.currentOrder;
    if (order == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _service.setCustomer(
        orderId: order.id,
        customerPhone: phone,
      );
      state = PosState(currentOrder: updated);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> payCash() async {
    final order = state.currentOrder;
    if (order == null) return;
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final paid = await _service.payCash(order.id);
      state = PosState(
        currentOrder: paid,
        successMessage: 'Thanh toán thành công!',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load an existing pending order to continue editing.
  Future<void> loadExistingOrder(String orderId, {String? storeId}) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final order = await _service.getOrder(orderId);
      final List<LocalCartItem> cartItems = order.items.map((it) {
        return LocalCartItem(
          variantId: it.variantId,
          variantName: it.variant?.name ?? '',
          productName: it.variant?.product?.name ?? '',
          price: it.unitPrice,
          quantity: it.quantity,
          stock: 100, // Stock info not available in OrderItem payload
        );
      }).toList();

      LoyaltyResult? custInfo;
      if (order.user != null) {
        custInfo = LoyaltyResult(
          registered: true,
          userId: order.user!.id,
          fullName: order.user!.fullName,
          phone: order.user!.phone ?? '',
          loyaltyPoints: order.user!.loyaltyPoints,
          tier: order.user!.tier,
        );
      }

      state = PosState(
        currentOrder: order,
        localCart: cartItems,
        customerPhone: order.phone ?? order.user?.phone,
        customerInfo: custInfo,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Cancel a pending POS order.
  Future<bool> cancelOrder(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.cancelOrder(orderId);
      state = const PosState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearOrder() {
    state = const PosState();
  }

  /// Resolve [rawCode] via backend barcode lookup and add one unit to cart or server order.
  /// Returns `true` if a line item was added or quantity increased.
  Future<bool> applyBarcode(String rawCode, String storeId) async {
    final code = rawCode.trim();
    if (code.isEmpty) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _service.searchProducts(
        barcode: code,
        storeId: storeId,
      );
      if (list.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Không tìm thấy sản phẩm với mã vạch này.',
        );
        return false;
      }

      PosVariant? match;
      String? productName;
      for (final p in list) {
        for (final v in p.variants) {
          if (v.barcode != null && v.barcode == code) {
            match = v;
            productName = p.name;
            break;
          }
        }
        if (match != null) break;
      }

      if (match == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Không tìm thấy sản phẩm với mã vạch này.',
        );
        return false;
      }

      if (match.stock <= 0) {
        state = state.copyWith(
          isLoading: false,
          error: 'Sản phẩm đã hết hàng tại quầy.',
        );
        return false;
      }

      final order = state.currentOrder;
      if (order != null && !order.isPaid) {
        int nextQty = 1;
        for (final it in order.items) {
          if (it.variantId == match.id) {
            nextQty = it.quantity + 1;
            break;
          }
        }
        if (nextQty > match.stock) {
          state = state.copyWith(
            isLoading: false,
            error: 'Vượt quá số lượng tồn kho (${match.stock}).',
          );
          return false;
        }
        final updated = await _service.upsertItem(
          orderId: order.id,
          variantId: match.id,
          quantity: nextQty,
        );
        state = state.copyWith(currentOrder: updated, isLoading: false);
        return true;
      } else {
        addToCart(match, productName ?? '');
        state = state.copyWith(isLoading: false);
        return true;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> createPosReturn({
    required String orderId,
    required List<PosOrderItem> orderItems,
    String? reason,
  }) async {
    if (orderItems.isEmpty) {
      state = state.copyWith(returnError: 'Không có sản phẩm để trả.');
      return false;
    }

    state = state.copyWith(
      isReturnLoading: true,
      returnError: null,
      returnSuccessMessage: null,
    );

    try {
      final request = CreateReturnRequest(
        orderId: orderId,
        reason: reason,
        items: orderItems
            .map(
              (e) => ReturnItemRequest(
                variantId: e.variantId,
                quantity: e.quantity,
                reason: reason,
              ),
            )
            .toList(),
      );

      final created = await _service.createPosReturn(request);
      final returnId = (created['id'] ?? '').toString();
      if (returnId.isEmpty) {
        throw Exception('Không tạo được phiếu trả hàng');
      }

      state = state.copyWith(
        isReturnLoading: false,
        returnSuccessMessage: 'Tạo yêu cầu hoàn trả POS thành công!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isReturnLoading: false, returnError: e.toString());
      return false;
    }
  }

  void clearReturnMessages() {
    state = state.copyWith(returnError: null, returnSuccessMessage: null);
  }
}

final posProvider = StateNotifierProvider<PosNotifier, PosState>((ref) {
  final service = ref.watch(staffPosServiceProvider);
  return PosNotifier(service);
});
