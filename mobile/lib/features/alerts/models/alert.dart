import 'package:flutter/material.dart';

enum AlertCategory { order, offer, account }

enum AlertFilter { all, unread, orders, offers, account }

class Alert {
  final String id;
  final String title;
  final String message;
  final String timeLabel;
  final AlertCategory category;
  final bool isUnread;
  final String? actionLabel;
  final Color accentColor;

  const Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.category,
    required this.isUnread,
    this.actionLabel,
    required this.accentColor,
  });

  Alert copyWith({bool? isUnread}) {
    return Alert(
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

  IconData get icon {
    switch (category) {
      case AlertCategory.order:
        return Icons.local_shipping_outlined;
      case AlertCategory.offer:
        return Icons.local_offer_outlined;
      case AlertCategory.account:
        return Icons.person_outline_rounded;
    }
  }

  String get categoryLabel {
    switch (category) {
      case AlertCategory.order:
        return 'ĐƠN HÀNG';
      case AlertCategory.offer:
        return 'ƯU ĐÃI';
      case AlertCategory.account:
        return 'TÀI KHOẢN';
    }
  }

  bool get isToday =>
      timeLabel != 'Hôm qua' &&
      timeLabel != 'Thứ Ba' &&
      !timeLabel.contains('ngày trước');
}
