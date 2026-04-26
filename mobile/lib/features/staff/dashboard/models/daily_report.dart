class DailyReport {
  final String date;
  final double totalRevenue;
  final double cashRevenue;
  final double transferRevenue;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int refundedOrders;
  final double totalRefundedAmount;
  final double completionRate;
  final double cancelRate;
  final double avgOrderValue;
  final List<HourlySales> hourlySales;
  final List<TopProduct> topProducts;

  const DailyReport({
    required this.date,
    required this.totalRevenue,
    required this.cashRevenue,
    required this.transferRevenue,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.refundedOrders,
    required this.totalRefundedAmount,
    required this.completionRate,
    required this.cancelRate,
    required this.avgOrderValue,
    required this.hourlySales,
    required this.topProducts,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      date: json['date'] as String,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      cashRevenue: (json['cashRevenue'] as num? ?? 0).toDouble(),
      transferRevenue: (json['transferRevenue'] as num? ?? 0).toDouble(),
      totalOrders: (json['totalOrders'] as num).toInt(),
      completedOrders: (json['completedOrders'] as num).toInt(),
      cancelledOrders: (json['cancelledOrders'] as num? ?? 0).toInt(),
      refundedOrders: (json['refundedOrders'] as num? ?? 0).toInt(),
      totalRefundedAmount: (json['totalRefundedAmount'] as num? ?? 0).toDouble(),
      completionRate: (json['completionRate'] as num? ?? 0).toDouble(),
      cancelRate: (json['cancelRate'] as num? ?? 0).toDouble(),
      avgOrderValue: (json['avgOrderValue'] as num).toDouble(),
      hourlySales: (json['hourlySales'] as List<dynamic>? ?? [])
          .map((e) => HourlySales.fromJson(e as Map<String, dynamic>))
          .toList(),
      topProducts: (json['topProducts'] as List<dynamic>)
          .map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TopProduct {
  final String productName;
  final String variantName;
  final String? imageUrl;
  final int totalQuantity;
  final double totalRevenue;

  const TopProduct({
    required this.productName,
    required this.variantName,
    this.imageUrl,
    required this.totalQuantity,
    required this.totalRevenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productName: json['productName'] as String,
      variantName: json['variantName'] as String,
      imageUrl: json['imageUrl'] as String?,
      totalQuantity: (json['totalQuantity'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
    );
  }
}

class HourlySales {
  final int hour;
  final double revenue;
  final int orderCount;

  const HourlySales({
    required this.hour,
    required this.revenue,
    required this.orderCount,
  });

  factory HourlySales.fromJson(Map<String, dynamic> json) {
    return HourlySales(
      hour: (json['hour'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
      orderCount: (json['orderCount'] as num).toInt(),
    );
  }
}
