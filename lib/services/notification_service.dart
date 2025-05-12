import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service to handle all notification-related operations including FCM token management
///
/// This service:
/// 1. Manages FCM token lifecycle (initialization, refreshing, and cleanup)
/// 2. Handles token persistence to Firestore
/// 3. Provides methods for token validation and refreshing
class NotificationService {
  // Singleton pattern implementation
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();
  
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // Constants
  static const String _tokenPrefsKey = 'fcm_token';
  static const String _tokenTimestampKey = 'fcm_token_timestamp';
  
  // MARK: - Public Methods
  
  /// Initialize the notification service
  ///
  /// This should be called at app startup (in main.dart)
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      await _requestPermissions();
      
      // Set up token refresh listener
      _setupTokenRefreshListener();
      
      // Get and save the token if the user is logged in
      if (_auth.currentUser != null) {
        await refreshAndSaveToken();
      }
      
      dev.log('Notification service initialized');
    } catch (e) {
      dev.log('Error initializing notification service: $e');
    }
  }
  
  /// Refresh and save the FCM token to both Firestore and local storage
  ///
  /// This should be called:
  /// 1. When the user logs in
  /// 2. Periodically (e.g., weekly) to ensure the token is valid
  /// 3. When the app is reinstalled
  Future<void> refreshAndSaveToken() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        dev.log('Cannot refresh token: No user logged in');
        return;
      }
      
      // Get the latest token from Firebase Messaging
      final String? token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        dev.log('Failed to get FCM token');
        return;
      }
      
      dev.log('FCM token refreshed: ${token.substring(0, 20)}...');
      
      // Compare with locally stored token
      final prefs = await SharedPreferences.getInstance();
      final String? storedToken = prefs.getString(_tokenPrefsKey);
      
      // If token has changed, update it in Firestore
      if (token != storedToken) {
        dev.log('Token changed, updating in Firestore');
        await _updateTokenInFirestore(token);
        
        // Save the new token locally
        await prefs.setString(_tokenPrefsKey, token);
        await prefs.setInt(_tokenTimestampKey, DateTime.now().millisecondsSinceEpoch);
      } else {
        dev.log('Token unchanged, checking age');
        
        // Check if token is older than a week
        final int? timestamp = prefs.getInt(_tokenTimestampKey);
        if (timestamp == null || 
            DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp)).inDays > 7) {
          // Token is older than a week, validate and update if needed
          await _validateAndUpdateToken(token);
        }
      }
    } catch (e) {
      dev.log('Error refreshing FCM token: $e');
    }
  }
  
  /// Clean up FCM token when user logs out
  ///
  /// This should be called during the logout process
  Future<void> cleanupOnLogout() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        dev.log('No user to clean up token for');
        return;
      }
      
      // Remove token from user document
      final userDoc = await _getUserDocument();
      if (userDoc != null) {
        await userDoc.reference.update({
          'fcm_token': FieldValue.delete(),
        });
        dev.log('Removed FCM token from user document');
      }
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenPrefsKey);
      await prefs.remove(_tokenTimestampKey);
      
      dev.log('FCM token cleanup completed');
    } catch (e) {
      dev.log('Error cleaning up FCM token: $e');
    }
  }
  
  // MARK: - Private Methods
  
  /// Request notification permissions from the user
  Future<void> _requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        dev.log('Notification permissions granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        dev.log('Provisional notification permissions granted');
      } else {
        dev.log('Notification permissions declined');
      }
    } catch (e) {
      dev.log('Error requesting notification permissions: $e');
    }
  }
  
  /// Set up listener for FCM token refreshes
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((String token) async {
      dev.log('FCM token refreshed automatically');
      
      // Update token in Firestore
      if (_auth.currentUser != null) {
        await _updateTokenInFirestore(token);
        
        // Save the new token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenPrefsKey, token);
        await prefs.setInt(_tokenTimestampKey, DateTime.now().millisecondsSinceEpoch);
      }
    }, onError: (e) {
      dev.log('Error in FCM token refresh listener: $e');
    });
  }
  
  /// Update the user's FCM token in Firestore
  Future<void> _updateTokenInFirestore(String token) async {
    try {
      // Get user document
      final userDoc = await _getUserDocument();
      if (userDoc == null) {
        dev.log('User document not found for token update');
        return;
      }
      
      // Update the token in the user document
      await userDoc.reference.update({
        'fcm_token': token,
        'token_updated_at': FieldValue.serverTimestamp()
      });
      
      // Also store in devices collection for multi-device support
      await _storeInDevicesCollection(token);
      
      dev.log('FCM token updated in Firestore');
    } catch (e) {
      dev.log('Error updating FCM token in Firestore: $e');
    }
  }
  
  /// Store the token in a devices collection for multi-device support
  Future<void> _storeInDevicesCollection(String token) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;
      
      // Get user document to extract ID fields
      final userDoc = await _getUserDocument();
      if (userDoc == null) return;
      
      final userData = userDoc.data() as Map<String, dynamic>;
      
      // Find existing device entry with this token
      final devicesSnapshot = await _firestore
          .collection('devices')
          .where('token', isEqualTo: token)
          .limit(1)
          .get();
      
      // Device data to store
      final deviceData = {
        'userId': userDoc.id,
        'user_id': userData['id'] ?? currentUser.uid,
        'email': currentUser.email,
        'token': token,
        'platform': defaultTargetPlatform.name,
        'lastActive': FieldValue.serverTimestamp(),
      };
      
      if (devicesSnapshot.docs.isNotEmpty) {
        // Update existing entry
        await devicesSnapshot.docs.first.reference.update(deviceData);
      } else {
        // Create new entry
        await _firestore.collection('devices').add(deviceData);
      }
    } catch (e) {
      dev.log('Error storing token in devices collection: $e');
    }
  }
  
  /// Get the user document from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>?> _getUserDocument() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;
      
      // Try to find user by email first (most reliable)
      if (currentUser.email != null) {
        final userByEmailQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();
            
        if (userByEmailQuery.docs.isNotEmpty) {
          return userByEmailQuery.docs.first;
        }
      }
      
      // Try to find user by uid
      final userByUidQuery = await _firestore
          .collection('users')
          .where('uid', isEqualTo: currentUser.uid)
          .limit(1)
          .get();
          
      if (userByUidQuery.docs.isNotEmpty) {
        return userByUidQuery.docs.first;
      }
      
      // Try to find user by id field
      final userByIdQuery = await _firestore
          .collection('users')
          .where('id', isEqualTo: currentUser.uid)
          .limit(1)
          .get();
          
      if (userByIdQuery.docs.isNotEmpty) {
        return userByIdQuery.docs.first;
      }
      
      dev.log('User document not found in Firestore');
      return null;
    } catch (e) {
      dev.log('Error getting user document: $e');
      return null;
    }
  }
  
  /// Validate a token and update if it's invalid
  Future<void> _validateAndUpdateToken(String token) async {
    try {
      // We cannot directly validate FCM tokens from the client
      // Instead, update the token in Firestore which will trigger
      // a cloud function that uses the token, which will detect invalid tokens
      
      dev.log('Token needs validation - updating timestamp and refreshing');
      
      // Get a fresh token
      final String? freshToken = await _messaging.getToken();
      if (freshToken == null || freshToken.isEmpty) {
        dev.log('Failed to get fresh FCM token');
        return;
      }
      
      // Update even if token is the same to refresh the timestamp
      await _updateTokenInFirestore(freshToken);
      
      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenPrefsKey, freshToken);
      await prefs.setInt(_tokenTimestampKey, DateTime.now().millisecondsSinceEpoch);
      
      dev.log('Token validated and updated');
    } catch (e) {
      dev.log('Error validating token: $e');
    }
  }
} 