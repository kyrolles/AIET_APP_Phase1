import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/pdf_view.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:graduation_project/services/training_notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ValidateButtomSheet extends StatefulWidget {
  const ValidateButtomSheet({super.key, required this.request});
  final Request request;

  @override
  State<ValidateButtomSheet> createState() => _ValidateButtomSheetState();
}

class _ValidateButtomSheetState extends State<ValidateButtomSheet> {
  int? score;
  String? comment;
  String? currentStatus;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _canViewPdf = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _downloadedFilePath;

  @override
  void initState() {
    super.initState();
    _checkFileAvailability();
  }

  void _checkFileAvailability() {
    try {
      // Check if we can view the PDF (either via storage URL or base64)
      final hasStorageUrl = widget.request.fileStorageUrl != null &&
          widget.request.fileStorageUrl!.isNotEmpty;

      final hasBase64 = widget.request.pdfBase64 != null &&
          widget.request.pdfBase64!.isNotEmpty;

      setState(() {
        _canViewPdf = hasStorageUrl || hasBase64;
      });

      log('Can view PDF: $_canViewPdf');
      log('Has fileStorageUrl: $hasStorageUrl');
      log('Has pdfBase64: $hasBase64');
    } catch (e) {
      log('Error checking file availability: $e');
      setState(() {
        _canViewPdf = false;
      });
    }
  }

