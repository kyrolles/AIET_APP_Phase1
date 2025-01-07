import 'package:cloud_firestore/cloud_firestore.dart';

enum PeriodNumber { p1, p2, p3, p4 }

class AttendanceModel {
  final String id;
  final String profEmail;
  final String profName;
  final String subjectName;
  final String period;
  final List<Student> studentsList;

  AttendanceModel({
    required this.id,
    required this.profEmail,
    required this.profName,
    required this.subjectName,
    required this.studentsList,
    required this.period,
  });

  factory AttendanceModel.fromJson(QueryDocumentSnapshot jsonData) {  // Changed to QueryDocumentSnapshot
    return AttendanceModel(
      id: jsonData.id,
      profEmail: jsonData['email'] ?? '',
      profName: jsonData['profName'] ?? '',
      subjectName: jsonData['subjectName'] ?? '',
      period: jsonData['period'] ?? '',
      studentsList: getAllStudents(jsonData['studentList'] ?? []),
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
      name: jsonData["name"],
      id: jsonData['id'],
      year: jsonData['academicYear'],
    );
  }
}

List<Student> getAllStudents(List<dynamic> jsonData) {
  List<Student> students = [];
  for (var i = 0; i < jsonData.length; i++) {
    students.add(Student(
        name: jsonData[i]["name"],
        id: jsonData[i]['id'],
        year: jsonData[i]['academicYear']));
  }
  return students;
}