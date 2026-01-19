enum PaymentMethodType {
  vnpay,
  momo,
  cod;

  String get displayName {
    switch (this) {
      case PaymentMethodType.vnpay:
        return 'VNPay';
      case PaymentMethodType.momo:
        return 'Momo';
      case PaymentMethodType.cod:
        return 'Cash on Delivery';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethodType.vnpay:
        return 'Pay with VNPay e-wallet';
      case PaymentMethodType.momo:
        return 'Pay with Momo e-wallet';
      case PaymentMethodType.cod:
        return 'Pay when you receive';
    }
  }

  String get iconAsset {
    switch (this) {
      case PaymentMethodType.vnpay:
        return 'assets/icons/vnpay.png';
      case PaymentMethodType.momo:
        return 'assets/icons/momo.png';
      case PaymentMethodType.cod:
        return 'assets/icons/cod.png';
    }
  }

  bool get requiresOnlinePayment {
    return this == PaymentMethodType.vnpay || this == PaymentMethodType.momo;
  }
}

class PaymentMethod {
  final PaymentMethodType type;
  final bool isDefault;
  final bool isEnabled;

  PaymentMethod({
    required this.type,
    this.isDefault = false,
    this.isEnabled = true,
  });

  PaymentMethod copyWith({
    PaymentMethodType? type,
    bool? isDefault,
    bool? isEnabled,
  }) {
    return PaymentMethod(
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'is_default': isDefault,
      'is_enabled': isEnabled,
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      type: PaymentMethodType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentMethodType.cod,
      ),
      isDefault: json['is_default'] as bool? ?? false,
      isEnabled: json['is_enabled'] as bool? ?? true,
    );
  }
}

enum PaymentStatus {
  pending,
  processing,
  success,
  failed,
  cancelled;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class PaymentTransaction {
  final String id;
  final String orderId;
  final PaymentMethodType method;
  final double amount;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? transactionId; // VNPay/Momo transaction ID
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  PaymentTransaction({
    required this.id,
    required this.orderId,
    required this.method,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.transactionId,
    this.errorMessage,
    this.metadata,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      method: PaymentMethodType.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethodType.cod,
      ),
      amount: (json['amount'] as num).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      transactionId: json['transaction_id'] as String?,
      errorMessage: json['error_message'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'method': method.name,
      'amount': amount,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'transaction_id': transactionId,
      'error_message': errorMessage,
      'metadata': metadata,
    };
  }
}
