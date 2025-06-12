/// Utility functions for processing schedule data
class ScheduleDataUtils {
  /// Extract instructor name from schedule entry, handling both singular and plural field names
  static String extractInstructor(Map<String, dynamic> scheduleEntry) {
    // Check for 'teachers' (plural) field first
    dynamic teachersField = scheduleEntry['teachers'];
    // If not found, check for 'teacher' (singular) field
    teachersField ??= scheduleEntry['teacher'];

    if (teachersField != null) {
      if (teachersField is List) {
        if (teachersField.isNotEmpty) {
          return teachersField.join(', ');
        }
      } else {
        return teachersField.toString();
      }
    }

    return 'Unknown Instructor';
  }

  /// Extract groups from schedule entry, handling both singular and plural field names
  static String extractGroups(Map<String, dynamic> scheduleEntry) {
    // Check for 'groups' (plural) field first
    dynamic groupsField = scheduleEntry['groups'];
    // If not found, check for 'group' (singular) field
    groupsField ??= scheduleEntry['group'];

    if (groupsField != null) {
      if (groupsField is List) {
        if (groupsField.isNotEmpty) {
          return groupsField.join(', ');
        }
      } else {
        return groupsField.toString();
      }
    }

    return '';
  }

  /// Extract subject name from schedule entry
  static String extractSubjectName(Map<String, dynamic> scheduleEntry) {
    return scheduleEntry['subject_name'] ?? 'Unknown Subject';
  }

  /// Check if a period has a scheduled class
  static bool hasPeriodScheduled(
      List<Map<String, dynamic>> daySchedule, int period) {
    return daySchedule.any(
        (entry) => int.tryParse(entry['period']?.toString() ?? '0') == period);
  }

  /// Get schedule entry for a specific period
  static Map<String, dynamic> getScheduleForPeriod(
      List<Map<String, dynamic>> daySchedule, int period) {
    return daySchedule.firstWhere(
      (entry) => int.tryParse(entry['period']?.toString() ?? '0') == period,
      orElse: () => <String, dynamic>{},
    );
  }
}
