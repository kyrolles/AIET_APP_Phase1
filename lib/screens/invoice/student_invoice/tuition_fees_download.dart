import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/pdf_view.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:open_file/open_file.dart';

class TuitionFeesDownload extends StatefulWidget {
  const TuitionFeesDownload({super.key, required this.request});

  final Request request;

  @override
  State<TuitionFeesDownload> createState() => _TuitionFeesDownloadState();
}

class _TuitionFeesDownloadState extends State<TuitionFeesDownload> {
  bool _isDownloading = false;
  bool _canViewPdf = false;
  bool _canDownloadPdf = false;
  double _downloadProgress = 0.0;
  String _downloadStatus = '';
  String? _lastDownloadedFilePath;

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

  Future<void> _openDownloadedFile() async {
    if (_lastDownloadedFilePath == null) {
      _showSnackBar('No downloaded file to open', isError: true);
      return;
    }

    try {
      final result = await OpenFile.open(_lastDownloadedFilePath!);
      if (result.type != ResultType.done) {
        _showSnackBar('Failed to open file: ${result.message}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error opening file: $e', isError: true);
    }
  }

  Future<void> _downloadFile() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadStatus = 'Preparing download...';
      _lastDownloadedFilePath = null;
    });

    try {
      if (widget.request.fileStorageUrl == null ||
          widget.request.fileStorageUrl!.isEmpty) {
        throw 'File storage URL is not available';
      }

      // Check Android version to determine appropriate permissions and storage approach
      bool canUseExternalStorage = false;
      if (Platform.isAndroid) {
        final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

        // For Android 10 (API 29) and below
        if (androidInfo.version.sdkInt <= 29) {
          var status = await Permission.storage.request();
          canUseExternalStorage = status.isGranted;
        } else {
          // For Android 11 (API 30) and above
          // Use manage external storage permission for all files access
          if (await Permission.manageExternalStorage.isGranted) {
            canUseExternalStorage = true;
          } else {
            var status = await Permission.manageExternalStorage.request();
            canUseExternalStorage = status.isGranted;
          }
        }
      } else if (Platform.isIOS) {
        // iOS doesn't need explicit permission for app document directory
        canUseExternalStorage = true;
      }

      log('canUseExternalStorage: $canUseExternalStorage');

      // Determine where to save the file
      String savePath;
      if (Platform.isAndroid && canUseExternalStorage) {
        // Try to use Download directory first on Android
        final Directory downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          savePath = '${downloadDir.path}/${widget.request.fileName}';
        } else {
          // Fallback to app's external storage directory
          final appDir = await getExternalStorageDirectory();
          if (appDir != null) {
            savePath = '${appDir.path}/${widget.request.fileName}';
          } else {
            // Last resort: app documents directory
            final docDir = await getApplicationDocumentsDirectory();
            savePath = '${docDir.path}/${widget.request.fileName}';
          }
        }
      } else {
        // For iOS or if Android permissions not granted, use app documents directory
        final docDir = await getApplicationDocumentsDirectory();
        savePath = '${docDir.path}/${widget.request.fileName}';
      }

      log('Will save file to: $savePath');
      final File file = File(savePath);

      // Create reference from URL
      final Reference ref =
          FirebaseStorage.instance.refFromURL(widget.request.fileStorageUrl!);

      setState(() {
        _downloadStatus = 'Downloading file...';
      });

      // Track download progress
      final DownloadTask downloadTask = ref.writeToFile(file);

      downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _downloadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          _downloadStatus =
              '${(_downloadProgress * 100).toStringAsFixed(1)}% downloaded';
        });
      });

      // Wait for the download to complete
      await downloadTask;

      setState(() {
        _downloadStatus = 'Download complete!';
        _downloadProgress = 1.0;
        _lastDownloadedFilePath = savePath;
      });

      // Format a more user-friendly path for display
      String displayPath = savePath;
      if (Platform.isAndroid &&
          savePath.contains('/storage/emulated/0/Download')) {
        displayPath = 'Downloads/${widget.request.fileName}';
      } else if (Platform.isAndroid && !canUseExternalStorage) {
        displayPath =
            'App Storage/${widget.request.fileName} (Needs permission for external access)';
      } else if (Platform.isIOS) {
        displayPath = 'Files App/${widget.request.fileName}';
      }

      _showSnackBar('File saved to: $displayPath');
      log('File saved successfully to: $savePath');
    } catch (e) {
      setState(() {
        _downloadStatus = 'Download failed';
      });
      _showSnackBar('Download failed: $e', isError: true);
      log('Download error: $e');
    } finally {
      // For this case, don't hide immediately to let user open the file
      if (_lastDownloadedFilePath == null) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isDownloading = false;
            });
          }
        });
      }
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
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
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
                        onPressed: _canDownloadPdf && !_isDownloading
                            ? _downloadFile
                            : null,
                        text: _isDownloading ? 'Downloading' : 'Download',
                        backgroundColor: _canDownloadPdf ? kgreen : Colors.grey,
                        width: 115,
                        height: 50,
                        fontSize: 16.55,
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                      ),
                    ],
                  ),
                  if (_isDownloading) ...[
                    const SizedBox(height: 8),
                    Text(_downloadStatus, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                          maxWidth:
                              195), // Match the width of the buttons above
                      child: LinearProgressIndicator(
                        value: _downloadProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(kgreen),
                      ),
                    ),
                    if (_lastDownloadedFilePath != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _openDownloadedFile,
                        icon: const Icon(Icons.folder_open, size: 16),
                        label: const Text('Open Downloaded File'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isDownloading = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Close'),
                      ),
                    ],
                  ],
                ],
              );
            },
            title: widget.request.fileName.isEmpty
                ? 'No file uploaded yet'
                : widget.request.fileName,
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
