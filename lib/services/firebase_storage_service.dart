import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'aiet-application-7d58d.appspot.com',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Uploads a PDF file to Firebase Storage
  /// Returns the download URL of the uploaded file
  Future<String> uploadPdf(File file, String studentId, String type) async {
    try {
      debugPrint('Uploading PDF to Firebase Storage: studentId=$studentId, type=$type');
      final fileName = path.basename(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Create a simpler path structure in case folder permissions are an issue
      final storageRef = _storage.ref().child(
          'pdf_files/$fileName');
      
      debugPrint('Storage reference created at path: ${storageRef.fullPath}');
      debugPrint('File exists: ${await file.exists()}, Size: ${await file.length()} bytes');
      
      // Ensure user is authenticated
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('Warning: No authenticated user found. Anonymous uploads may be restricted.');
      }
      
      // Start upload with detailed metadata
      final metadata = SettableMetadata(
        contentType: 'application/pdf',
        customMetadata: {
          'studentId': studentId,
          'type': type,
          'uploadTime': DateTime.now().toIso8601String(),
          'uploadedBy': currentUser?.uid ?? 'anonymous',
        },
      );
      
      debugPrint('Starting upload task with metadata...');
      final uploadTask = storageRef.putFile(file, metadata);
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        debugPrint('Upload progress: ${progress.toStringAsFixed(2)}%');
      });
      
      final snapshot = await uploadTask.whenComplete(() {
        debugPrint('Upload complete!');
      });
      
      // Get the download URL
      debugPrint('Getting download URL...');
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Download URL obtained: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading PDF to Firebase Storage: $e');
      // More detailed error information
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
        debugPrint('Firebase error message: ${e.message}');
        debugPrint('Firebase error details: ${e.stackTrace}');
        
        if (e.code == 'unauthorized' || e.code == 'permission-denied') {
          debugPrint('This appears to be a permissions issue. Check your Firebase Storage rules.');
        } else if (e.code == 'object-not-found') {
          debugPrint('The specified object or bucket does not exist.');
        }
      }
      throw Exception('Failed to upload PDF: $e');
    }
  }
  
  /// Downloads a PDF file from Firebase Storage
  /// Returns a local file path where the PDF is stored
  Future<String> downloadPdf(String downloadUrl) async {
    try {
      debugPrint('Downloading PDF from URL: $downloadUrl');
      // Extract file name from the URL
      final uri = Uri.parse(downloadUrl);
      final fileName = uri.pathSegments.last;
      
      // Get temporary directory
      final Directory tempDir = Directory.systemTemp;
      final filePath = '${tempDir.path}/$fileName';
      
      // Create a reference to the file
      debugPrint('Creating reference to storage file...');
      final ref = _storage.refFromURL(downloadUrl);
      
      // Download the file
      final file = File(filePath);
      debugPrint('Downloading file to: $filePath');
      await ref.writeToFile(file);
      debugPrint('Download complete!');
      
      return filePath;
    } catch (e) {
      debugPrint('Error downloading PDF from Firebase Storage: $e');
      throw Exception('Failed to download PDF: $e');
    }
  }

  /// Deletes a PDF file from Firebase Storage
  Future<void> deletePdf(String downloadUrl) async {
    try {
      debugPrint('Deleting PDF from URL: $downloadUrl');
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      debugPrint('Delete complete!');
    } catch (e) {
      debugPrint('Error deleting PDF from Firebase Storage: $e');
      throw Exception('Failed to delete PDF: $e');
    }
  }

  /// Tests if Firebase Storage is accessible by creating and deleting a test file
  Future<bool> testStorageAccess() async {
    try {
      debugPrint('Testing Firebase Storage access...');
      
      // Log auth status
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        debugPrint('Testing with authenticated user: ${currentUser.uid}');
      } else {
        debugPrint('Testing with no authenticated user (anonymous access)');
      }
      
      // Create a small test file
      final Directory tempDir = Directory.systemTemp;
      final testFilePath = '${tempDir.path}/test_firebase_${DateTime.now().millisecondsSinceEpoch}.txt';
      final testFile = File(testFilePath);
      await testFile.writeAsString('Firebase Storage test file');
      
      // Try to upload it to root level first (simplest path)
      debugPrint('Uploading test file to root level...');
      final testFileName = 'test_${DateTime.now().millisecondsSinceEpoch}.txt';
      final storageRef = _storage.ref().child(testFileName);
      
      final uploadTask = storageRef.putFile(testFile);
      final snapshot = await uploadTask.whenComplete(() {
        debugPrint('Test upload complete');
      });
      
      // Get the URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Test file URL: $downloadUrl');
      
      // Delete the test file from storage
      await snapshot.ref.delete();
      debugPrint('Test file deleted from storage');
      
      // Delete local test file
      await testFile.delete();
      
      debugPrint('Firebase Storage access test PASSED');
      return true;
    } catch (e) {
      debugPrint('Firebase Storage access test FAILED: $e');
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
        debugPrint('Firebase error message: ${e.message}');
        
        if (e.code == 'unauthorized' || e.code == 'permission-denied') {
          debugPrint('This appears to be a permissions issue. Please check your Firebase Storage rules.');
          debugPrint('Your Firebase Storage rules should allow authenticated users to read and write.');
        }
      }
      return false;
    }
  }
} 