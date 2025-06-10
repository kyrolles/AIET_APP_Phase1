/// Utility functions for time-related operations
class TimeUtils {
  /// Check if selected date is today
  static bool isToday(DateTime selectedDate) {
    final now = DateTime.now();
    return now.year == selectedDate.year &&
        now.month == selectedDate.month &&
        now.day == selectedDate.day;
  }

  /// Format date to display string
  static String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return "${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}";
  }

  /// Get current period status text
  static String getCurrentPeriodStatus(
      DateTime selectedDate, int currentPeriod) {
    if (!isToday(selectedDate)) {
      return "Schedule for ${formatDate(selectedDate)}";
    }

    if (currentPeriod == 0) {
      return "Schedule for Today (Currently: Break Time)";
    } else {
      return "Schedule for Today (Currently: Period $currentPeriod)";
    }
  }
}
