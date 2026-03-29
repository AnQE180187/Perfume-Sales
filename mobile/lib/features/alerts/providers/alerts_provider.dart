import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert.dart';

// ---------------------------------------------------------------------------
// Mock seed — replace with real API call when backend is ready
// ---------------------------------------------------------------------------
const List<Alert> _mockAlerts = [
  Alert(
    id: 'ord-1',
    title: 'Đơn hàng của bạn đang được đóng gói',
    message:
        'No. 07 Velvet Rose đã vào giai đoạn hoàn thiện cuối cùng và sẽ được chuẩn bị giao trong tối nay.',
    timeLabel: '2 phút trước',
    category: AlertCategory.order,
    isUnread: true,
    actionLabel: 'Theo dõi đơn',
    accentColor: Color(0xFFD4AF37),
  ),
  Alert(
    id: 'off-1',
    title: 'Ưu đãi riêng vừa được mở',
    message:
        'Ưu đãi 12% đang chờ bạn cho lần mua nước hoa tiếp theo đến hết nửa đêm hôm nay.',
    timeLabel: '18 phút trước',
    category: AlertCategory.offer,
    isUnread: true,
    actionLabel: 'Dùng ưu đãi',
    accentColor: Color(0xFFB9824A),
  ),
  Alert(
    id: 'acc-1',
    title: 'Sản phẩm yêu thích đã có hàng lại',
    message:
        'Maison Lumiere Ambre bản 50ml đã có hàng trở lại và được giữ cho bạn trong 6 giờ tới.',
    timeLabel: 'Hôm nay, 09:24',
    category: AlertCategory.account,
    isUnread: true,
    actionLabel: 'Xem sản phẩm',
    accentColor: Color(0xFF7D8F69),
  ),
  Alert(
    id: 'ord-2',
    title: 'Đơn vị vận chuyển đã xác nhận lịch ngày mai',
    message:
        'Đơn hàng gần nhất của bạn dự kiến sẽ được giao trong khoảng 10:00 đến 13:00 và cần ký nhận.',
    timeLabel: 'Hôm qua',
    category: AlertCategory.order,
    isUnread: false,
    actionLabel: 'Xem vận chuyển',
    accentColor: Color(0xFF8A7D6A),
  ),
  Alert(
    id: 'off-2',
    title: 'Bài viết tuyển chọn mới',
    message:
        'Khám phá ba mùi hương trầm ấm cho buổi tối do chuyên gia tư vấn mùi hương tuyển chọn cho mùa mưa.',
    timeLabel: 'Thứ Ba',
    category: AlertCategory.offer,
    isUnread: false,
    actionLabel: 'Đọc bài viết',
    accentColor: Color(0xFFA15C45),
  ),
];

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------
class AlertsNotifier extends AsyncNotifier<List<Alert>> {
  @override
  Future<List<Alert>> build() async {
    // TODO: replace with real API call:
    // final client = ref.read(apiClientProvider);
    // final response = await client.dio.get('/notifications');
    // return (response.data as List).map(Alert.fromJson).toList();
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockAlerts);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  void markAsRead(String id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.map((a) => a.id == id ? a.copyWith(isUnread: false) : a).toList(),
    );
  }

  void markAllAsRead() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.map((a) => a.copyWith(isUnread: false)).toList());
  }
}

// ---------------------------------------------------------------------------
// Preference notifier (filter + toggles — synchronous UI state)
// ---------------------------------------------------------------------------
class AlertsPrefsNotifier extends Notifier<AlertsPrefs> {
  @override
  AlertsPrefs build() => const AlertsPrefs();

  void setFilter(AlertFilter filter) =>
      state = state.copyWith(activeFilter: filter);

  void toggleOrderUpdates(bool value) =>
      state = state.copyWith(orderUpdatesEnabled: value);

  void toggleOfferUpdates(bool value) =>
      state = state.copyWith(offerUpdatesEnabled: value);

  void toggleAccountAlerts(bool value) =>
      state = state.copyWith(accountAlertsEnabled: value);
}

class AlertsPrefs {
  final AlertFilter activeFilter;
  final bool orderUpdatesEnabled;
  final bool offerUpdatesEnabled;
  final bool accountAlertsEnabled;

  const AlertsPrefs({
    this.activeFilter = AlertFilter.all,
    this.orderUpdatesEnabled = true,
    this.offerUpdatesEnabled = true,
    this.accountAlertsEnabled = false,
  });

  AlertsPrefs copyWith({
    AlertFilter? activeFilter,
    bool? orderUpdatesEnabled,
    bool? offerUpdatesEnabled,
    bool? accountAlertsEnabled,
  }) {
    return AlertsPrefs(
      activeFilter: activeFilter ?? this.activeFilter,
      orderUpdatesEnabled: orderUpdatesEnabled ?? this.orderUpdatesEnabled,
      offerUpdatesEnabled: offerUpdatesEnabled ?? this.offerUpdatesEnabled,
      accountAlertsEnabled: accountAlertsEnabled ?? this.accountAlertsEnabled,
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------
final alertsProvider = AsyncNotifierProvider<AlertsNotifier, List<Alert>>(
  AlertsNotifier.new,
);

final alertsPrefsProvider = NotifierProvider<AlertsPrefsNotifier, AlertsPrefs>(
  AlertsPrefsNotifier.new,
);
