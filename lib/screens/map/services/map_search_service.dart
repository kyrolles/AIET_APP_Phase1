import 'dart:convert';
import 'package:flutter/services.dart';
import 'map_schedule_service.dart';

class MapSearchService {
  static Map<String, dynamic> _allSchedulesCache = {};
  static bool _isInitialized = false;

  // Initialize and cache all schedule data
  static Future<void> initialize() async {
    print('🚀 MapSearchService.initialize() called');

    if (_isInitialized) {
      print('🚀 Already initialized, skipping...');
      return;
    }

    try {
      print('🚀 Loading AssetManifest.json...');
      // Get all schedule file names from your assets/scadules folder
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final scheduleFiles = manifestMap.keys
          .where((String key) =>
              key.startsWith('assets/scadules/') && key.endsWith('.json'))
          .toList();

      print('🚀 Found ${scheduleFiles.length} schedule files: $scheduleFiles');

      if (scheduleFiles.isEmpty) {
        print('❌ No schedule files found! Check your assets/scadules/ folder');
        return;
      }

      for (final filePath in scheduleFiles) {
        try {
          print('🚀 Loading file: $filePath');
          final jsonString = await rootBundle.loadString(filePath);
          final scheduleData = json.decode(jsonString);

          // Extract file name from path
          final fileName = filePath.split('/').last.replaceAll('.json', '');
          _allSchedulesCache[fileName] = scheduleData;

          print(
              '✅ Loaded schedule file: $fileName with ${scheduleData.keys.length} rooms');
        } catch (e) {
          print('❌ Error loading schedule file $filePath: $e');
        }
      }

      _isInitialized = true;
      print(
          '🚀 MapSearchService initialized with ${_allSchedulesCache.length} room schedules');

      // Print sample data to verify structure
      if (_allSchedulesCache.isNotEmpty) {
        final firstKey = _allSchedulesCache.keys.first;
        final firstSchedule = _allSchedulesCache[firstKey];
        print('📋 Sample data from $firstKey: ${firstSchedule?.keys}');
      }
    } catch (e) {
      print('❌ Error initializing MapSearchService: $e');
    }
  }

  // Main search function
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

    print(
        'Searching for: "$query" on $dayName, Week: $weekType, Period: $currentPeriod');

    final List<SearchResult> results = [];

    // Search through all cached schedules
    for (final entry in _allSchedulesCache.entries) {
      final fileName = entry.key;
      final scheduleData = entry.value as Map<String, dynamic>;

      // Each file contains one or more rooms
      for (final roomName in scheduleData.keys) {
        final sessions = scheduleData[roomName] as List<dynamic>;

        for (final sessionData in sessions) {
          final session = sessionData as Map<String, dynamic>;

          // Check if session matches the target day and week type
          if (!_isSessionRelevant(session, dayName, weekType)) continue;

          // Check for matches in this session
          final matches = _findMatches(session, normalizedQuery);
          if (matches.isNotEmpty) {
            results.add(SearchResult(
              roomName: roomName,
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

    print('Found ${results.length} search results');

    // Sort by relevance (current period first, then by score)
    results.sort((a, b) {
      if (a.isCurrentPeriod && !b.isCurrentPeriod) return -1;
      if (!a.isCurrentPeriod && b.isCurrentPeriod) return 1;
      return b.relevanceScore.compareTo(a.relevanceScore);
    });

    return results;
  }

  // Check if session is relevant for the target day and week
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

  // Find all matches in a session
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

    // Check subject code
    final subject = session['subject']?.toString() ?? '';
    if (subject.toLowerCase().contains(query)) {
      matches.add('Subject: $subject');
    }

    // Check subject name
    final subjectName = session['subject_name']?.toString() ?? '';
    if (subjectName.toLowerCase().contains(query)) {
      matches.add('Subject: $subjectName');
    }

    return matches;
  }

  // Smart name matching for teachers - improved for full names
  static bool _nameMatches(String fullName, String query) {
    final normalizedName = fullName.toLowerCase();
    final normalizedQuery = query.toLowerCase();

    // Direct substring match - this should catch most cases
    if (normalizedName.contains(normalizedQuery)) return true;

    // Remove common titles for cleaner comparison
    final cleanedName = _removeCommonTitles(normalizedName);
    final cleanedQuery = _removeCommonTitles(normalizedQuery);

    // Check cleaned versions
    if (cleanedName.contains(cleanedQuery)) return true;

    // Split into words for flexible matching
    final nameWords = cleanedName.split(RegExp(r'[\s.]+'));
    final queryWords = cleanedQuery.split(RegExp(r'[\s.]+'));

    // For longer queries (full names), use flexible matching
    if (queryWords.length >= 2) {
      int matchedWords = 0;

      for (final queryWord in queryWords) {
        if (queryWord.length >= 2) {
          // Check if this query word appears in any name word
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

      // If we found most of the query words, it's a match
      // For "dr reda el shistawy" -> we need at least 3 out of 4 words
      double matchRatio = matchedWords / queryWords.length;
      if (matchRatio >= 0.6) {
        // 60% of words must match
        return true;
      }
    } else {
      // Single word matching - keep the existing logic
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

  // Improved title removal to handle more cases
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

    // Remove titles from the beginning with better regex
    for (final title in titles) {
      // Handle "Dr." "Dr " "DR." "dr" etc.
      cleaned = cleaned.replaceFirst(
        RegExp('^$title\\.?\\s+', caseSensitive: false),
        '',
      );
    }

    return cleaned.trim();
  }

  // Calculate relevance score
  static double _calculateRelevanceScore(
      List<String> matches, Map<String, dynamic> session, int currentPeriod) {
    double score = 0.0;
    final sessionPeriod = int.tryParse(session['period'].toString()) ?? 0;

    // Boost score for current period
    if (sessionPeriod == currentPeriod) score += 10.0;

    // Boost for next period
    if (sessionPeriod == currentPeriod + 1) score += 5.0;

    // Score based on match types
    for (final match in matches) {
      if (match.startsWith('Teacher:')) score += 5.0;
      if (match.startsWith('Group:')) score += 4.0;
      if (match.startsWith('Subject:')) score += 3.0;
    }

    // Boost for multiple matches
    score += matches.length * 0.5;

    return score;
  }

  static String _getWeekType(DateTime date) {
    // Simple implementation - you can adjust based on your academic calendar
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

// Search result model
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
