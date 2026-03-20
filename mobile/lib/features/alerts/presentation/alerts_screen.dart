import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

enum _AlertFilter { all, unread, orders, offers, account }

enum _AlertCategory { order, offer, account }

class _AlertItem {
  final String id;
  final String title;
  final String message;
  final String timeLabel;
  final _AlertCategory category;
  final bool isUnread;
  final String? actionLabel;
  final Color accentColor;

  const _AlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.category,
    required this.isUnread,
    this.actionLabel,
    required this.accentColor,
  });

  _AlertItem copyWith({bool? isUnread}) {
    return _AlertItem(
      id: id,
      title: title,
      message: message,
      timeLabel: timeLabel,
      category: category,
      isUnread: isUnread ?? this.isUnread,
      actionLabel: actionLabel,
      accentColor: accentColor,
    );
  }
}

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late List<_AlertItem> _alerts;
  _AlertFilter _activeFilter = _AlertFilter.all;
  bool _orderUpdatesEnabled = true;
  bool _offerUpdatesEnabled = true;
  bool _accountAlertsEnabled = false;

  static const List<_AlertItem> _seedAlerts = [
    _AlertItem(
      id: 'ord-1',
      title: 'Đơn hàng của bạn đang được đóng gói',
      message:
          'No. 07 Velvet Rose đã vào giai đoạn hoàn thiện cuối cùng và sẽ được chuẩn bị giao trong tối nay.',
      timeLabel: '2 phút trước',
      category: _AlertCategory.order,
      isUnread: true,
      actionLabel: 'Theo dõi đơn',
      accentColor: Color(0xFFD4AF37),
    ),
    _AlertItem(
      id: 'off-1',
      title: 'Ưu đãi riêng vừa được mở',
      message:
          'Ưu đãi 12% đang chờ bạn cho lần mua nước hoa tiếp theo đến hết nửa đêm hôm nay.',
      timeLabel: '18 phút trước',
      category: _AlertCategory.offer,
      isUnread: true,
      actionLabel: 'Dùng ưu đãi',
      accentColor: Color(0xFFB9824A),
    ),
    _AlertItem(
      id: 'acc-1',
      title: 'Sản phẩm yêu thích đã có hàng lại',
      message:
          'Maison Lumiere Ambre bản 50ml đã có hàng trở lại và được giữ cho bạn trong 6 giờ tới.',
      timeLabel: 'Hôm nay, 09:24',
      category: _AlertCategory.account,
      isUnread: true,
      actionLabel: 'Xem sản phẩm',
      accentColor: Color(0xFF7D8F69),
    ),
    _AlertItem(
      id: 'ord-2',
      title: 'Đơn vị vận chuyển đã xác nhận lịch ngày mai',
      message:
          'Đơn hàng gần nhất của bạn dự kiến sẽ được giao trong khoảng 10:00 đến 13:00 và cần ký nhận.',
      timeLabel: 'Hôm qua',
      category: _AlertCategory.order,
      isUnread: false,
      actionLabel: 'Xem vận chuyển',
      accentColor: Color(0xFF8A7D6A),
    ),
    _AlertItem(
      id: 'off-2',
      title: 'Bài viết tuyển chọn mới',
      message:
          'Khám phá ba mùi hương trầm ấm cho buổi tối do chuyên gia tư vấn mùi hương tuyển chọn cho mùa mưa.',
      timeLabel: 'Thứ Ba',
      category: _AlertCategory.offer,
      isUnread: false,
      actionLabel: 'Đọc bài viết',
      accentColor: Color(0xFFA15C45),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _alerts = _seedAlerts;
  }

  List<_AlertItem> get _filteredAlerts {
    switch (_activeFilter) {
      case _AlertFilter.all:
        return _alerts;
      case _AlertFilter.unread:
        return _alerts.where((alert) => alert.isUnread).toList();
      case _AlertFilter.orders:
        return _alerts
            .where((alert) => alert.category == _AlertCategory.order)
            .toList();
      case _AlertFilter.offers:
        return _alerts
            .where((alert) => alert.category == _AlertCategory.offer)
            .toList();
      case _AlertFilter.account:
        return _alerts
            .where((alert) => alert.category == _AlertCategory.account)
            .toList();
    }
  }

  int get _unreadCount => _alerts.where((alert) => alert.isUnread).length;

  Future<void> _refreshAlerts() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _alerts = _alerts.map((alert) => alert).toList();
    });
  }

  void _markAllAsRead() {
    setState(() {
      _alerts = _alerts
          .map((alert) => alert.copyWith(isUnread: false))
          .toList();
    });
  }

  void _openAlert(_AlertItem selectedAlert) {
    setState(() {
      _alerts = _alerts
          .map(
            (alert) => alert.id == selectedAlert.id
                ? alert.copyWith(isUnread: false)
                : alert,
          )
          .toList();
    });

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AlertDetailSheet(
          alert: selectedAlert.copyWith(isUnread: false),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _filteredAlerts;

    return Scaffold(
      backgroundColor: AppTheme.ivoryBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshAlerts,
          color: AppTheme.accentGold,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TRUNG TÂM THÔNG BÁO',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.2,
                                    color: AppTheme.mutedSilver,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Thông báo của bạn',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.deepCharcoal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _unreadCount == 0
                                ? null
                                : _markAllAsRead,
                            child: Text(
                              'Đánh dấu đã đọc',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _unreadCount == 0
                                    ? AppTheme.mutedSilver
                                    : AppTheme.accentGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Theo dõi đơn hàng, ưu đãi riêng và hoạt động tài khoản trong một hộp thư gọn gàng.',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.deepCharcoal.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _AlertsHeroCard(
                        unreadCount: _unreadCount,
                        totalCount: _alerts.length,
                      ),
                      const SizedBox(height: 18),
                      _NotificationPreferencesCard(
                        orderUpdatesEnabled: _orderUpdatesEnabled,
                        offerUpdatesEnabled: _offerUpdatesEnabled,
                        accountAlertsEnabled: _accountAlertsEnabled,
                        onOrderChanged: (value) {
                          setState(() => _orderUpdatesEnabled = value);
                        },
                        onOffersChanged: (value) {
                          setState(() => _offerUpdatesEnabled = value);
                        },
                        onAccountChanged: (value) {
                          setState(() => _accountAlertsEnabled = value);
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _FilterChip(
                              label: 'Tất cả',
                              isSelected: _activeFilter == _AlertFilter.all,
                              onTap: () => setState(
                                () => _activeFilter = _AlertFilter.all,
                              ),
                            ),
                            _FilterChip(
                              label: 'Chưa đọc',
                              count: _unreadCount,
                              isSelected: _activeFilter == _AlertFilter.unread,
                              onTap: () => setState(
                                () => _activeFilter = _AlertFilter.unread,
                              ),
                            ),
                            _FilterChip(
                              label: 'Đơn hàng',
                              isSelected: _activeFilter == _AlertFilter.orders,
                              onTap: () => setState(
                                () => _activeFilter = _AlertFilter.orders,
                              ),
                            ),
                            _FilterChip(
                              label: 'Ưu đãi',
                              isSelected: _activeFilter == _AlertFilter.offers,
                              onTap: () => setState(
                                () => _activeFilter = _AlertFilter.offers,
                              ),
                            ),
                            _FilterChip(
                              label: 'Tài khoản',
                              isSelected: _activeFilter == _AlertFilter.account,
                              onTap: () => setState(
                                () => _activeFilter = _AlertFilter.account,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              if (alerts.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyAlertsState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList.list(
                    children: [
                      const _SectionLabel(title: 'Mới hôm nay'),
                      const SizedBox(height: 12),
                      for (final alert in alerts.where(
                        (item) =>
                            item.timeLabel != 'Hôm qua' &&
                            item.timeLabel != 'Thứ Ba',
                      )) ...[
                        _AlertCard(
                          alert: alert,
                          onTap: () => _openAlert(alert),
                        ),
                        const SizedBox(height: 12),
                      ],
                      const _SectionLabel(title: 'Trước đó'),
                      const SizedBox(height: 12),
                      for (final alert in alerts.where(
                        (item) =>
                            item.timeLabel == 'Hôm qua' ||
                            item.timeLabel == 'Thứ Ba',
                      )) ...[
                        _AlertCard(
                          alert: alert,
                          onTap: () => _openAlert(alert),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertsHeroCard extends StatelessWidget {
  final int unreadCount;
  final int totalCount;

  const _AlertsHeroCard({required this.unreadCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5E8D5), Color(0xFFE0C79E)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepCharcoal.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  unreadCount == 0 ? 'Bạn đã xem hết' : '$unreadCount chưa đọc',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepCharcoal,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.notifications_active_outlined,
                color: AppTheme.deepCharcoal,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Theo sát mọi chuyển động của đơn hàng và từng ưu đãi dành riêng cho bạn.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              height: 1.05,
              fontWeight: FontWeight.w600,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$totalCount cập nhật gần đây được gom lại tại đây để bạn không bỏ lỡ điều gì quan trọng.',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              height: 1.6,
              fontWeight: FontWeight.w500,
              color: AppTheme.deepCharcoal.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationPreferencesCard extends StatelessWidget {
  final bool orderUpdatesEnabled;
  final bool offerUpdatesEnabled;
  final bool accountAlertsEnabled;
  final ValueChanged<bool> onOrderChanged;
  final ValueChanged<bool> onOffersChanged;
  final ValueChanged<bool> onAccountChanged;

  const _NotificationPreferencesCard({
    required this.orderUpdatesEnabled,
    required this.offerUpdatesEnabled,
    required this.accountAlertsEnabled,
    required this.onOrderChanged,
    required this.onOffersChanged,
    required this.onAccountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _PreferenceRow(
            title: 'Cập nhật đơn hàng',
            subtitle: 'Xác nhận giao hàng, chuẩn bị đơn và thanh toán',
            value: orderUpdatesEnabled,
            onChanged: onOrderChanged,
          ),
          Divider(color: AppTheme.softTaupe.withValues(alpha: 0.8), height: 28),
          _PreferenceRow(
            title: 'Ưu đãi riêng',
            subtitle: 'Ưu đãi thành viên, gói giới hạn và mã giảm giá đã lưu',
            value: offerUpdatesEnabled,
            onChanged: onOffersChanged,
          ),
          Divider(color: AppTheme.softTaupe.withValues(alpha: 0.8), height: 28),
          _PreferenceRow(
            title: 'Cảnh báo tài khoản',
            subtitle: 'Thông báo có hàng lại và nhắc nhở hoạt động hồ sơ',
            value: accountAlertsEnabled,
            onChanged: onAccountChanged,
          ),
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepCharcoal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.mutedSilver,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch.adaptive(
          value: value,
          activeColor: AppTheme.accentGold,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? AppTheme.deepCharcoal : Colors.white,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppTheme.deepCharcoal,
                  ),
                ),
                if (count != null && count! > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accentGold
                          : AppTheme.ivoryBackground,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppTheme.deepCharcoal
                            : AppTheme.accentGold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: AppTheme.mutedSilver,
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final _AlertItem alert;
  final VoidCallback onTap;

  const _AlertCard({required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: alert.isUnread
                  ? alert.accentColor.withValues(alpha: 0.32)
                  : AppTheme.softTaupe,
            ),
            gradient: alert.isUnread
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      alert.accentColor.withValues(alpha: 0.07),
                    ],
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: alert.accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _iconForCategory(alert.category),
                  color: alert.accentColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.deepCharcoal,
                            ),
                          ),
                        ),
                        if (alert.isUnread)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: alert.accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      alert.message,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.deepCharcoal.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.ivoryBackground,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _labelForCategory(alert.category),
                                style: GoogleFonts.montserrat(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: alert.accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                alert.timeLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.mutedSilver,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (alert.actionLabel != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              alert.actionLabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.deepCharcoal,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertDetailSheet extends StatelessWidget {
  final _AlertItem alert;

  const _AlertDetailSheet({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        color: AppTheme.creamWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.softTaupe,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: alert.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                _iconForCategory(alert.category),
                color: alert.accentColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              alert.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              alert.message,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                height: 1.7,
                fontWeight: FontWeight.w500,
                color: AppTheme.deepCharcoal.withValues(alpha: 0.74),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _labelForCategory(alert.category),
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: alert.accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  alert.timeLabel,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mutedSilver,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(alert.actionLabel ?? 'Đóng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAlertsState extends StatelessWidget {
  const _EmptyAlertsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 34,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Không có thông báo trong bộ lọc này.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppTheme.deepCharcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thử bộ lọc khác hoặc bật thêm loại thông báo để khu vực này luôn hữu ích.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w500,
              color: AppTheme.mutedSilver,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconForCategory(_AlertCategory category) {
  switch (category) {
    case _AlertCategory.order:
      return Icons.local_shipping_outlined;
    case _AlertCategory.offer:
      return Icons.local_offer_outlined;
    case _AlertCategory.account:
      return Icons.favorite_border_rounded;
  }
}

String _labelForCategory(_AlertCategory category) {
  switch (category) {
    case _AlertCategory.order:
      return 'Đơn hàng';
    case _AlertCategory.offer:
      return 'Ưu đãi';
    case _AlertCategory.account:
      return 'Tài khoản';
  }
}
