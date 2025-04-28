import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

// Data class to hold announcement details for posting
class AnnouncementData {
  final String title;
  final String description;
  final String authorName;
  final String authorEmail;
  final String authorRole;
  final File? imageFile;
  final File? pdfFile;

  AnnouncementData({
    required this.title,
    required this.description,
    required this.authorName,
    required this.authorEmail,
    required this.authorRole,
    this.imageFile,
    this.pdfFile,
  });
}

class AnnouncementRepository {
  final FirebaseFirestore _firestore;

  AnnouncementRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Function to convert file to Base64 (moved from screen)
  Future<String?> _fileToBase64(File? file) async {
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> postAnnouncement(AnnouncementData data) async {
    try {
      final String? imageBase64 = await _fileToBase64(data.imageFile);
      final String? pdfBase64 = await _fileToBase64(data.pdfFile);
      final String? pdfFileName = data.pdfFile?.path.split(Platform.pathSeparator).last;
      final DateTime now = DateTime.now();

      await _firestore.collection('announcements').add({
        'title': data.title.trim(),
        'text': data.description.trim(),
        'timestamp': Timestamp.fromDate(now),
        'author': data.authorName,
        'email': data.authorEmail,
        'role': data.authorRole, // Include role from data
        'imageBase64': imageBase64,
        'pdfBase64': pdfBase64,
        'pdfFileName': pdfFileName,
      });

      // *** Point to add notification trigger ***
      // await _triggerNotification(authorName: data.authorName, title: data.title);
      // print('Notification trigger called (placeholder)');

    } catch (e) {
      // Re-throw the exception to be caught by the controller
      print('Error in AnnouncementRepository.postAnnouncement: $e');
      throw Exception('Failed to post announcement: ${e.toString()}');
    }
  }

  // Placeholder for the notification trigger function
  // In a real implementation, this would call a Cloud Function or your backend API
  // Future<void> _triggerNotification({required String authorName, required String title}) async {
  //   try {
  //     // Replace with your actual backend call (e.g., using http package or cloud_functions)
  //     print('Simulating call to backend to trigger notification for: $authorName - $title');
  //     // Example with hypothetical Cloud Function:
  //     // final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendAnnouncementNotification');
  //     // await callable.call(<String, dynamic>{
  //     //   'authorName': authorName,
  //     //   'title': title,
  //     // });
  //     await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
  //   } catch (e) {
  //     print('Error triggering notification: $e');
  //     // Decide how to handle notification trigger errors (e.g., log, ignore, retry?)
  //   }
  // }

  // Add other announcement-related methods if needed (fetch, delete, update)
} 