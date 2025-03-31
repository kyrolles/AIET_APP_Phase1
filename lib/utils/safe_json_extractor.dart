import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

/// Safely extracts data from Firestore DocumentSnapshot
class SafeDocumentSnapshot {
  /// Safely get a field from a DocumentSnapshot, returning defaultValue if the field doesn't exist
  static T getField<T>(DocumentSnapshot doc, String fieldName, T defaultValue) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return defaultValue;
      return data.containsKey(fieldName) ? data[fieldName] as T : defaultValue;
    } catch (e) {
      log("Error accessing field '$fieldName': $e");
      return defaultValue;
    }
  }
  
  /// Safely get a field from a Firestore document data map
  static T getMapField<T>(Map<String, dynamic>? data, String fieldName, T defaultValue) {
    if (data == null) return defaultValue;
    try {
      return data.containsKey(fieldName) ? data[fieldName] as T : defaultValue;
    } catch (e) {
      log("Error accessing field '$fieldName' from map: $e");
      return defaultValue;
    }
  }
  
  /// Safely check if a field exists in a DocumentSnapshot
  static bool hasField(DocumentSnapshot doc, String fieldName) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return false;
      return data.containsKey(fieldName);
    } catch (e) {
      log("Error checking field '$fieldName': $e");
      return false;
    }
  }
} 