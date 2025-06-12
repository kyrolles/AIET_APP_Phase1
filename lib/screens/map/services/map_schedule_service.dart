// Building Widget Request
//     ↓
// RoomMappingService.getScheduleId("B17") → "A-0-17"
//     ↓
// MapScheduleService.isRoomOccupied(roomId: "A-0-17", ...)
//     ↓
// Loads "assets/scadules/A-0-17.json"
//     ↓
// Filters by day + week type + current period
//     ↓
// Returns true/false (occupied/available)
//     ↓
// Building Widget shows Orange/Grey color

import 'dart:convert';
import 'package:flutter/services.dart';
import 'room_mapping_service.dart';

/// Service for handling map-specific schedule data integration
class MapScheduleService {
  static const String _scheduleBasePath = 'assets/scadules/';

  // Cache for loaded schedule data to improve performance
  static final Map<String, Map<String, dynamic>> _scheduleCache = {};

  /// Fetches schedule data for a specific room
  ///
  /// [roomId] - The room identifier (e.g., 'A-0-17', 'M1', 'CR1')
  /// Returns the schedule data or null if not found
  static Future<Map<String, dynamic>?> getScheduleForRoom(String roomId) async {
    try {
      // Check cache first
      if (_scheduleCache.containsKey(roomId)) {
        return _scheduleCache[roomId];
      }

      // Load from assets
      final String filePath = '$_scheduleBasePath$roomId.json';
      final String jsonString = await rootBundle.loadString(filePath);
      final Map<String, dynamic> scheduleData = json.decode(jsonString);

      // Cache the data
      _scheduleCache[roomId] = scheduleData;

      return scheduleData;
    } catch (e) {
      print('Error loading schedule for room $roomId: $e');
      return null;
    }
  }

