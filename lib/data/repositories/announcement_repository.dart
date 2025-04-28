import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

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
  final FirebaseMessaging _messaging;

  AnnouncementRepository({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

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

      // Subscribe to the announcements topic (ensure users receive notifications)
      await _subscribeToAnnouncementsTopic();
      
      if (kDebugMode) {
        print('Announcement posted successfully');
      }

    } catch (e) {
      // Re-throw the exception to be caught by the controller
      if (kDebugMode) {
        print('Error in AnnouncementRepository.postAnnouncement: $e');
      }
      throw Exception('Failed to post announcement: ${e.toString()}');
    }
  }

  // Subscribe the device to the 'announcements' topic to receive notifications
  Future<void> _subscribeToAnnouncementsTopic() async {
    try {
      await _messaging.subscribeToTopic('announcements');
      if (kDebugMode) {
        print('Successfully subscribed to announcements topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to announcements topic: $e');
      }
      // We don't throw here to avoid failing the announcement posting
    }
  }

  // Add other announcement-related methods if needed (fetch, delete, update)
} 