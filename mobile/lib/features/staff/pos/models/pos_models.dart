/// Product variant available in a store for POS.
class PosProduct {
  final String id;
  final String name;
  final String? slug;
  final PosProductBrand? brand;
  final String? family;
  final List<PosProductImage> images;
  final List<PosVariant> variants;

  const PosProduct({
    required this.id,
    required this.name,
    this.slug,
    this.brand,
    this.family,
    this.images = const [],
    this.variants = const [],
  });

  factory PosProduct.fromJson(Map<String, dynamic> json) {
    return PosProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      brand: json['brand'] != null
          ? PosProductBrand.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      family: json['family'] as String?,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => PosProductImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      variants:
          (json['variants'] as List<dynamic>?)
              ?.map((e) => PosVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class PosProductBrand {
  final String id;
  final String name;

  const PosProductBrand({required this.id, required this.name});

  factory PosProductBrand.fromJson(Map<String, dynamic> json) {
    return PosProductBrand(
      id: json['id'].toString(),
      name: json['name'] as String,
    );
  }
}

class PosProductImage {
  final String url;

  const PosProductImage({required this.url});

  factory PosProductImage.fromJson(Map<String, dynamic> json) {
    return PosProductImage(url: json['url'] as String);
  }
}

class PosVariant {
  final String id;
  final String name;
  final double price;
  final String? sku;
  final String? barcode;
  final int stock;

  const PosVariant({
    required this.id,
    required this.name,
    required this.price,
    this.sku,
    this.barcode,
    required this.stock,
  });

  factory PosVariant.fromJson(Map<String, dynamic> json) {
    return PosVariant(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A POS order (draft or completed).
class PosOrder {
  final String id;
  final String code;
  final String? storeId;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final PosOrderCustomer? user;
  final String? phone;
  final List<PosOrderItem> items;

  const PosOrder({
    required this.id,
    required this.code,
    this.storeId,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.user,
    this.phone,
    this.items = const [],
  });

  bool get isPaid => paymentStatus == 'PAID';

  factory PosOrder.fromJson(Map<String, dynamic> json) {
    return PosOrder(
      id: json['id'] as String,
      code: json['code'] as String,
      storeId: json['storeId'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      finalAmount: (json['finalAmount'] as num).toDouble(),
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      phone: json['phone'] as String?,
      user: json['user'] != null
          ? PosOrderCustomer.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => PosOrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'storeId': storeId,
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'phone': phone,
      'user': user?.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class PosOrderCustomer {
  final String id;
  final String? fullName;
  final String? phone;
  final int loyaltyPoints;
  final String? tier;

  const PosOrderCustomer({
    required this.id,
    this.fullName,
    this.phone,
    required this.loyaltyPoints,
    this.tier,
  });

  factory PosOrderCustomer.fromJson(Map<String, dynamic> json) {
    return PosOrderCustomer(
      id: json['id'] as String,
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
      loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
      tier: json['tier'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'loyaltyPoints': loyaltyPoints,
      'tier': tier,
    };
  }
}

class PosOrderItem {
  final String id;
  final String variantId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final PosOrderItemVariant? variant;

  const PosOrderItem({
    required this.id,
    required this.variantId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.variant,
  });

  factory PosOrderItem.fromJson(Map<String, dynamic> json) {
    return PosOrderItem(
      id: json['id'].toString(),
      variantId: json['variantId'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      variant: json['variant'] != null
          ? PosOrderItemVariant.fromJson(
              json['variant'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'variantId': variantId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'variant': variant?.toJson(),
    };
  }
}

class PosOrderItemVariant {
  final String id;
  final String name;
  final double price;
  final PosOrderItemProduct? product;

  const PosOrderItemVariant({
    required this.id,
    required this.name,
    required this.price,
    this.product,
  });

  factory PosOrderItemVariant.fromJson(Map<String, dynamic> json) {
    return PosOrderItemVariant(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      product: json['product'] != null
          ? PosOrderItemProduct.fromJson(
              json['product'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'product': product?.toJson(),
    };
  }
}

class PosOrderItemProduct {
  final String id;
  final String name;

  const PosOrderItemProduct({required this.id, required this.name});

  factory PosOrderItemProduct.fromJson(Map<String, dynamic> json) {
    return PosOrderItemProduct(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// Loyalty lookup result.
class LoyaltyResult {
  final bool registered;
  final String? userId;
  final String? fullName;
  final String? phone;
  final int loyaltyPoints;
  final String? tier;

  const LoyaltyResult({
    required this.registered,
    this.userId,
    this.fullName,
    this.phone,
    required this.loyaltyPoints,
    this.tier,
  });

  factory LoyaltyResult.fromJson(Map<String, dynamic> json) {
    return LoyaltyResult(
      registered: json['registered'] as bool? ?? false,
      userId: json['userId'] as String?,
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
      loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
      tier: json['tier'] as String?,
    );
  }
}

/// Local cart item (before checkout — no backend order created yet).
class LocalCartItem {
  final String variantId;
  final String variantName;
  final String productName;
  final double price;
  final int stock;
  int quantity;

  LocalCartItem({
    required this.variantId,
    required this.variantName,
    required this.productName,
    required this.price,
    required this.stock,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  /// Payload for the checkout API.
  Map<String, dynamic> toCheckoutJson() => {
    'variantId': variantId,
    'quantity': quantity,
  };
}