  /// Gets schedule entries for a specific room, day, and date
  ///
  /// [roomId] - Room identifier
  /// [day] - Day of week (e.g., 'Sunday', 'Monday')
  /// [selectedDate] - The specific date being queried
  /// [weekType] - Either 'Odd' or 'Even' week
  static Future<List<Map<String, dynamic>>> getScheduleForDay({
    required String roomId,
    required String day,
    required DateTime selectedDate,
    required String weekType,
  }) async {
    final scheduleData = await getScheduleForRoom(roomId);
    if (scheduleData == null) return [];

    // Get the room's schedule array using the room ID as key
    final List<dynamic>? roomSchedule = scheduleData[roomId];
    if (roomSchedule == null) return [];

    // Filter by day and week type
    return roomSchedule
        .where((entry) {
          final entryDay = entry['day']?.toString();
          final entryWeekTypes = entry['week_type'];

          // Check day match
          if (entryDay != day) return false;

          // Check week type match - week_type can be a list or string
          if (entryWeekTypes is List) {
            return entryWeekTypes.contains(weekType);
          } else if (entryWeekTypes is String) {
            return entryWeekTypes == weekType;
          }

          return false;
        })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  /// Checks if a room is occupied at a specific time
  ///
  /// [roomId] - Room identifier
  /// [selectedDate] - The date being checked
  /// [currentPeriod] - The current academic period (1-5)
  static Future<bool> isRoomOccupied({
    required String roomId,
    required DateTime selectedDate,
    required int currentPeriod,
  }) async {
    final day = _getDayName(selectedDate.weekday);
    final weekType = DateTimeService.getWeekType(selectedDate);

    final daySchedule = await getScheduleForDay(
      roomId: roomId,
      day: day,
      selectedDate: selectedDate,
      weekType: weekType,
    );

    // Check if any entry matches the current period
    return daySchedule.any(
        (entry) => int.tryParse(entry['period'].toString()) == currentPeriod);
  }

  /// Gets the current academic period based on time
  static int getCurrentPeriod(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final totalMinutes = hour * 60 + minute;

    // Academic periods (adjust these times as needed)
    if (totalMinutes >= 540 && totalMinutes < 630) return 1; // 9:00-10:30
    if (totalMinutes >= 640 && totalMinutes < 730) return 2; // 10:40-12:10
    if (totalMinutes >= 740 && totalMinutes < 830) return 3; // 12:20-13:50
    if (totalMinutes >= 840 && totalMinutes < 930) return 4; // 14:00-15:30
    if (totalMinutes >= 940 && totalMinutes < 1030) return 5; // 15:40-17:10

    return 0; // Break time
  }

  /// Converts weekday number to day name
  static String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  /// Clears the schedule cache (useful for memory management)
  static void clearCache() {
    _scheduleCache.clear();
  }

  /// Gets complete schedule for a room on a specific date
  Future<List<Map<String, dynamic>>> getRoomScheduleForDate(
    String roomDisplayName,
    DateTime date,
  ) async {
    try {
      final roomId = RoomMappingService.getScheduleId(roomDisplayName);
      print('Loading schedule for room: $roomDisplayName -> $roomId');

      final scheduleData = await getScheduleForRoom(roomId);
      if (scheduleData == null) {
        print('No schedule data found for room: $roomId');
        return [];
      }

      // The JSON structure is { "roomId": [...] }, not { "schedule": [...] }
      final List<dynamic>? schedule = scheduleData[roomId];
      if (schedule == null) {
        print(
            'No schedule array found for room: $roomId in data: ${scheduleData.keys}');
        return [];
      }

      final weekType = DateTimeService.getWeekType(date);
      final dayName = DateTimeService.getDayName(date);
      print('Filtering for day: $dayName, week: $weekType');

      // Filter schedule for the specific day and week type
      final daySchedule = schedule.where((entry) {
        final entryDay = entry['day']?.toString();
        final entryWeekTypes = entry['week_type'];

        // Check day match
        if (entryDay?.toLowerCase() != dayName.toLowerCase()) {
          return false;
        }

        // Check week type match - week_type can be a list or string
        if (entryWeekTypes is List) {
          return entryWeekTypes.any(
              (wt) => wt.toString().toLowerCase() == weekType.toLowerCase());
        } else if (entryWeekTypes is String) {
          return entryWeekTypes.toLowerCase() == weekType.toLowerCase();
        }

        return false;
      }).toList();

      print(
          'Found ${daySchedule.length} schedule entries for $roomDisplayName on $dayName ($weekType week)');

      // Sort by period
      daySchedule.sort((a, b) {
        final periodA = int.tryParse(a['period']?.toString() ?? '0') ?? 0;
        final periodB = int.tryParse(b['period']?.toString() ?? '0') ?? 0;
        return periodA.compareTo(periodB);
      });

      return daySchedule.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading room schedule: $e');
      return [];
    }
  }
}

/// Service for handling date/time calculations and academic calendar
class DateTimeService {
  // Academic year start date (adjust as needed)
  static DateTime academicYearStart = DateTime(2024, 9, 1); // September 1st

  /// Determines if the given date falls in an odd or even academic week
  static String getWeekType(DateTime date) {
    final daysSinceStart = date.difference(academicYearStart).inDays;
    final weekNumber = (daysSinceStart / 7).floor();
    return weekNumber % 2 == 0 ? 'Even' : 'Odd';
  }

  /// Gets day name for schedule filtering
  static String getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
  }

  /// Gets a human-readable string for the current period
  static String getPeriodString(int period) {
    switch (period) {
      case 1:
        return 'Period 1 (9:00-10:30)';
      case 2:
        return 'Period 2 (10:40-12:10)';
      case 3:
        return 'Period 3 (12:20-13:50)';
      case 4:
        return 'Period 4 (14:00-15:30)';
      case 5:
        return 'Period 5 (15:40-17:10)';
      default:
        return 'Break Time';
    }
  }

  /// Checks if the given date is a weekend
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }
}
