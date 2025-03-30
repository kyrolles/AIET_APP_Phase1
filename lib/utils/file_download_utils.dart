import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:graduation_project/services/firebase_storage_service.dart';
import 'package:http/http.dart' as http;

class FileDownloadUtils {
  /// Download PDF file to device's Downloads directory from URL
  static Future<void> downloadPdfToDevice(
    BuildContext context, 
    String url, 
    String fileName,
  ) async {
    try {
      // Check storage permission
      if (await Permission.storage.request().isGranted) {
        // Show progress indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading PDF...')),
        );
        
        // Get the download directory
        final directory = await _getDownloadDirectory();
        if (directory == null) {
          throw Exception('Could not access download directory');
        }
        
        // Create a path for downloads
        final downloadPath = directory.path;
        final filePath = '$downloadPath/$fileName';
        final file = File(filePath);
        
        // Download the file
        if (url.startsWith('http')) {
          final response = await http.get(Uri.parse(url));
          await file.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception('Invalid URL format');
        }
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to: $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF: $e')),
      );
    }
  }
  
  /// Get the appropriate download directory based on platform
  static Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // On Android, use the Download directory
      final directory = await getExternalStorageDirectory();
      return directory;
    } else if (Platform.isIOS) {
      // On iOS, use the Documents directory
      return await getApplicationDocumentsDirectory();
    } else {
      // For other platforms
      return await getTemporaryDirectory();
    }
  }
} 