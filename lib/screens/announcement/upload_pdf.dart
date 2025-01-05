import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class UploadPdf extends StatefulWidget {
  const UploadPdf({super.key, this.pdfBase64, this.pdfFileName});

  final String? pdfBase64;
  final String? pdfFileName;

  @override
  State<UploadPdf> createState() => _UploadPdfState();
}

class _UploadPdfState extends State<UploadPdf> {
  @override
  Widget build(BuildContext context) {
    final pdfBase64 = widget.pdfBase64;
    final pdfFileName = widget.pdfFileName;
    if (pdfBase64 != null && pdfFileName != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: _buildPDFWidget(
          pdfBase64,
          pdfFileName,
        ),
      );
    } else {
      return Container();
    }
  }

  void _showFullScreenPDF(BuildContext context, String pdfBase64) {
    final pdfBytes = base64Decode(pdfBase64);
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/temp.pdf');
    tempFile.writeAsBytesSync(pdfBytes);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('PDF Viewer'),
          ),
          body: PDFView(
            filePath: tempFile.path,
          ),
        ),
      ),
    );
  }

  Widget _buildPDFWidget(String pdfBase64, String fileName) {
    return GestureDetector(
      onTap: () {
        _showFullScreenPDF(context, pdfBase64);
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/4726010.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Center(
                child: Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
