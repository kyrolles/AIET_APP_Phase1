import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:graduation_project/services/firebase_storage_service.dart';

class PDFViewer extends StatelessWidget {
  final String? pdfBase64;
  final String? pdfUrl;
  
  const PDFViewer._({
    super.key,
    this.pdfBase64,
    this.pdfUrl,
  }) : assert(pdfBase64 != null || pdfUrl != null, 'Either pdfBase64 or pdfUrl must be provided');

  /// Constructor for base64-encoded PDF
  const PDFViewer.fromBase64({
    super.key,
    required String pdfBase64,
  }) : pdfBase64 = pdfBase64, pdfUrl = null;
  
  /// Constructor for URL-based PDF
  const PDFViewer.fromUrl({
    super.key,
    required String pdfUrl,
  }) : pdfUrl = pdfUrl, pdfBase64 = null;

  Future<String?> _preparePdfFile() async {
    try {
      if (pdfBase64 != null && pdfBase64!.isNotEmpty) {
        final pdfBytes = base64Decode(pdfBase64!);
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
            '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await tempFile.writeAsBytes(pdfBytes);
        return tempFile.path;
      } else if (pdfUrl != null && pdfUrl!.isNotEmpty) {
        final storageService = FirebaseStorageService();
        return await storageService.downloadPdf(pdfUrl!);
      }
      return null;
    } catch (e) {
      debugPrint('Error preparing PDF file: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _preparePdfFile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('PDF Viewer')),
            body: const Center(child: Text('Error loading PDF')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('PDF Viewer')),
          body: PDFView(filePath: snapshot.data!),
        );
      },
    );
  }

  /// Static method to open the PDF viewer with base64 data
  static void open(BuildContext context, String pdfBase64) {
    if (pdfBase64.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF data is empty')),
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PDFViewer.fromBase64(pdfBase64: pdfBase64)),
    );
  }
  
  /// Static method to open the PDF viewer with URL
  static void openUrl(BuildContext context, String pdfUrl) {
    if (pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF URL is empty')),
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PDFViewer.fromUrl(pdfUrl: pdfUrl)),
    );
  }
}
