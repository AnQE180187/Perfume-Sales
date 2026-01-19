enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  refunded;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'Your order is being processed';
      case OrderStatus.confirmed:
        return 'Order confirmed and preparing';
      case OrderStatus.processing:
        return 'Packaging your fragrance';
      case OrderStatus.shipped:
        return 'On the way to you';
      case OrderStatus.outForDelivery:
        return 'Arriving today';
      case OrderStatus.delivered:
        return 'Successfully delivered';
      case OrderStatus.cancelled:
        return 'Order cancelled';
      case OrderStatus.refunded:
        return 'Refund processed';
    }
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String? size;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.size,
  });

  double get subtotal => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      size: json['size'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'price': price,
      'quantity': quantity,
      'size': size,
    };
  }
}

class OrderTimeline {
  final OrderStatus status;
  final DateTime timestamp;
  final String? note;

  OrderTimeline({
    required this.status,
    required this.timestamp,
    this.note,
  });

  factory OrderTimeline.fromJson(Map<String, dynamic> json) {
    return OrderTimeline(
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }
}

class Order {
  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final OrderStatus status;
  final List<OrderItem> items;
  final List<OrderTimeline> timeline;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double total;
  final String shippingAddress;
  final String? trackingNumber;
  final String? shippingProvider; // GHN, GHTK
  final String paymentMethod;

  Order({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.status,
    required this.items,
    required this.timeline,
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.total,
    required this.shippingAddress,
    this.trackingNumber,
    this.shippingProvider,
    required this.paymentMethod,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get canCancel => status == OrderStatus.pending || status == OrderStatus.confirmed;
  bool get canReorder => status == OrderStatus.delivered || status == OrderStatus.cancelled;
  bool get canTrack => trackingNumber != null && (status == OrderStatus.shipped || status == OrderStatus.outForDelivery);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
      timeline: (json['timeline'] as List).map((t) => OrderTimeline.fromJson(t)).toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      shippingFee: (json['shipping_fee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      shippingAddress: json['shipping_address'] as String,
      trackingNumber: json['tracking_number'] as String?,
      shippingProvider: json['shipping_provider'] as String?,
      paymentMethod: json['payment_method'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'items': items.map((item) => item.toJson()).toList(),
      'timeline': timeline.map((t) => t.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'shipping_fee': shippingFee,
      'total': total,
      'shipping_address': shippingAddress,
      'tracking_number': trackingNumber,
      'shipping_provider': shippingProvider,
      'payment_method': paymentMethod,
    };
  }
}
