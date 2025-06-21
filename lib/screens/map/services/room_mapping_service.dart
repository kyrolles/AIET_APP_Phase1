/// Service for mapping display room names to schedule file identifiers
class RoomMappingService {
  /// Maps display room names (as shown on the map) to schedule file names
  /// Organized by building and floor for better maintainability
  static const Map<String, String> _roomMapping = {
    // =====================================================
    // BUILDING A - GROUND FLOOR (Floor 0)
    // =====================================================
    // Meeting Rooms
    'M1': 'M1',
    'M2': 'M2',
    'M3': 'M3',

    // Classrooms Ground Floor
    'CR1': 'CR1',
    'CR2': 'CR2',
    'CR3': 'CR3',
    'CR4': 'CR4',

    // Labs Ground Floor (B prefix rooms)
    'B11': 'A-0-11', // Available schedule file
    'B17': 'A-0-17',
    'B19': 'A-0-19',
    'B20': 'A-0-20',
    'B21': 'A-0-21',
    'B31': 'A-0-31',

    // =====================================================
    // BUILDING A - MEZZANINE FLOOR (Floor M)
    // =====================================================
    // Lecture Room
    'LR1': 'LR1',

    // Classrooms Mezzanine Floor
    'CR5': 'CR5',
    'CR6': 'CR6',
    'CR7': 'CR7',
    'CR8': 'CR8',

    // Labs Mezzanine Floor
    'B12': 'A-M-12',
    'B13': 'A-M-13',

    // =====================================================
    // BUILDING A - THIRD FLOOR (Floor 3)
    // =====================================================
    // Meeting Rooms
    'M4': 'M4',
    'M5': 'M5',
    'M6': 'M6',

    // Classrooms Third Floor
    'CR9': 'CR9',
    'CR10': 'CR10',
    'CR11': 'CR11',
    'CR12': 'CR12',
    'CR13': 'CR13',

    // Labs Third Floor
    'B12_F3': 'A-3-12', // Different B12 on floor 3
    'B13_F3': 'A-3-13', // Different B13 on floor 3
    'B14': 'A-3-14',
    'B16': 'A-3-16',
    'B17_F3': 'A-3-17', // Different B17 on floor 3
    'B18': 'A-3-18',

    // =====================================================
    // BUILDING B - ALL FLOORS
    // =====================================================
    // Meeting Rooms in Building B
    'M7': 'M7',
    'M8': 'M8',
    'M9': 'M9',
    'M10': 'M10',
    'M11': 'M11',

    // Lecture Room in Building B
    'LR2': 'LR2',

    // Labs Building B - Floor 1
    'B05': 'B-1-05',
    'B06': 'B-1-06',

    // Labs Building B - Floor 2
    'B04': 'B-2-04',
    'B05_F2': 'B-2-05', // Different B05 on floor 2

    // Labs Building B - Floor 3
    'B06_F3': 'B-3-06', // Different B06 on floor 3
    'B07': 'B-3-07',

    // Labs Building B - Floor 4
    'B06_F4': 'B-4-06', // Different B06 on floor 4
    'B07_F4': 'B-4-07', // Different B07 on floor 4
    'B08': 'B-4-08',
  };

  /// Gets the schedule file identifier for a display room name
  ///
  /// [displayName] - The room name as shown on the map (e.g., 'B17', 'M1')
  /// Returns the schedule file identifier or the original name if no mapping exists
  static String getScheduleId(String displayName) {
    return _roomMapping[displayName] ?? displayName;
  }

  /// Gets the display name for a schedule file identifier
  ///
  /// [scheduleId] - The schedule file identifier (e.g., 'A-0-17', 'M1')
  /// Returns the display name or the original ID if no reverse mapping exists
  static String getDisplayName(String scheduleId) {
    for (final entry in _roomMapping.entries) {
      if (entry.value == scheduleId) {
        return entry.key;
      }
    }
    return scheduleId;
  }

  /// Checks if a room has schedule data available
  ///
  /// [displayName] - The room name as shown on the map
  /// Returns true if schedule data should be available for this room
  static bool hasScheduleData(String displayName) {
    final scheduleId = getScheduleId(displayName);
    // Check against known schedule files
    return _availableScheduleFiles.contains(scheduleId);
  }

  /// List of available schedule files (based on assets/scadules directory)
  static const Set<String> _availableScheduleFiles = {
    // Building A - Ground Floor Labs
    'A-0-11',
    'A-0-17',
    'A-0-19',
    'A-0-20',
    'A-0-21',
    'A-0-31',

    // Building A - Mezzanine Floor Labs
    'A-M-12',
    'A-M-13',

    // Building A - Third Floor Labs
    'A-3-12',
    'A-3-13',
    'A-3-14',
    'A-3-16',
    'A-3-17',
    'A-3-18',

    // Building B Labs
    'B-1-05',
    'B-1-06',
    'B-2-04',
    'B-2-05',
    'B-3-06',
    'B-3-07',
    'B-4-06',
    'B-4-07',
    'B-4-08',

    // Classrooms
    'CR1',
    'CR2',
    'CR3',
    'CR4',
    'CR5',
    'CR6',
    'CR7',
    'CR8',
    'CR9',
    'CR10',
    'CR11',
    'CR12',
    'CR13',

    // Lecture Rooms
    'LR1',
    'LR2',

    // Meeting Rooms
    'M1',
    'M2',
    'M3',
    'M4',
    'M5',
    'M6',
    'M7',
    'M8',
    'M9',
    'M10',
    'M11',
  };

  /// Gets all rooms for a specific building
  ///
  /// [building] - 'A' or 'B'
  /// Returns a list of display names for rooms in that building
  static List<String> getRoomsForBuilding(String building) {
    if (building == 'A') {
      return _roomMapping.keys.where((room) {
        final scheduleId = _roomMapping[room]!;
        return scheduleId.startsWith('A-') ||
            scheduleId.startsWith('M') ||
            scheduleId.startsWith('CR') ||
            scheduleId == 'LR1';
      }).toList();
    } else if (building == 'B') {
      return _roomMapping.keys.where((room) {
        final scheduleId = _roomMapping[room]!;
        return scheduleId.startsWith('B-') ||
            (scheduleId.startsWith('M') &&
                ['M7', 'M8', 'M9', 'M10', 'M11'].contains(scheduleId)) ||
            scheduleId == 'LR2';
      }).toList();
    }
    return [];
  }

  /// Gets all mapped rooms
  ///
  /// Returns a list of all display room names
  static List<String> getAllRooms() {
    return _roomMapping.keys.toList();
  }
}
