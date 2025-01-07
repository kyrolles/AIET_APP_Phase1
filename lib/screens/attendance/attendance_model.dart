import 'package:cloud_firestore/cloud_firestore.dart';

enum PeriodNumber { p1, p2, p3, p4 }

class AttendanceModel {
  final String professor;
  final String courseID;
  final PeriodNumber periodNumber;
  final Timestamp startTime;
  final Timestamp endTime;
  final List<Student> students;

  AttendanceModel({
    required this.professor,
    required this.courseID,
    required this.students,
    required this.endTime,
    required this.periodNumber,
    required this.startTime,
  });

  factory AttendanceModel.fromJson(jsonData) {
    return AttendanceModel(
      professor: jsonData['professor'],
      courseID: jsonData['courseID'],
      startTime: jsonData['startTime'],
      endTime: jsonData['endTime'],
      periodNumber: jsonData['periodNumber'],
      students: getAllStudents(jsonData['listOfStudents']),
    );
  }
}

class Student {
  final String name;
  final String id;
  final String year;

  Student({
    required this.name,
    required this.id,
    required this.year,
  });

  factory Student.fromJson(jsonData) {
    return Student(
      name: jsonData["studentName"],
      id: jsonData['studentId'],
      year: jsonData['studentYear'],
    );
  }
}

List<Student> getAllStudents(List<dynamic> jsonData) {
  List<Student> students = [];
  for (var i = 0; i < jsonData.length; i++) {
    students.add(Student(
        name: jsonData[i]["studentName"],
        id: jsonData[i]['studentId'],
        year: jsonData[i]['studentYear']));
  }
  return students;
}
