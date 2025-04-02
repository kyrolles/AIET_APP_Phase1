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
        year: json['classIdentifier']['year'],
        department: Department.values.firstWhere(
          (d) => d.name == json['classIdentifier']['department'],
          orElse: () => Department.G,
        ),
        section: json['classIdentifier']['section'],
      ),
      isLab: json['isLab'] ?? false,
      isTutorial: json['isTutorial'] ?? false,
    );
  }
  
  // Convert session to JSON for caching
  Map<String, dynamic> toJson() {
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
  final String name; // e.g., "2nd Semester(2024-2025)"
  final List<ClassSession> sessions;
  
  Semester({
    required this.name,
    required this.sessions,
  });
  
  // Factory method to create a semester from JSON data
  factory Semester.fromJson(Map<String, dynamic> json) {
    final List<dynamic> sessionsList = json['sessions'] ?? [];
    return Semester(
      name: json['name'],
      sessions: sessionsList.map((session) => ClassSession.fromJson(session)).toList(),
    );
  }
  
  // Convert semester to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sessions': sessions.map((session) => session.toJson()).toList(),
    };
  }
} 