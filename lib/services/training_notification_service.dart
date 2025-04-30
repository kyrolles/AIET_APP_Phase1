import 'dart:developer' as dev;
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// A comprehensive service to handle all training notification operations
///
/// This service combines functionalities for:
/// 1. Updating training request statuses to trigger notifications
/// 2. Processing received notifications
/// 3. Handling notification tap events
/// 4. Updating local training data when notifications are received
class TrainingNotificationService {
  // Singleton pattern implementation
  static final TrainingNotificationService _instance = TrainingNotificationService._internal();
  
  factory TrainingNotificationService() {
    return _instance;
  }
  
  TrainingNotificationService._internal();
  
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // MARK: - Helper Methods for Triggering Notifications
  
  /// Updates a training request status to trigger a notification
  /// 
  /// When updating a training request status to 'Done' or 'Rejected',
  /// use this method to ensure the cloud function is triggered correctly.
  /// 
  /// Parameters:
  /// - [requestId]: The ID of the request document to update
  /// - [status]: The new status ('Done' or 'Rejected')
  /// - [trainingScore]: The number of days to add to training (if status is 'Done')
  /// - [comment]: Optional comment about the request
  Future<void> updateTrainingRequestStatus({
    required String requestId,
    required String status,
    required int trainingScore,
    String comment = '',
  }) async {
    try {
      // Log detailed information about the update
      dev.log('======= UPDATING TRAINING REQUEST STATUS =======');
      dev.log('RequestID: $requestId');
      dev.log('Status: $status');
      dev.log('Training Score: $trainingScore');
      dev.log('Comment: $comment');
      
      // Validate parameters
      if (requestId.isEmpty) {
        throw 'Request ID cannot be empty';
      }
      
      // Make sure status is set with consistent casing
      String normalizedStatus = status.trim();
      // Ensure first character is capitalized and the rest is lowercase
      if (normalizedStatus.toLowerCase() == 'done') {
        normalizedStatus = 'Done';
      } else if (normalizedStatus.toLowerCase() == 'rejected') {
        normalizedStatus = 'Rejected';
      } else {
        throw 'Status must be either "Done" or "Rejected"';
      }
      
      if (normalizedStatus == 'Done' && trainingScore <= 0) {
        throw 'Training score must be greater than 0 for accepted requests';
      }
      
      // Get reference to the request document
      final docRef = _firestore.collection('requests').doc(requestId);
      
      // Check if document exists
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        dev.log('ERROR: Document does not exist: $requestId');
        throw 'Document with ID $requestId does not exist';
      }
      
      final data = docSnapshot.data();
      dev.log('Current document data: $data');
      
      // First update all non-status fields
      dev.log('Updating non-status fields first');
      await docRef.update({
        'training_score': trainingScore,
        'comment': comment,
      });
      
      dev.log('Successfully updated non-status fields');
      
      // Then update status separately to ensure notification is triggered
      dev.log('Updating status to "$normalizedStatus"');
      await docRef.update({
        'status': normalizedStatus
      });
      
      dev.log('Status updated successfully - notification should be triggered');
      
    } catch (e) {
      dev.log('Error updating training request: $e');
      rethrow;
    }
  }
  
  // MARK: - Handler Methods for Received Notifications
  
  /// Process a training notification when received
  /// 
  /// This method is called when a training notification is received
  /// and updates the necessary UI components.
  Future<void> processNotification(Map<String, dynamic> notificationData) async {
    try {
      dev.log('Processing training notification: $notificationData');
      
      final String status = notificationData['status'] ?? '';
      final String score = notificationData['score'] ?? '0';
      final String requestId = notificationData['request_id'] ?? '';
      
      // Log for debugging
      dev.log('Training notification details:');
      dev.log('  Status: $status');
      dev.log('  Score: $score');
      dev.log('  Request ID: $requestId');
      
      // Mark notification as read in the database if we have a request ID
      if (requestId.isNotEmpty) {
        await _markNotificationAsRead(requestId);
      }
      
      // Update local training data if approved
      if (status.toLowerCase() == 'done') {
        await _updateLocalTrainingData(int.tryParse(score) ?? 0);
      }
    } catch (e) {
      dev.log('Error processing training notification: $e');
    }
  }
  
  /// Handle navigation when a training notification is tapped
  void handleNotificationTap(Map<String, dynamic> notificationData) {
    try {
      dev.log('Training notification tapped: $notificationData');
      
      // Additional processing can be added here if needed
      // For example, you might want to navigate to a specific request detail page
      // instead of the general training screen, if you have the request ID
      
      final String requestId = notificationData['request_id'] ?? '';
      if (requestId.isNotEmpty && kDebugMode) {
        dev.log('Could navigate to specific request: $requestId');
      }
    } catch (e) {
      dev.log('Error handling training notification tap: $e');
    }
  }
  
  // MARK: - Private Helper Methods
  
  /// Mark a notification as read in the database
  Future<void> _markNotificationAsRead(String requestId) async {
    try {
      // Find the notification document related to this request
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('request_id', isEqualTo: requestId)
          .where('read', isEqualTo: false)
          .get();
      
      // Update all matching notifications to read=true
      for (final doc in querySnapshot.docs) {
        await doc.reference.update({'read': true});
        dev.log('Marked notification ${doc.id} as read');
      }
    } catch (e) {
      dev.log('Error marking notification as read: $e');
    }
  }
  
  /// Update the local training data when a training request is approved
  Future<void> _updateLocalTrainingData(int trainingScore) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        dev.log('No user logged in, cannot update training data');
        return;
      }
      
      // Get the user document
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: currentUser.email)
          .limit(1)
          .get();
      
      if (userQuery.docs.isEmpty) {
        dev.log('User document not found');
        return;
      }
      
      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();
      
      // Calculate new training days
      final int currentTrainingDays = userData['training_days'] ?? 0;
      final int newTrainingDays = currentTrainingDays + trainingScore;
      
      // Update the user document
      await userDoc.reference.update({
        'training_days': newTrainingDays,
        'last_training_update': FieldValue.serverTimestamp(),
      });
      
      dev.log('Updated training days from $currentTrainingDays to $newTrainingDays');
    } catch (e) {
      dev.log('Error updating training data: $e');
    }
  }
  
  // MARK: - Testing Methods
  
  /// Tests sending a training notification by creating and updating a test request
  /// 
  /// This method is for testing purposes only and should not be used in production.
  Future<void> testTrainingNotification({
    required String studentId,
    required String studentName,
    int trainingScore = 5,
    bool acceptRequest = true,
  }) async {
    try {
      // Create a test request with 'Pending' status
      final requestRef = await _firestore.collection('requests').add({
        'student_id': studentId,
        'student_name': studentName,
        'type': 'Training',
        'status': 'Pending',
        'addressed_to': 'Test Recipient',
        'created_at': FieldValue.serverTimestamp(),
        'year': '2023/2024',
        'stamp': false,
        'file_name': 'Test Training Document',
        'comment': '',
        'training_score': 0,
        'pdfBase64': ''
      });
      
      dev.log('Created test request: ${requestRef.id}');
      
      // Wait for the document to be fully created
      await Future.delayed(const Duration(seconds: 1));
      
      // Update the status to trigger notification
      await requestRef.update({
        'training_score': trainingScore,
        'comment': acceptRequest ? 'Your training has been approved' : 'Your training was rejected',
      });
      
      await requestRef.update({
        'status': acceptRequest ? 'Done' : 'Rejected'
      });
      
      dev.log('Updated test request status to ${acceptRequest ? 'Done' : 'Rejected'}');
      dev.log('Check Firebase Functions logs for notification status');
    } catch (e) {
      dev.log('Error testing notification: $e');
    }
  }
  
  /// Manually tests if a training notification works by updating an existing request
  /// 
  /// IMPORTANT: This is only for debugging - not for normal app use.
  Future<void> debugTestNotificationOnExistingRequest(String requestId) async {
    try {
      dev.log('======= DEBUGGING NOTIFICATION =======');
      dev.log('RequestID: $requestId');
      
      // Get reference to the request document
      final docRef = _firestore.collection('requests').doc(requestId);
      
      // Check if document exists
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        dev.log('ERROR: Document does not exist: $requestId');
        throw 'Document with ID $requestId does not exist';
      }
      
      final data = docSnapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        dev.log('ERROR: Document data is null');
        throw 'Document data is null';
      }
      
      dev.log('Current document data: $data');
      
      // Create a random training score between 1-30
      final trainingScore = 5 + (DateTime.now().millisecondsSinceEpoch % 25);
      
      // First force status to 'Pending' if it's already Done/Rejected
      final currentStatus = data['status'] as String? ?? 'No status';
      if (currentStatus == 'Done' || currentStatus == 'Rejected') {
        dev.log('Resetting status to Pending first');
        await docRef.update({
          'status': 'Pending',
        });
        
        // Wait to ensure the status change is processed
        await Future.delayed(const Duration(seconds: 2));
      }
      
      // Update to change status
      dev.log('Updating non-status fields first');
      await docRef.update({
        'training_score': trainingScore,
        'comment': 'Test notification - updated on ${DateTime.now()}',
      });
      
      dev.log('Successfully updated non-status fields');
      
      // Then update status separately to ensure notification is triggered
      dev.log('Updating status to "Done"');
      await docRef.update({
        'status': 'Done'
      });
      
      dev.log('Debug test complete - check Firebase function logs');
      
    } catch (e) {
      dev.log('Error testing notification: $e');
      rethrow;
    }
  }
} 