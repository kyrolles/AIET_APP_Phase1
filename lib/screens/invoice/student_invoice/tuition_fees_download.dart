import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/pdf_view.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:graduation_project/services/storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:developer';

class TuitionFeesDownload extends StatefulWidget {
  const TuitionFeesDownload({super.key, required this.request});

  final Request request;

  @override
  State<TuitionFeesDownload> createState() => _TuitionFeesDownloadState();
}

class _TuitionFeesDownloadState extends State<TuitionFeesDownload> {
  final StorageService _storageService = StorageService();
  bool _isDownloading = false;
  bool _canViewPdf = false;
  bool _canDownloadPdf = false;

  @override
  void initState() {
    super.initState();
    _checkFileAvailability();
  }

  void _checkFileAvailability() {
    // Check if we can view the PDF (either via storage URL or base64)
    _canViewPdf = (widget.request.fileStorageUrl != null && 
        widget.request.fileStorageUrl!.isNotEmpty) || 
        (widget.request.pdfBase64 != null && 
        widget.request.pdfBase64!.isNotEmpty);
        
    // Check if we can download the PDF (requires storage URL)
    _canDownloadPdf = widget.request.fileStorageUrl != null && 
        widget.request.fileStorageUrl!.isNotEmpty;
        
    log('Can view PDF: $_canViewPdf, Can download PDF: $_canDownloadPdf');
    log('fileStorageUrl: ${widget.request.fileStorageUrl}');
    log('pdfBase64 available: ${widget.request.pdfBase64 != null && widget.request.pdfBase64!.isNotEmpty}');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : kgreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _downloadFile() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      if (widget.request.fileStorageUrl == null || widget.request.fileStorageUrl!.isEmpty) {
        throw 'File storage URL is not available';
      }

      final File file = await _storageService.downloadFile(
        fileUrl: widget.request.fileStorageUrl!,
        fileName: widget.request.fileName,
      );

      // Get the application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String savePath = '${appDocDir.path}/${widget.request.fileName}';

      // Copy the downloaded file to the save path
      await file.copy(savePath);

      _showSnackBar('File downloaded successfully to: $savePath');
    } catch (e) {
      _showSnackBar('Download failed: $e', isError: true);
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  void _viewPdf(BuildContext context) {
    try {
      log('Opening PDF viewer');
      PDFViewer.open(
        context,
        pdfUrl: widget.request.fileStorageUrl,
        pdfBase64: widget.request.pdfBase64,
      );
    } catch (e) {
      log('Error viewing PDF: $e');
      _showSnackBar('Error viewing PDF: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    'Tuition Fees',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6C7072)),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          // Expanded(
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     child: Image.asset(
          //       'assets/images/invoice_preview.png',
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),
          StudentContainer(
            button: (BuildContext context) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KButton(
                    onPressed: _canViewPdf ? () => _viewPdf(context) : null,
                    text: 'View',
                    backgroundColor: _canViewPdf 
                        ? const Color.fromRGBO(6, 147, 241, 1)
                        : Colors.grey,
                    width: 80,
                    height: 50,
                    fontSize: 16.55,
                    margin: const EdgeInsets.only(right: 8),
                  ),
                  KButton(
                    onPressed: _canDownloadPdf && !_isDownloading ? _downloadFile : null,
                    text: _isDownloading ? 'Downloading...' : 'Download',
                    backgroundColor: _canDownloadPdf ? kgreen : Colors.grey,
                    width: 115,
                    height: 50,
                    fontSize: 16.55,
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                  ),
                ],
              );
            },
            title: widget.request.fileName.isEmpty ? 'No file uploaded yet' : widget.request.fileName,
            image: 'assets/project_image/pdf.png',
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: KButton(
          //     onPressed: () {},
          //     text: 'View PDF',
          //     fontSize: 21.7,
          //     textColor: Colors.white,
          //     backgroundColor: kBlue,
          //     borderColor: Colors.white,
          //   ),
          // ),
        ],
      ),
    );
  }
}