  Future<void> updateDocument({
    required String collectionPath,
    required Map<String, dynamic> searchCriteria,
    required Map<String, dynamic> newData,
  }) async {
    try {
      Query query = FirebaseFirestore.instance.collection(collectionPath);

      searchCriteria.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;
        final String documentId = docRef.id;

        // If the status is Done or Rejected, use the notification service
        if (newData['status'] == 'Done' || newData['status'] == 'Rejected') {
          await TrainingNotificationService().updateTrainingRequestStatus(
            requestId: documentId,
            status: newData['status'],
            trainingScore: newData['training_score'] ?? 0,
            comment: newData['comment'] ?? '',
          );
          log('Document updated using notification service');
        } else {
          // For other statuses, update normally
          await docRef.update(newData);
          log('Document updated normally');
        }
      }
    } catch (e) {
      log('Error updating document: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating request: $e')),
        );
      }
    }
  }

  Future<void> _downloadPdf() async {
    if (!_canViewPdf) {
      _showSnackBar('No PDF file available to download');
      return;
    }

    try {
      // Request storage permission on Android
      if (Platform.isAndroid) {
        if (await _requestStoragePermission() == false) {
          return;
        }
      }

      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
        _downloadedFilePath = null;
      });

      final hasStorageUrl = widget.request.fileStorageUrl != null &&
          widget.request.fileStorageUrl!.isNotEmpty;

      if (hasStorageUrl) {
        await _downloadFromUrl();
      } else if (widget.request.pdfBase64 != null &&
          widget.request.pdfBase64!.isNotEmpty) {
        await _downloadFromBase64();
      } else {
        throw Exception('No valid PDF source found');
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
      });
      _showSnackBar('Error downloading PDF: $e');
      log('Error downloading PDF: $e');
    }
  }

  Future<void> _downloadFromUrl() async {
    final url = widget.request.fileStorageUrl!;
    final fileName = widget.request.fileName ?? 'training_document.pdf';

    try {
      // Get download directory
      final Directory? downloadDir = await _getDownloadDirectory();
      if (downloadDir == null) {
        throw Exception('Cannot access download directory');
      }

      // Clean filename and add timestamp to avoid overwriting
      final safeFileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final filePath = '${downloadDir.path}/${timestamp}_$safeFileName';

      final file = File(filePath);

      // Show initial progress
      if (mounted) {
        setState(() {
          _downloadProgress = 0.05;
        });
      }

      // Use a simpler approach with ByteStream to avoid stream closure issues
      final httpClient = http.Client();
      try {
        final response = await httpClient.get(Uri.parse(url));

        if (response.statusCode != 200) {
          throw Exception(
              'Failed to download file: HTTP ${response.statusCode}');
        }

        // Update progress to indicate download has started
        if (mounted) {
          setState(() {
            _downloadProgress = 0.2;
          });
        }

        // Write the file all at once
        await file.writeAsBytes(response.bodyBytes);
        log('File downloaded to: ${file.path}');

        // Ensure we're still mounted before updating UI
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _downloadProgress = 1.0;
            _downloadedFilePath = filePath;
          });

          final localizations = AppLocalizations.of(context);
          _showSnackBar(localizations?.fileDownloadedToDownloads ??
              'File downloaded to Downloads/AIETApp folder');

          // Force a rebuild after a short delay to ensure UI updates
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {});
            }
          });
        }
      } finally {
        httpClient.close();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });
      }
      rethrow;
    }
  }

  Future<void> _downloadFromBase64() async {
    try {
      if (widget.request.pdfBase64 == null ||
          widget.request.pdfBase64!.isEmpty) {
        throw Exception('Invalid base64 data');
      }

      final fileName = widget.request.fileName ?? 'training_document.pdf';

      // Get download directory
      final Directory? downloadDir = await _getDownloadDirectory();
      if (downloadDir == null) {
        throw Exception('Cannot access download directory');
      }

      // Generate a unique filename to avoid overwriting
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final filePath = '${downloadDir.path}/${timestamp}_$fileName';

      final file = File(filePath);

      // Simulate progress for base64 conversion
      setState(() {
        _downloadProgress = 0.3;
      });

      // Decode base64
      final bytes = base64Decode(widget.request.pdfBase64!);

      setState(() {
        _downloadProgress = 0.6;
      });

      // Write to file
      await file.writeAsBytes(bytes);

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 1.0;
          _downloadedFilePath = filePath;
        });

        _showSnackBar('File downloaded successfully');
        log('File saved to: $filePath');

        // Force a rebuild after a short delay to ensure UI updates
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {});
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
      rethrow;
    }
  }

  Future<bool> _requestStoragePermission() async {
    bool hasPermission = false;

    // Request storage permissions with more comprehensive approach
    if (Platform.isAndroid) {
      // For Android 13+ (API level 33+)
      if (await Permission.manageExternalStorage.request().isGranted) {
        log('manageExternalStorage permission granted');
        hasPermission = true;
      }
      // For Android 10+ (API level 29+)
      else if (await Permission.storage.request().isGranted) {
        log('storage permission granted');
        hasPermission = true;
      }
      // Additional permission requests
      else {
        final permissions = await [
          Permission.storage,
          Permission.mediaLibrary,
          Permission.photos,
          Permission.videos,
        ].request();

        hasPermission = permissions.values.any((status) => status.isGranted);
        log('Multiple permissions requested, granted: $hasPermission');
      }
    } else {
      // For iOS
      hasPermission = await Permission.storage.request().isGranted;
    }

    if (!hasPermission) {
      _showSnackBar(
          'Storage permission is required. Please grant permission in app settings.');
    }

    return hasPermission;
  }

  Future<Directory?> _getDownloadDirectory() async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        // For Android, use the standard Download directory
        try {
          // Try to get common public Downloads directory - most accessible
          final downloadPath = '/storage/emulated/0/Download';
          final downloadDir = Directory('$downloadPath/AIETApp');

          // Test if we can access and write to this directory
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }

          // Verify we can write to it
          final testFile = File('${downloadDir.path}/test.txt');
          await testFile.writeAsString('test');
          await testFile.delete();

          log('Using public Download directory: ${downloadDir.path}');
          return downloadDir;
        } catch (e) {
          log('Error accessing public Downloads directory: $e');

          // Fallback to app-specific external storage
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            final downloadDir = Directory('${directory.path}/Download');
            if (!await downloadDir.exists()) {
              await downloadDir.create(recursive: true);
            }
            log('Using app-specific external directory: ${downloadDir.path}');
            return downloadDir;
          }
        }

        // Final fallback to application documents directory
        directory = await getApplicationDocumentsDirectory();
      } else {
        // For iOS or other platforms
        directory = await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      log('Error getting download directory: $e');
      // Final fallback
      directory = await getTemporaryDirectory();
    }
    log('Using fallback directory: ${directory.path}');
    return directory;
  }

  void _openFileLocation() async {
    try {
      if (_downloadedFilePath == null) {
        _showSnackBar('No downloaded file to open');
        return;
      }

      final file = File(_downloadedFilePath!);
      if (await file.exists()) {
        log('Opening file: $_downloadedFilePath');

        if (Platform.isAndroid) {
          // Show a more descriptive message about where to find the file
          _showSnackBar('File location: ${path.dirname(_downloadedFilePath!)}');

          // Try multiple approaches to open the file
          try {
            // First attempt - standard open with default viewer
            final result = await OpenFile.open(_downloadedFilePath!);

            if (result.type != ResultType.done) {
              log('First attempt failed: ${result.message}');

              // Second attempt - open the Downloads folder
              await OpenFile.open('/storage/emulated/0/Download');
            }
          } catch (e) {
            log('Error in file opening sequence: $e');

            // Fallback to showing the exact file path
            _showSnackBar('File saved to Downloads/AIETApp folder.\n'
                'Please open your file manager app and navigate to that location.');
          }
        } else {
          // For iOS and other platforms
          final result = await OpenFile.open(_downloadedFilePath!);

          if (result.type != ResultType.done) {
            _showSnackBar('Could not open file: ${result.message}');
          }
        }
      } else {
        _showSnackBar('File not found at: $_downloadedFilePath');
      }
    } catch (e) {
      _showSnackBar('Error opening file: $e');
      log('Error opening file: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _updateStatus(String status) {
    setState(() {
      currentStatus = status;
    });

    if (formKey.currentState!.validate()) {
      updateDocument(
        collectionPath: 'requests',
        searchCriteria: {
          'type': 'Training',
          'student_id': widget.request.studentId,
          'file_name': widget.request.fileName
        },
        newData: {
          'status': status,
          'training_score': score ?? 0,
          'comment': comment ?? '',
        },
      ).then((_) {
        Navigator.pop(context);

        // Show a snackbar to confirm the status change
        final localizations = AppLocalizations.of(context);
        final String message = status == 'Done'
            ? (localizations?.requestApproved ??
                'Request approved. Student will be notified.')
            : status == 'Rejected'
                ? (localizations?.requestRejected ??
                    'Request rejected. Student will be notified.')
                : (localizations?.requestStatusUpdated ??
                    'Request status updated.');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: status == 'Done'
                ? kgreen
                : status == 'Rejected'
                    ? Colors.red
                    : Colors.blue,
          ),
        );
      });
    }
  }

  void _viewPdf(BuildContext context) {
    try {
      log('Opening PDF viewer');
      log('fileStorageUrl: ${widget.request.fileStorageUrl}');
      log('pdfBase64 length: ${widget.request.pdfBase64?.length ?? 0}');

      // Check if at least one source is available
      if ((widget.request.fileStorageUrl == null ||
              widget.request.fileStorageUrl!.isEmpty) &&
          (widget.request.pdfBase64 == null ||
              widget.request.pdfBase64!.isEmpty)) {
        throw Exception('No PDF data available');
      }

      PDFViewer.open(
        context,
        pdfUrl: widget.request.fileStorageUrl,
        pdfBase64: widget.request.pdfBase64,
      );
    } catch (e) {
      log('Error viewing PDF: $e');
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${localizations?.errorViewingPDF ?? 'Error viewing PDF'}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              bottom: 32.0, left: 16.0, right: 16.0, top: 22.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    localizations?.review ?? 'Review',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF6C7072),
                    ),
                  ),
                ),
                StudentContainer(
                  button: (BuildContext context) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        KButton(
                          onPressed:
                              _canViewPdf ? () => _viewPdf(context) : null,
                          text: 'View',
                          backgroundColor: _canViewPdf
                              ? const Color.fromRGBO(6, 147, 241, 1)
                              : Colors.grey,
                          width: 90,
                          height: 50,
                          fontSize: 16,
                          margin: const EdgeInsets.only(
                              top: 8, bottom: 8, right: 8),
                        ),
                        KButton(
                          onPressed: _canViewPdf && !_isDownloading
                              ? _downloadPdf
                              : null,
                          text: _isDownloading ? 'Downloading...' : 'Download',
                          backgroundColor: _canViewPdf && !_isDownloading
                              ? kgreen
                              : Colors.grey,
                          width: 100,
                          height: 50,
                          fontSize: 16,
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
                        ),
                      ],
                    );
                  },
                  title: widget.request.fileName,
                  image: 'assets/project_image/pdf.png',
                ),

                // Download progress indicator
                if (_isDownloading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${localizations?.downloading ?? 'Downloading'}... ${(_downloadProgress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (_isDownloading)
                              const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _downloadProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(kBlue),
                        ),
                      ],
                    ),
                  ),

                // Open file button - shown only when download is complete
                if (_downloadedFilePath != null && !_isDownloading)
                  Container(
                    margin: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                    child: ElevatedButton.icon(
                      onPressed: _openFileLocation,
                      icon: const Icon(Icons.folder_open, size: 20),
                      label: Text(
                        localizations?.openFile ?? 'Open File',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 5),
                TextFormField(
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (currentStatus == 'Done') {
                      if (value == null || value.isEmpty) {
                        return 'Score must be filled to mark as Done';
                      }
                      final number = int.tryParse(value);
                      if (number == null) {
                        return 'Please enter a valid number';
                      }
                      if (number == 0) {
                        return localizations?.scoreCannotBeZero ??
                            'Score cannot be zero for Done status';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      score = int.tryParse(value);
                    });
                  },
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: localizations?.scoreInDays ?? 'Score(in Days)',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (currentStatus == 'Rejected') {
                      if (value == null || value.isEmpty) {
                        return localizations?.commentRequiredForRejected ??
                            'Comment must be filled to mark as Rejected';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      comment = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: localizations?.comment ?? 'Comment',
                  ),
                ),
                const SizedBox(height: 29),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: KButton(
                        onPressed: () => _updateStatus('Rejected'),
                        text: null,
                        svgPath: 'assets/project_image/false.svg',
                        svgHeight: 50,
                        svgWidth: 50,
                        height: 65,
                        margin: const EdgeInsets.only(right: 8),
                        backgroundColor: const Color.fromRGBO(255, 118, 72, 1),
                      ),
                    ),
                    Flexible(
                      child: KButton(
                        onPressed: () => _updateStatus('Pending'),
                        text: null,
                        svgPath: 'assets/project_image/pause.svg',
                        svgHeight: 45,
                        svgWidth: 45,
                        height: 65,
                        backgroundColor: const Color.fromRGBO(255, 221, 41, 1),
                      ),
                    ),
                    Flexible(
                      child: KButton(
                        onPressed: () => _updateStatus('Done'),
                        text: null,
                        svgPath: 'assets/project_image/true.svg',
                        svgHeight: 50,
                        svgWidth: 50,
                        height: 65,
                        backgroundColor: kgreen,
                        margin: const EdgeInsets.only(left: 8),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
