import 'package:flutter/material.dart';

enum WeekType { 
  ODD, 
  EVEN 
}

enum Department {
  G, // General
  C, // Computer
  E, // Communication
  I, // Industrial
  M, // Mechatronics
}

extension DepartmentExtension on Department {
  String get fullName {
    switch (this) {
      case Department.G: return 'General';
      case Department.C: return 'Computer';
      case Department.E: return 'Communication';
      case Department.I: return 'Industrial';
      case Department.M: return 'Mechatronics';
    }
  }
  
  String get abbreviation => name;
}

class ClassIdentifier {
  final int year; // 0 for general, 1-4 for academic years
  final Department department;
  final int section;
  
  ClassIdentifier({
    required this.year,
    required this.department,
    required this.section,
  });
  
  @override
  String toString() {
    return '$year${department.name}$section';
  }
}

enum DayOfWeek {
  SATURDAY,
  SUNDAY,
  MONDAY,
  TUESDAY,
  WEDNESDAY,
  THURSDAY,
}

extension DayOfWeekExtension on DayOfWeek {
  String get shortName {
    switch (this) {
      case DayOfWeek.SATURDAY: return 'Sat.';
      case DayOfWeek.SUNDAY: return 'Sun.';
      case DayOfWeek.MONDAY: return 'Mon.';
      case DayOfWeek.TUESDAY: return 'Tue.';
      case DayOfWeek.WEDNESDAY: return 'Wed.';
      case DayOfWeek.THURSDAY: return 'Thu.';
    }
  }
}

class Period {
  final int number;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  
  const Period({
    required this.number,
    required this.startTime,
    required this.endTime,
  });
  
  String get displayName => '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
  
  static List<Period> getPeriods() {
    return [
      const Period(
        number: 1, 
        startTime: TimeOfDay(hour: 9, minute: 0),
        endTime: TimeOfDay(hour: 10, minute: 30)
      ),
      const Period(
        number: 2, 
        startTime: TimeOfDay(hour: 10, minute: 40),
        endTime: TimeOfDay(hour: 12, minute: 10)
      ),
      const Period(
        number: 3, 
        startTime: TimeOfDay(hour: 12, minute: 20),
        endTime: TimeOfDay(hour: 13, minute: 50)
      ),
      const Period(
        number: 4, 
        startTime: TimeOfDay(hour: 14, minute: 0),
        endTime: TimeOfDay(hour: 15, minute: 30)
      ),
      const Period(
        number: 5, 
        startTime: TimeOfDay(hour: 15, minute: 40),
        endTime: TimeOfDay(hour: 17, minute: 10)
      ),
    ];
  }
}

class ClassSession {
  final String id;
  final String courseName;
  final String courseCode;
  final String instructor;
  final String location; // Room number or lab code (e.g., "M5", "B3 (A-0-20)")
  final DayOfWeek day;
  final int periodNumber;
  final WeekType weekType;
  final ClassIdentifier classIdentifier;
  final bool isLab;
  final bool isTutorial;
  
  ClassSession({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.instructor,
    required this.location,
    required this.day,
    required this.periodNumber,
    required this.weekType,
    required this.classIdentifier,
    this.isLab = false,
    this.isTutorial = false,
  });
  
