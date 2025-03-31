import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;

class PDFViewer extends StatelessWidget {
  final String? pdfBase64;
  final String? pdfUrl;

  const PDFViewer({
    super.key, 
    this.pdfBase64,
    this.pdfUrl,
  }) : assert(pdfBase64 != null || pdfUrl != null, 'Either pdfBase64 or pdfUrl must be provided');

  Future<String?> _preparePdfFile() async {
    try {
      // Try URL method first if available
      if (pdfUrl != null && pdfUrl!.isNotEmpty) {
        try {
          log('Loading PDF from URL: $pdfUrl');
          final response = await http.get(Uri.parse(pdfUrl!));
          
          if (response.statusCode == 200) {
            final tempDir = await getTemporaryDirectory();
            final tempFile = File(
                '${tempDir.path}/temp_url_${DateTime.now().millisecondsSinceEpoch}.pdf');
            await tempFile.writeAsBytes(response.bodyBytes);
            log('PDF loaded from URL successfully');
            return tempFile.path;
          } else {
            log('Failed to load PDF from URL: ${response.statusCode}');
            // Fall back to base64 if URL doesn't work
          }
        } catch (e) {
          log('Error loading PDF from URL: $e');
          // Fall back to base64 if URL doesn't work
        }
      }
      
      // Use base64 method if URL failed or isn't available
      if (pdfBase64 != null && pdfBase64!.isNotEmpty) {
        try {
          log('Loading PDF from base64');
          final pdfBytes = base64Decode(pdfBase64!);
          final tempDir = await getTemporaryDirectory();
          final tempFile = File(
              '${tempDir.path}/temp_base64_${DateTime.now().millisecondsSinceEpoch}.pdf');
          await tempFile.writeAsBytes(pdfBytes);
          log('PDF loaded from base64 successfully');
          return tempFile.path;
        } catch (e) {
          log('Error loading PDF from base64: $e');
          return null;
        }
      }
      
      log('No valid PDF source available');
      return null;
    } catch (e) {
      log('Error preparing PDF file: $e');
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
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading PDF. The file may be missing or corrupted.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('PDF Viewer')),
          body: PDFView(
            filePath: snapshot.data!,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: false,
            pageSnap: true,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false, 
            onRender: (pages) {
              log('PDF rendered with $pages pages');
            },
            onError: (error) {
              log('Error rendering PDF: $error');
            },
            onPageError: (page, error) {
              log('Error on page $page: $error');
            },
            onViewCreated: (controller) {
              log('PDF view created');
            },
          ),
        );
      },
    );
  }

  // Static method to open the PDF viewer
  static void open(BuildContext context, {String? pdfBase64, String? pdfUrl}) {
    if ((pdfBase64 == null || pdfBase64.isEmpty) && (pdfUrl == null || pdfUrl.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No PDF data available')),
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PDFViewer(
        pdfBase64: pdfBase64,
        pdfUrl: pdfUrl,
      )),
    );
  }
}
