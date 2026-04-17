import 'package:intl/intl.dart';

class AppDateUtils {
  static String getEstimatedDeliveryRange(int minDays, int maxDays, String locale) {
    final now = DateTime.now();
    final minDate = now.add(Duration(days: minDays));
    final maxDate = now.add(Duration(days: maxDays));

    final dayFormat = DateFormat('d');
    
    // Check if month changes in the range
    if (minDate.month == maxDate.month) {
      final monthFormat = DateFormat('MMMM', locale);
      final monthStr = monthFormat.format(minDate);
      
      if (locale == 'vi') {
        return 'ngày ${dayFormat.format(minDate)} - ${dayFormat.format(maxDate)} tháng ${minDate.month}';
      } else {
        return '${dayFormat.format(minDate)} - ${dayFormat.format(maxDate)} $monthStr';
      }
    } else {
      final monthFormat = DateFormat('MMM', locale);
      final minMonthStr = monthFormat.format(minDate);
      final maxMonthStr = monthFormat.format(maxDate);

      if (locale == 'vi') {
        return 'ngày ${dayFormat.format(minDate)}/${minDate.month} - ${dayFormat.format(maxDate)}/${maxDate.month}';
      } else {
        return '${dayFormat.format(minDate)} $minMonthStr - ${dayFormat.format(maxDate)} $maxMonthStr';
      }
    }
  }
}