  // Factory method to create a session from JSON data
  factory ClassSession.fromJson(Map<String, dynamic> json) {
    // First extract the classIdentifier data
    final classIdentifierData = json['classIdentifier'] as Map<String, dynamic>;
    
    // Handle year which might be a string like 'GN', '1st', '2nd', etc.
    int year;
    if (classIdentifierData['year'] is String) {
      final String yearString = classIdentifierData['year'].toString();
      // Convert year string to int
      switch (yearString.trim().toLowerCase()) {
        case 'gn':
          year = 0;
          break;
        case '1st':
          year = 1;
          break;
        case '2nd':
          year = 2;
          break;
        case '3rd':
          year = 3;
          break;
        case '4th':
          year = 4;
          break;
        default:
          // Try to parse as int if it's just a number
          year = int.tryParse(yearString) ?? 0;
      }
    } else {
      // It's already an int
      year = classIdentifierData['year'] ?? 0;
    }
    
    // Handle department which might be a full code like 'CE', 'EME', etc.
    final String deptCode = classIdentifierData['department']?.toString() ?? 'G';
    Department department;
    
    // Convert department code to enum
    switch (deptCode.trim().toUpperCase()) {
      case 'CE':
        department = Department.C;
        break;
      case 'EME':
        department = Department.M;
        break;
      case 'IE':
        department = Department.I;
        break;
      case 'ECE':
        department = Department.E;
        break;
      case 'GN':
        department = Department.G;
        break;
      default:
        // Check if it's already a single letter matching our enum
        if (deptCode.length == 1) {
          department = Department.values.firstWhere(
            (d) => d.name == deptCode,
            orElse: () => Department.G,
          );
        } else {
          department = Department.G;
        }
    }
    
    return ClassSession(
      id: json['id'],
      courseName: json['courseName'],
      courseCode: json['courseCode'],
      instructor: json['instructor'],
      location: json['location'],
      day: DayOfWeek.values.firstWhere(
        (d) => d.name == json['day'],
        orElse: () => DayOfWeek.MONDAY,
      ),
      periodNumber: json['periodNumber'],
      weekType: WeekType.values.firstWhere(
        (w) => w.name == json['weekType'],
        orElse: () => WeekType.ODD,
      ),
      classIdentifier: ClassIdentifier(
        year: year,
        department: department,
        section: classIdentifierData['section'],
      ),
      isLab: json['isLab'] ?? false,
      isTutorial: json['isTutorial'] ?? false,
    );
  }
  
  // Convert session to JSON for caching
  Map<String, dynamic> toJson() {
    // For caching, we keep the integer representation of year and single-letter department
    // This is fine for local caching as we'll convert back to appropriate formats when sending to Firestore
    return {
      'id': id,
      'courseName': courseName,
      'courseCode': courseCode,
      'instructor': instructor,
      'location': location,
      'day': day.name,
      'periodNumber': periodNumber,
      'weekType': weekType.name,
      'classIdentifier': {
        'year': classIdentifier.year,
        'department': classIdentifier.department.name,
        'section': classIdentifier.section,
      },
      'isLab': isLab,
      'isTutorial': isTutorial,
    };
  }
}

class Semester {
  final String id; // Firestore document ID
  final String name; // e.g., "2nd Semester(2024-2025)"
  final List<ClassSession> sessions;
  final int semesterNumber; // 1 for 1st semester, 2 for 2nd semester
  final String academicYear; // e.g., "2024-2025"
  final bool isActive; // Whether this is the currently active semester
  
  Semester({
    this.id = '',
    required this.name,
    required this.sessions,
    this.semesterNumber = 2, // Default to 2nd semester
    this.academicYear = '2024-2025', // Default academic year
    this.isActive = false,
  });
  
  // Factory method to create a semester from JSON data
  factory Semester.fromJson(Map<String, dynamic> json) {
    final List<dynamic> sessionsList = json['sessions'] ?? [];
    
    // Extract semester number and academic year from name if available
    final String name = json['name'] ?? '2nd Semester(2024-2025)';
    int semesterNumber = json['semesterNumber'] ?? 2;
    String academicYear = json['academicYear'] ?? '2024-2025';
    
    // If semester number and academic year are not directly available,
    // try to parse them from the name
    if (!json.containsKey('semesterNumber') || !json.containsKey('academicYear')) {
      // Parse from name like "1st Semester(2024-2025)"
      if (name.contains('1st')) {
        semesterNumber = 1;
      } else if (name.contains('2nd')) {
        semesterNumber = 2;
      }
      
      // Extract academic year from name if in parentheses
      final RegExp yearRegex = RegExp(r'\(([0-9\-]+)\)');
      final match = yearRegex.firstMatch(name);
      if (match != null && match.groupCount >= 1) {
        academicYear = match.group(1) ?? academicYear;
      }
    }
    
    return Semester(
      id: json['id'] ?? '',
      name: name,
      semesterNumber: semesterNumber,
      academicYear: academicYear,
      isActive: json['isActive'] ?? false,
      sessions: sessionsList.map((session) => ClassSession.fromJson(session)).toList(),
    );
  }
  
  // Convert semester to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'semesterNumber': semesterNumber,
      'academicYear': academicYear,
      'isActive': isActive,
      'sessions': sessions.map((session) => session.toJson()).toList(),
    };
  }
} 