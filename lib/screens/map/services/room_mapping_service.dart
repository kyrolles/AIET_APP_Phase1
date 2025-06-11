/// Service for mapping display room names to schedule file identifiers
class RoomMappingService {
  
  /// Maps display room names (as shown on the map) to schedule file names
  static const Map<String, String> _roomMapping = {
    // Building A - Floor 0
    'M1': 'M1',
    'M2': 'M2', 
    'M3': 'M3',
    'CR1': 'CR1',
    'CR2': 'CR2',
    'CR3': 'CR3',
    'CR4': 'CR4',
    'DH': 'DH', // Assuming there's a DH.json file
    'B17': 'A-0-17',
    'B19': 'A-0-19',
    'B20': 'A-0-20',
    'B23': 'A-0-23', // Assuming this exists
    'B24': 'A-0-24', // Assuming this exists
    'B31': 'A-0-31',
    'B21': 'A-0-21',
    
    // Building A - Floor M (Mezzanine)
    'LR1': 'LR1',
    'CR5': 'CR5',
    'CR6': 'CR6',
    'CR7': 'CR7',
    'CR8': 'CR8',
    'B12': 'A-M-12', // Assuming M floor labs use A-M prefix
    'B14': 'A-M-14', // Assuming this exists
    'B13': 'A-M-13',
    
    // Building A - Floor 3
    'M4': 'M4',
    'M5': 'M5',
    'M6': 'M6',
    'CR9': 'CR9',
    'CR10': 'CR10',
    'CR11': 'CR11',
    'CR12': 'CR12',
    'CR13': 'CR13',
    'B4': 'A-3-04', // Assuming this exists
    // Note: B12, B13, B14, B16, B17, B18 on floor 3 may need different mapping
    'B16': 'A-3-16',
    'B18': 'A-3-18',
    
    // Building B rooms
    'shbana': 'B-0-shbana', // Assuming this exists
    'M7': 'M7',
    'M8': 'M8',
    'B05': 'B-1-05',
    'B06': 'B-1-06',
    'M9': 'M9',
    'M10': 'M10',
    'M11': 'M11',
    'B04': 'B-2-04',
    'LR2': 'LR2',
    'B07': 'B-3-07',
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
    'A-0-17',
    'A-0-19', 
    'A-0-20',
    'A-0-21',
    'A-0-31',
    'A-3-12',
    'A-3-13',
    'A-3-14',
    'A-3-16',
    'A-3-17',
    'A-3-18',
    'A-M-12',
    'A-M-13',
    'B-1-05',
    'B-1-06',
    'B-2-04',
    'B-2-05',
    'B-3-06',
    'B-3-07',
    'B-4-06',
    'B-4-07',
    'B-4-08',
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
    'LR1',
    'LR2',
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
      return _roomMapping.keys
          .where((room) => _roomMapping[room]!.startsWith('A-') || 
                          _roomMapping[room]!.startsWith('M') ||
                          _roomMapping[room]!.startsWith('CR') ||
                          _roomMapping[room]!.startsWith('LR'))
          .toList();
    } else if (building == 'B') {
      return _roomMapping.keys
          .where((room) => _roomMapping[room]!.startsWith('B-'))
          .toList();
    }
    return [];
  }
}
