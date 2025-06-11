import 'package:cloud_firestore/cloud_firestore.dart';

enum PeriodNumber { p1, p2, p3, p4 }

class AttendanceModel {
  final String id;
  final String subjectName;
  final String period;
  final String? profName;
  final String? timestamp;
  final String? status;
  final String? approvalTimestamp; 
  final List<Map<String, dynamic>>? studentsList;
  final Map<String, dynamic>? data;
  final String? className; 

  AttendanceModel({
    required this.id,
    required this.subjectName,
    required this.period,
    this.profName,
    this.timestamp,
    this.status,
    this.approvalTimestamp, 
    this.studentsList,
    this.data,
    this.className,  
  });

  factory AttendanceModel.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    List<Map<String, dynamic>>? students;
    if (data.containsKey('studentsList')) {
      students = List<Map<String, dynamic>>.from(data['studentsList']);
    } else if (data.containsKey('studentList')) {
      students = List<Map<String, dynamic>>.from(data['studentList']);
    }
    
    return AttendanceModel(
      id: doc.id,
      subjectName: data['subjectName'] ?? '',
      period: data['period'] ?? '',
      profName: data['profName'],
      timestamp: data['timestamp'],
      status: data['status'],
      approvalTimestamp: data['approvalTimestamp'],
      studentsList: students,
      data: data,
      className: data['className'] ?? '', 
    );
  }
}