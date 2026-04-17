import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/daily_report.dart';

class StaffDashboardService {
  final ApiClient _client;

  StaffDashboardService({required ApiClient client}) : _client = client;

  /// Fetch daily KPI report. [date] format: `yyyy-MM-dd`.
  Future<DailyReport> getDailyReport({String? date, String? storeId}) async {
    final response = await _client.get(
      ApiEndpoints.staffReportsDaily,
      queryParameters: {
        if (date != null) 'date': date,
        if (storeId != null) 'storeId': storeId,
      },
    );
    return DailyReport.fromJson(response.data as Map<String, dynamic>);
  }
}
