import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PDFViewer extends StatelessWidget {
  final String pdfBase64;

  const PDFViewer({super.key, required this.pdfBase64});

  Future<String?> _preparePdfFile() async {
    try {
      final pdfBytes = base64Decode(pdfBase64);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await tempFile.writeAsBytes(pdfBytes);
      return tempFile.path;
    } catch (e) {
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

  // Static method to open the PDF viewer
  static void open(BuildContext context, String pdfBase64) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PDFViewer(pdfBase64: pdfBase64)),
    );
  }
}
