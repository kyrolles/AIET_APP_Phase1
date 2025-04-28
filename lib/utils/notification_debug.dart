import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Utility class to help debug notification issues
class NotificationDebugger {
  static final NotificationDebugger _instance = NotificationDebugger._internal();
  
  factory NotificationDebugger() {
    return _instance;
  }
  
  NotificationDebugger._internal();
  
  /// Logs FCM token and saves it to a debug collection for testing
  Future<void> logAndSaveFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final currentUser = FirebaseAuth.instance.currentUser;
      
      dev.log('======= NOTIFICATION DEBUG =======');
      dev.log('FCM Token: $fcmToken');
      
      if (fcmToken == null) {
        dev.log('Error: FCM Token is null');
        return;
      }
      
      // Save token to a dedicated debug collection
      await FirebaseFirestore.instance
          .collection('notification_debug')
          .doc('fcm_tokens')
          .set({
        'token': fcmToken,
        'timestamp': FieldValue.serverTimestamp(),
        'user_email': currentUser?.email ?? 'anonymous',
        'user_id': currentUser?.uid ?? 'anonymous'
      }, SetOptions(merge: true));
      
      dev.log('FCM token saved to debug collection');
      
      // If user is logged in, also save token to user document
      if (currentUser != null) {
        // Try to find the user in the users collection
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();
            
        if (userQuery.docs.isNotEmpty) {
          final userDoc = userQuery.docs.first;
          dev.log('Found user document: ${userDoc.id}');
          
          // Update the user's FCM token
          await userDoc.reference.update({
            'fcm_token': fcmToken
          });
          
          dev.log('FCM token saved to user document');
          
          // Log user data for debugging
          final userData = userDoc.data();
          dev.log('User data: $userData');
        } else {
          dev.log('User document not found!');
        }
      } else {
        dev.log('User not logged in');
      }
      
      dev.log('================================');
    } catch (e) {
      dev.log('Error in notification debugger: $e');
    }
  }

  /// Tests if a notification can be sent by directly triggering the function
  Future<void> testSendNotificationDirectly() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        dev.log('User not logged in, cannot test notification');
        return;
      }
      
      dev.log('Trying to send a test notification...');
      
      // Get the user details
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser.email)
          .limit(1)
          .get();
          
      if (userQuery.docs.isEmpty) {
        dev.log('User document not found!');
        return;
      }
      
      final userData = userQuery.docs.first.data();
      final fcmToken = userData['fcm_token'];
      final studentId = userData['id'];
      
      if (fcmToken == null) {
        dev.log('FCM Token not found in user document');
        return;
      }
      
      // Create a test invoice request with 'Pending' status
      final requestRef = await FirebaseFirestore.instance
          .collection('requests')
          .add({
        'student_id': studentId,
        'student_name': userData['firstName'] + ' ' + userData['lastName'],
        'type': 'Tuition Fees',
        'status': 'Pending',
        'addressed_to': 'Test Recipient',
        'created_at': FieldValue.serverTimestamp(),
        'year': userData['academicYear'] ?? '2023/2024',
        'stamp': false,
        'file_name': '',
        'comment': 'Test request',
        'training_score': 0,
        'pdfBase64': ''
      });
      
      dev.log('Created test request: ${requestRef.id}');
      
      // Wait for the document to be fully created
      await Future.delayed(const Duration(seconds: 1));
      
      // Update the status to 'Done' to trigger notification
      await requestRef.update({
        'status': 'Done'
      });
      
      dev.log('Updated test request status to Done');
      dev.log('Check Firebase Functions logs for notification status');
    } catch (e) {
      dev.log('Error testing notification: $e');
    }
  }
  
  /// Logs permission status
  Future<void> checkNotificationPermissions() async {
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      
      dev.log('Notification permission status: ${settings.authorizationStatus}');
      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          dev.log('User has granted permission');
          break;
        case AuthorizationStatus.denied:
          dev.log('User has denied permission');
          break;
        case AuthorizationStatus.notDetermined:
          dev.log('Permission not determined yet');
          break;
        case AuthorizationStatus.provisional:
          dev.log('User has granted provisional permission');
          break;
      }
    } catch (e) {
      dev.log('Error checking permissions: $e');
    }
  }
} 