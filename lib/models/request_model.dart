import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String studentName;
  final String studentId;
  final String status;
  final String year;
  final String fileName;
  final String pdfBase64;
  final String trainingScore;
  final String comment;
  final String type;
  final DateTime createdAt;

  Request({
    required this.studentName,
    required this.studentId,
    required this.status,
    required this.year,
    required this.fileName,
    required this.pdfBase64,
    required this.trainingScore,
    required this.comment,
    required this.type,
    required this.createdAt,
  });

  factory Request.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // safely check for the 'created_at' field; use current time if missing
    final Timestamp? ts = data.containsKey('created_at') ? data['created_at'] as Timestamp : null;
    return Request(
      studentName: data['studentName'] ?? '',
      studentId: data['studentId'] ?? '',
      status: data['status'] ?? '',
      year: data['year'] ?? '',
      fileName: data['fileName'] ?? '',
      pdfBase64: data['pdfBase64'] ?? '',
      trainingScore: data['trainingScore'] ?? '',
      comment: data['comment'] ?? '',
      type: data['type'] ?? '',
      createdAt: ts?.toDate() ?? DateTime.now(),
    );
  }
}
