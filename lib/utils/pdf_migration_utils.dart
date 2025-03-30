import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:graduation_project/services/firebase_storage_service.dart';
import 'package:path_provider/path_provider.dart';

class PdfMigrationUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorageService _storageService = FirebaseStorageService();
  
  /// Migrates a single request's PDF from base64 to Firebase Storage
  static Future<void> migrateRequestPdf(String requestId) async {
    try {
      // Get the request document
      final doc = await _firestore.collection('requests').doc(requestId).get();
      if (!doc.exists) {
        throw Exception('Request not found');
      }
      
      final data = doc.data()!;
      
      // Check if required fields exist
      if (data['pdfBase64'] == null) {
        debugPrint('Request $requestId has no pdfBase64 field, skipping');
        return;
      }
      
      final String? pdfBase64 = data['pdfBase64'];
      final String? fileUrl = data['file_url'];
      final String studentId = data['student_id'] ?? '';
      final String type = data['type'] ?? '';
      final String fileName = data['file_name'] ?? 'document.pdf';
      
      // If already has fileUrl or no base64 data, skip
      if (fileUrl != null || pdfBase64 == null || pdfBase64.isEmpty || studentId.isEmpty) {
        debugPrint('Request $requestId has invalid PDF data or already has a file URL, skipping');
        return;
      }
      
      // Convert base64 to file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await tempFile.writeAsBytes(base64Decode(pdfBase64));
      
      // Upload to Firebase Storage
      final url = await _storageService.uploadPdf(tempFile, studentId, type);
      
      // Update Firestore document
      await _firestore.collection('requests').doc(requestId).update({
        'file_url': url,
        // Note: we're keeping pdfBase64 for backward compatibility
      });
      
      // Delete temp file
      await tempFile.delete();
      debugPrint('Successfully migrated PDF for request $requestId');
    } catch (e) {
      debugPrint('Error migrating PDF for request $requestId: $e');
      rethrow;
    }
  }
  
  /// Migrates all requests' PDFs from base64 to Firebase Storage
  static Future<void> migrateAllRequestPdfs() async {
    try {
      // Get all requests with pdfBase64 but no fileUrl
      final querySnapshot = await _firestore.collection('requests')
          .where('pdfBase64', isNull: false)
          .get();
      
      // Migrate each request
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          // Skip if file_url already exists and is not empty
          if (data['file_url'] != null && data['file_url'] != '') {
            debugPrint('Skipping request ${doc.id} as it already has file_url');
            continue;
          }
          
          await migrateRequestPdf(doc.id);
          debugPrint('Successfully migrated PDF for request ${doc.id}');
        } catch (e) {
          debugPrint('Error migrating PDF for request ${doc.id}: $e');
          // Continue with the next document even if one fails
        }
      }
    } catch (e) {
      debugPrint('Error migrating all PDFs: $e');
      rethrow;
    }
  }
} 