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
  final List<String> departments;
  final List<String> years;

  AnnouncementData({
    required this.title,
    required this.description,
    required this.authorName,
    required this.authorEmail,
    required this.authorRole,
    this.imageFile,
    this.pdfFile,
    required this.departments,
    required this.years,
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
      final String? pdfFileName =
          data.pdfFile?.path.split(Platform.pathSeparator).last;
      final DateTime now = DateTime.now();

      // Create the composite targetAudience field
      List<String> targetAudience = [];

      // Add combinations of department and year
      if (data.departments.isNotEmpty && data.years.isNotEmpty) {
        for (String dept in data.departments) {
          for (String yr in data.years) {
            targetAudience.add('${dept}_$yr');
          }
        }
      } else if (data.departments.isNotEmpty) {
        // Only departments are provided
        for (String dept in data.departments) {
          targetAudience.add(dept);
        }
      } else if (data.years.isNotEmpty) {
        // Only years are provided
        for (String yr in data.years) {
          targetAudience.add(yr);
        }
      } else {
        targetAudience.add('global');
      }

      // Add global flag if both lists are empty
      final bool isGlobal = data.departments.isEmpty && data.years.isEmpty;

      await _firestore.collection('announcements').add({
        'title': data.title.trim(),
        'text': data.description.trim(),
        'timestamp': Timestamp.fromDate(now),
        'author': data.authorName,
        'email': data.authorEmail,
        'role': data.authorRole,
        'imageBase64': imageBase64,
        'pdfBase64': pdfBase64,
        'pdfFileName': pdfFileName,
        'departments': data.departments,
        'years': data.years,
        'targetAudience': targetAudience, // Add the composite field
        'isGlobal': isGlobal, // Add a simple flag for global announcements
      });

      // Subscribe to the announcements topic
      await _subscribeToAnnouncementsTopic();

      if (kDebugMode) {
        print('Announcement posted successfully');
        print('Target audience: $targetAudience');
      }
    } catch (e) {
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
