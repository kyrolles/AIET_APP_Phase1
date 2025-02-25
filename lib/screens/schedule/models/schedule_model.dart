import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleEntry {
  final String courseId;
  final String courseName;
  final String lecturer;
  final String room;
  final String type; // Lecture, Lab, or Section
  final String periodId; // References the period (start and end time)
  final DateTime startTime; // Now using DateTime
  final DateTime endTime;
  final String day;

  ScheduleEntry({
    required this.courseId,
    required this.courseName,
    required this.lecturer,
    required this.room,
    required this.type,
    required this.periodId,
    required this.startTime,
    required this.endTime,
    required this.day,
  });

  // Convert Firestore document to a ScheduleEntry object
  factory ScheduleEntry.fromMap(Map<String, dynamic> map) {
    return ScheduleEntry(
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      lecturer: map['lecturer'] ?? '',
      room: map['room'] ?? '',
      type: map['type'] ?? 'Lecture',
      periodId: map['periodId'] ?? '',
      startTime: (map['startTime'] as Timestamp)
          .toDate(), // Convert Firestore Timestamp to DateTime
      endTime: (map['endTime'] as Timestamp).toDate(),
      day: map['day'] ?? '',
    );
  }

  // Convert ScheduleEntry object to a Firestore document
  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'lecturer': lecturer,
      'room': room,
      'type': type,
      'periodId': periodId,
      'startTime': Timestamp.fromDate(
          startTime), // Convert DateTime to Firestore Timestamp
      'endTime': Timestamp.fromDate(endTime),
      'day': day,
    };
  }
}
