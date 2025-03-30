import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:graduation_project/services/firebase_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

/// A utility class for diagnosing and repairing Firebase issues
class FirebaseDiagnostics {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorageService _storageService = FirebaseStorageService();
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Run comprehensive Firebase diagnostics
  static Future<Map<String, bool>> runDiagnostics() async {
    final results = <String, bool>{};
    
    // Check Firebase initialization
    results['firebase_initialized'] = Firebase.apps.isNotEmpty;
    debugPrint('Firebase initialized: ${results['firebase_initialized']}');
    
    // Check Auth status
    final User? currentUser = _auth.currentUser;
    results['user_authenticated'] = currentUser != null;
    debugPrint('User authenticated: ${results['user_authenticated']}');
    if (currentUser != null) {
      debugPrint('User ID: ${currentUser.uid}');
      debugPrint('User email: ${currentUser.email}');
    }
    
    // Check Firestore
    results['firestore_working'] = await _testFirestore();
    debugPrint('Firestore working: ${results['firestore_working']}');
    
    // Check Storage root access
    results['storage_root_access'] = await _testStorageRootAccess();
    debugPrint('Storage root access: ${results['storage_root_access']}');
    
    // Check Storage nested path access
    results['storage_nested_access'] = await _testStorageNestedAccess();
    debugPrint('Storage nested access: ${results['storage_nested_access']}');
    
    return results;
  }
  
  /// Test if Firestore is accessible
  static Future<bool> _testFirestore() async {
    try {
      await _firestore.collection('test_collection').doc('test_document').set({
        'test_field': 'test_value',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      await _firestore.collection('test_collection').doc('test_document').delete();
      return true;
    } catch (e) {
      debugPrint('Error testing Firestore: $e');
      return false;
    }
  }
  
  /// Test if root level Storage access works
  static Future<bool> _testStorageRootAccess() async {
    try {
      // Create a test file
      final tempDir = await getTemporaryDirectory();
      final testFile = File('${tempDir.path}/test_${DateTime.now().millisecondsSinceEpoch}.txt');
      await testFile.writeAsString('Test content');
      
      // Upload to root level
      final ref = FirebaseStorage.instance.ref().child('test_file.txt');
      await ref.putFile(testFile);
      
      // Delete the file
      await ref.delete();
      await testFile.delete();
      
      return true;
    } catch (e) {
      debugPrint('Error testing Storage root access: $e');
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
      }
      return false;
    }
  }
  
  /// Test if nested path Storage access works
  static Future<bool> _testStorageNestedAccess() async {
    try {
      // Create a test file
      final tempDir = await getTemporaryDirectory();
      final testFile = File('${tempDir.path}/test_${DateTime.now().millisecondsSinceEpoch}.txt');
      await testFile.writeAsString('Test content');
      
      // Upload to nested path
      final ref = FirebaseStorage.instance.ref().child('test/nested/path/test_file.txt');
      await ref.putFile(testFile);
      
      // Delete the file
      await ref.delete();
      await testFile.delete();
      
      return true;
    } catch (e) {
      debugPrint('Error testing Storage nested access: $e');
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
      }
      return false;
    }
  }
  
  /// Check if Firebase Storage is working correctly
  static Future<bool> checkFirebaseStorage() async {
    try {
      return await _storageService.testStorageAccess();
    } catch (e) {
      debugPrint('Error checking Firebase Storage: $e');
      return false;
    }
  }
  
  /// Fix missing fileUrl fields in Firestore documents
  static Future<void> repairMissingFileUrlFields() async {
    try {
      debugPrint('Starting repair of missing file_url fields...');
      
      // Get all requests with pdfBase64 but potentially no fileUrl
      final querySnapshot = await _firestore.collection('requests')
          .where('pdfBase64', isNull: false)
          .get();
      
      debugPrint('Found ${querySnapshot.docs.length} documents with pdfBase64 field');
      
      // Check each document if it's missing file_url
      int fixed = 0;
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          
          // Skip if file_url already exists
          if (data['file_url'] != null) {
            continue;
          }
          
          // Add empty fileUrl field
          await _firestore.collection('requests').doc(doc.id).update({
            'file_url': '',  // Add an empty string field
          });
          
          fixed++;
          debugPrint('Added empty file_url field to document ${doc.id}');
        } catch (e) {
          debugPrint('Error fixing document ${doc.id}: $e');
        }
      }
      
      debugPrint('Repair completed. Fixed $fixed documents.');
    } catch (e) {
      debugPrint('Error repairing missing file_url fields: $e');
    }
  }
  
  /// Count documents with various field combinations
  static Future<Map<String, int>> countDocumentsByFieldStatus() async {
    final result = {
      'total': 0,
      'with_pdfBase64': 0,
      'with_fileUrl': 0,
      'with_both': 0,
      'with_none': 0,
    };
    
    try {
      final querySnapshot = await _firestore.collection('requests').get();
      result['total'] = querySnapshot.docs.length;
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final hasPdfBase64 = data['pdfBase64'] != null;
        final hasFileUrl = data['file_url'] != null;
        
        if (hasPdfBase64) result['with_pdfBase64'] = (result['with_pdfBase64'] ?? 0) + 1;
        if (hasFileUrl) result['with_fileUrl'] = (result['with_fileUrl'] ?? 0) + 1;
        if (hasPdfBase64 && hasFileUrl) result['with_both'] = (result['with_both'] ?? 0) + 1;
        if (!hasPdfBase64 && !hasFileUrl) result['with_none'] = (result['with_none'] ?? 0) + 1;
      }
      
      debugPrint('Document statistics: $result');
      return result;
    } catch (e) {
      debugPrint('Error counting documents: $e');
      return result;
    }
  }
} 