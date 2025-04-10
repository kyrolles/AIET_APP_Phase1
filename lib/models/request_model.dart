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
  final String? fileStorageUrl;

  Request({
    required this.addressedTo,
    required this.comment,
    required this.fileName,
    this.pdfBase64,
    required this.stamp,
    required this.status,
    required this.studentId,
    required this.studentName,
    required this.trainingScore,
    required this.type,
    required this.year,
    required this.createdAt,
    this.fileStorageUrl,
  });

  factory Request.fromJson(dynamic json) {
    // Convert document snapshot to Map if needed
    final Map<String, dynamic> data = json is DocumentSnapshot 
        ? json.data() as Map<String, dynamic> 
        : json as Map<String, dynamic>;
    
    // Safe getter function to handle missing fields
    T? safeGet<T>(String key) {
      try {
        return data.containsKey(key) ? data[key] as T : null;
      } catch (e) {
        print('Error getting $key: $e');
        return null;
      }
    }
    
    return Request(
      addressedTo: safeGet<String>('addressed_to') ?? '',
      comment: safeGet<String>('comment') ?? '',
      fileName: safeGet<String>('file_name') ?? '',
      pdfBase64: safeGet<String>('pdfBase64'),
      stamp: safeGet<bool>('stamp') ?? false,
      status: safeGet<String>('status') ?? 'No Status',
      studentId: safeGet<String>('student_id') ?? '',
      studentName: safeGet<String>('student_name') ?? '',
      trainingScore: safeGet<int>('training_score') ?? 0,
      type: safeGet<String>('type') ?? '',
      year: safeGet<String>('year') ?? '',
      createdAt: safeGet<Timestamp>('created_at') ?? Timestamp.now(),
      fileStorageUrl: safeGet<String>('file_storage_url') ?? '',
    );
  }
}
