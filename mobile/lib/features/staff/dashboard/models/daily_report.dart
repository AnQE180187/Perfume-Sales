/// Daily KPI report returned by `GET /staff/reports/daily`.
class DailyReport {
  final String date;
  final double totalRevenue;
  final int totalOrders;
  final int completedOrders;
  final double avgOrderValue;
  final int cancelledOrders;
  final int refundedOrders;
  final double completionRate;
  final List<HourlySales> hourlySales;
  final List<TopProduct> topProducts;

  const DailyReport({
    required this.date,
    required this.totalRevenue,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.refundedOrders,
    required this.completionRate,
    required this.avgOrderValue,
    required this.hourlySales,
    required this.topProducts,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      date: json['date'] as String,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalOrders: (json['totalOrders'] as num).toInt(),
      completedOrders: (json['completedOrders'] as num).toInt(),
      cancelledOrders: (json['cancelledOrders'] as num? ?? 0).toInt(),
      refundedOrders: (json['refundedOrders'] as num? ?? 0).toInt(),
      completionRate: (json['completionRate'] as num? ?? 0).toDouble(),
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
  final int totalQuantity;
  final double totalRevenue;

  const TopProduct({
    required this.productName,
    required this.variantName,
    required this.totalQuantity,
    required this.totalRevenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productName: json['productName'] as String,
      variantName: json['variantName'] as String,
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
