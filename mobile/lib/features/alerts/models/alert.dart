import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../../../../l10n/app_localizations.dart';

enum AlertCategory { order, offer, account }
enum AlertFilter { all, unread, orders, offers, account }

class Alert {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final AlertCategory category;
  final bool isUnread;
  final String? actionLabel;
  final Color accentColor;
  final String? orderId;

  const Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.category,
    required this.isUnread,
    this.actionLabel,
    required this.accentColor,
    this.orderId,
  });

  /// Format time with l10n
  static String formatTime(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.yesterday;
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  static String? actionLabelFor(AlertCategory cat, AppLocalizations l10n) {
    switch (cat) {
      case AlertCategory.order:
        return l10n.trackOrderCta;
      case AlertCategory.offer:
        return l10n.viewOffers;
      case AlertCategory.account:
        return l10n.viewDetails;
    }
  }

  static String getCategoryLabel(AlertCategory cat, AppLocalizations l10n) {
    switch (cat) {
      case AlertCategory.order:
        return l10n.categoryOrders;
      case AlertCategory.offer:
        return l10n.categoryOffers;
      case AlertCategory.account:
        return l10n.categoryAccount;
    }
  }

  factory Alert.fromNotification(NotificationItem item) {
    final category = _mapTypeToCategory(item.type);
    String? orderId;
    if (item.data != null) {
      try {
        final parsed = jsonDecode(item.data!);
        if (parsed is Map) orderId = parsed['orderId'] as String?;
      } catch (_) {}
    }
    return Alert(
      id: item.id,
      title: item.title,
      message: item.content,
      createdAt: item.createdAt,
      category: category,
      isUnread: !item.isRead,
      orderId: orderId,
      accentColor: _colorFor(category),
    );
  }

  static AlertCategory _mapTypeToCategory(String type) {
    switch (type) {
      case 'ORDER':
      case 'SHIPPING':
        return AlertCategory.order;
      case 'PROMOTION':
        return AlertCategory.offer;
      case 'LOYALTY':
      case 'SYSTEM':
      default:
        return AlertCategory.account;
    }
  }

  static Color _colorFor(AlertCategory cat) {
    switch (cat) {
      case AlertCategory.order:
        return const Color(0xFFD4AF37);
      case AlertCategory.offer:
        return const Color(0xFFB9824A);
      case AlertCategory.account:
        return const Color(0xFF7D8F69);
    }
  }

  Alert copyWith({bool? isUnread}) {
    return Alert(
      id: id,
      title: title,
      message: message,
      createdAt: createdAt,
      category: category,
      isUnread: isUnread ?? this.isUnread,
      actionLabel: actionLabel,
      accentColor: accentColor,
      orderId: orderId,
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

  bool isToday(AppLocalizations l10n) {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }
}
