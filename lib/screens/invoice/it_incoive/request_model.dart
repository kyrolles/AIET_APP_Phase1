import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String addressedTo;
  final String comment;
  final String fileName;
  String? pdfBase64;
  final bool stamp;
  final String status;
  final String studentId;
  final String studentName;
  final int trainingScore;
  final String type;
  final String year;
  final Timestamp createdAt;

  Request(
      {required this.addressedTo,
      required this.comment,
      required this.fileName,
      required this.pdfBase64,
      required this.stamp,
      required this.status,
      required this.studentId,
      required this.studentName,
      required this.trainingScore,
      required this.type,
      required this.year,
      required this.createdAt});

  factory Request.fromJson(json) {
    return Request(
      addressedTo: json['addressed_to'],
      comment: json['comment'],
      fileName: json['file_name'],
      pdfBase64: json['pdfBase64'],
      stamp: json['stamp'],
      status: json['status'],
      studentId: json['student_id'],
      studentName: json['student_name'],
      trainingScore: json['training_score'],
      type: json['type'],
      year: json['year'],
      createdAt: json['created_at'],
    );
  }
}
