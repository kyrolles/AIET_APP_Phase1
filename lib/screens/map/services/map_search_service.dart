import 'dart:convert';
import 'package:flutter/services.dart';
import 'map_schedule_service.dart';
import 'room_mapping_service.dart';

class MapSearchService {
  static Map<String, dynamic> _allSchedulesCache = {};
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final scheduleFiles = manifestMap.keys
          .where((String key) =>
              key.startsWith('assets/scadules/') && key.endsWith('.json'))
          .toList();

      if (scheduleFiles.isEmpty) return;

      for (final filePath in scheduleFiles) {
        try {
          final jsonString = await rootBundle.loadString(filePath);
          final scheduleData = json.decode(jsonString);
          final fileName = filePath.split('/').last.replaceAll('.json', '');
          _allSchedulesCache[fileName] = scheduleData;
        } catch (e) {
          // Silent fail for individual files
        }
      }

      _isInitialized = true;
    } catch (e) {
      // Silent fail for initialization
    }
  }

  static Future<List<SearchResult>> search({
    required String query,
    DateTime? searchDate,
  }) async {
    if (!_isInitialized) await initialize();
    if (query.trim().isEmpty) return [];

    final normalizedQuery = query.toLowerCase().trim();
    final targetDate = searchDate ?? DateTime.now();
    final currentPeriod = MapScheduleService.getCurrentPeriod(targetDate);
    final weekType = _getWeekType(targetDate);
    final dayName = _getDayName(targetDate);

    final List<SearchResult> results = [];

    // Search through rooms using RoomMappingService
    for (final displayRoomName in RoomMappingService.getAllRooms()) {
      final scheduleId = RoomMappingService.getScheduleId(displayRoomName);

      // Check if room name matches the query
      if (_roomNameMatches(displayRoomName, normalizedQuery)) {
        // Add room name match result
        final roomResult = _createRoomSearchResult(displayRoomName, scheduleId,
            targetDate, currentPeriod, weekType, dayName);
        if (roomResult != null) {
          results.add(roomResult);
        }
      }

      // Check schedule data if available
      if (RoomMappingService.hasScheduleData(displayRoomName) &&
          _allSchedulesCache.containsKey(scheduleId)) {
        final scheduleData =
            _allSchedulesCache[scheduleId] as Map<String, dynamic>;

        for (final roomDataKey in scheduleData.keys) {
          final sessions = scheduleData[roomDataKey] as List<dynamic>;

          for (final sessionData in sessions) {
            final session = sessionData as Map<String, dynamic>;

            if (!_isSessionRelevant(session, dayName, weekType)) continue;

            final matches = _findMatches(session, normalizedQuery);
            if (matches.isNotEmpty) {
              results.add(SearchResult(
                roomName:
                    displayRoomName, // Use display name instead of schedule ID
                session: session,
                matches: matches,
                relevanceScore:
                    _calculateRelevanceScore(matches, session, currentPeriod),
                isCurrentPeriod:
                    session['period'].toString() == currentPeriod.toString(),
              ));
            }
          }
        }
      }
    }

    // Remove duplicates and sort
    final uniqueResults = _removeDuplicateResults(results);
    uniqueResults.sort((a, b) {
      if (a.isCurrentPeriod && !b.isCurrentPeriod) return -1;
      if (!a.isCurrentPeriod && b.isCurrentPeriod) return 1;
      return b.relevanceScore.compareTo(a.relevanceScore);
    });

    return uniqueResults;
  }

  // Check if room name matches query
  static bool _roomNameMatches(String roomName, String query) {
    return roomName.toLowerCase().contains(query);
  }

  // Create a search result for room name matches
  static SearchResult? _createRoomSearchResult(
    String displayRoomName,
    String scheduleId,
    DateTime targetDate,
    int currentPeriod,
    String weekType,
    String dayName,
  ) {
    // Try to find current session for this room
    if (RoomMappingService.hasScheduleData(displayRoomName) &&
        _allSchedulesCache.containsKey(scheduleId)) {
      final scheduleData =
          _allSchedulesCache[scheduleId] as Map<String, dynamic>;

      for (final roomDataKey in scheduleData.keys) {
        final sessions = scheduleData[roomDataKey] as List<dynamic>;

        for (final sessionData in sessions) {
          final session = sessionData as Map<String, dynamic>;

          if (_isSessionRelevant(session, dayName, weekType) &&
              session['period'].toString() == currentPeriod.toString()) {
            return SearchResult(
              roomName: displayRoomName,
              session: session,
              matches: ['Room: $displayRoomName'],
              relevanceScore: 8.0, // High score for room name matches
              isCurrentPeriod: true,
            );
          }
        }
      }
    }

    // Return basic room result if no current session found
    return SearchResult(
      roomName: displayRoomName,
      session: {
        'period': currentPeriod,
        'day': dayName,
        'subject': '',
        'subject_name': '',
        'teacher': [],
        'group': [],
      },
      matches: ['Room: $displayRoomName'],
      relevanceScore: 6.0,
      isCurrentPeriod: false,
    );
  }

  // Remove duplicate results (same room, same period)
  static List<SearchResult> _removeDuplicateResults(
      List<SearchResult> results) {
    final Map<String, SearchResult> uniqueMap = {};

    for (final result in results) {
      final key = '${result.roomName}_${result.period}';
      if (!uniqueMap.containsKey(key) ||
          result.relevanceScore > uniqueMap[key]!.relevanceScore) {
        uniqueMap[key] = result;
      }
    }

    return uniqueMap.values.toList();
  }

  static bool _isSessionRelevant(
      Map<String, dynamic> session, String dayName, String weekType) {
    final sessionDay = session['day']?.toString() ?? '';
    final sessionWeekTypes = session['week_type'];

    if (sessionDay.toLowerCase() != dayName.toLowerCase()) return false;

    if (sessionWeekTypes != null) {
      List<String> weekTypeStrings = [];
      if (sessionWeekTypes is List) {
        weekTypeStrings = sessionWeekTypes.map((e) => e.toString()).toList();
      } else if (sessionWeekTypes is String) {
        weekTypeStrings = [sessionWeekTypes];
      }

      if (weekTypeStrings.isNotEmpty && !weekTypeStrings.contains(weekType)) {
        return false;
      }
    }

    return true;
  }

  static List<String> _findMatches(Map<String, dynamic> session, String query) {
    final List<String> matches = [];

    // Check teachers
    final teachersData = session['teacher'] ?? session['teachers'];
    if (teachersData != null) {
      List<String> teachers = [];
      if (teachersData is List) {
        teachers = teachersData.map((e) => e.toString()).toList();
      } else if (teachersData is String) {
        teachers = [teachersData];
      }

      for (final teacher in teachers) {
        if (_nameMatches(teacher, query)) {
          matches.add('Teacher: $teacher');
        }
      }
    }

    // Check groups
    final groupsData = session['group'] ?? session['groups'];
    if (groupsData != null) {
      List<String> groups = [];
      if (groupsData is List) {
        groups = groupsData.map((e) => e.toString()).toList();
      } else if (groupsData is String) {
        groups = [groupsData];
      }

      for (final group in groups) {
        if (group.toLowerCase().contains(query)) {
          matches.add('Group: $group');
        }
      }
    }

    // Check subjects
    final subject = session['subject']?.toString() ?? '';
    if (subject.toLowerCase().contains(query)) {
      matches.add('Subject: $subject');
    }

    final subjectName = session['subject_name']?.toString() ?? '';
    if (subjectName.toLowerCase().contains(query)) {
      matches.add('Subject: $subjectName');
    }

    return matches;
  }

  static bool _nameMatches(String fullName, String query) {
    final normalizedName = fullName.toLowerCase();
    final normalizedQuery = query.toLowerCase();

    if (normalizedName.contains(normalizedQuery)) return true;

    final cleanedName = _removeCommonTitles(normalizedName);
    final cleanedQuery = _removeCommonTitles(normalizedQuery);

    if (cleanedName.contains(cleanedQuery)) return true;

    final nameWords = cleanedName.split(RegExp(r'[\s.]+'));
    final queryWords = cleanedQuery.split(RegExp(r'[\s.]+'));

    if (queryWords.length >= 2) {
      int matchedWords = 0;
      for (final queryWord in queryWords) {
        if (queryWord.length >= 2) {
          bool foundInName = false;
          for (final nameWord in nameWords) {
            if (nameWord.contains(queryWord)) {
              foundInName = true;
              break;
            }
          }
          if (foundInName) matchedWords++;
        }
      }
      double matchRatio = matchedWords / queryWords.length;
      if (matchRatio >= 0.6) return true;
    } else {
      final queryWord = queryWords.first;
      if (queryWord.length >= 2) {
        for (final nameWord in nameWords) {
          if (nameWord.startsWith(queryWord) || nameWord.contains(queryWord)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  static String _removeCommonTitles(String name) {
    final titles = [
      'dr',
      'dr.',
      'doctor',
      'eng',
      'eng.',
      'engineer',
      'prof',
      'prof.',
      'professor',
      'mr',
      'mr.',
      'mister',
      'mrs',
      'mrs.',
      'miss',
      'ms',
      'ms.',
    ];

    String cleaned = name.trim();
    for (final title in titles) {
      cleaned = cleaned.replaceFirst(
        RegExp('^$title\\.?\\s+', caseSensitive: false),
        '',
      );
    }
    return cleaned.trim();
  }

  static double _calculateRelevanceScore(
      List<String> matches, Map<String, dynamic> session, int currentPeriod) {
    double score = 0.0;
    final sessionPeriod = int.tryParse(session['period'].toString()) ?? 0;

    if (sessionPeriod == currentPeriod) score += 10.0;
    if (sessionPeriod == currentPeriod + 1) score += 5.0;

    for (final match in matches) {
      if (match.startsWith('Room:')) score += 8.0;
      if (match.startsWith('Teacher:')) score += 5.0;
      if (match.startsWith('Group:')) score += 4.0;
      if (match.startsWith('Subject:')) score += 3.0;
    }

    score += matches.length * 0.5;
    return score;
  }

  static String _getWeekType(DateTime date) {
    final weekNumber =
        ((date.difference(DateTime(date.year, 9, 1)).inDays) / 7).floor();
    return weekNumber % 2 == 0 ? 'Even' : 'Odd';
  }

  static String _getDayName(DateTime date) {
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
}

// Rest of SearchResult class stays the same...
class SearchResult {
  final String roomName;
  final Map<String, dynamic> session;
  final List<String> matches;
  final double relevanceScore;
  final bool isCurrentPeriod;

  SearchResult({
    required this.roomName,
    required this.session,
    required this.matches,
    required this.relevanceScore,
    required this.isCurrentPeriod,
  });

  String get period => session['period']?.toString() ?? '';
  String get day => session['day']?.toString() ?? '';
  String get subject => session['subject']?.toString() ?? '';
  String get subjectName => session['subject_name']?.toString() ?? '';

  List<String> get teachers {
    final teachersData = session['teacher'] ?? session['teachers'];
    if (teachersData == null) return [];

    if (teachersData is List) {
      return teachersData.map((e) => e.toString()).toList();
    } else if (teachersData is String) {
      return [teachersData];
    }
    return [];
  }

  List<String> get groups {
    final groupsData = session['group'] ?? session['groups'];
    if (groupsData == null) return [];

    if (groupsData is List) {
      return groupsData.map((e) => e.toString()).toList();
    } else if (groupsData is String) {
      return [groupsData];
    }
    return [];
  }
}
