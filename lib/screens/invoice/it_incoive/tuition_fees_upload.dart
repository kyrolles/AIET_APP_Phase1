import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graduation_project/components/file_upload_with_progress.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:graduation_project/services/firebase_storage_service.dart';
import 'package:path/path.dart' as path;

import 'it_invoice_request_contanier.dart';

class TuitionFeesSheet extends StatefulWidget {
  const TuitionFeesSheet({
    super.key,
    required this.doneFunctionality,
    required this.request,
  });
  final Function() doneFunctionality;
  final Request request;

  @override
  State<TuitionFeesSheet> createState() => _TuitionFeesSheetState();
}

class _TuitionFeesSheetState extends State<TuitionFeesSheet> {
  String? pdfBase64;
  String? fileUrl;
  bool _isLoading = false;
  String? fileName;
  File? pdfFile;
  Map<String, dynamic>? userData;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Show custom snackbar function
  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : kgreen,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            right: 20,
            left: 20,
          ),
        ),
      );
  }

  Future<void> _fetchUserData() async {
    try {
      final data = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .where('id', isEqualTo: widget.request.studentId)
          .get();
      userData = data.docs.first.data();
    } catch (e) {
      _showCustomSnackBar('Error fetching user data: $e', isError: true);
    }
  }

  Future<void> updatePdfForTuitionFees() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      // Validate inputs
      if (pdfFile == null) {
        throw 'Please upload a PDF file';
      }
      if (fileName == null || fileName!.isEmpty) {
        throw 'File name is required';
      }
      if (userData == null) {
        throw 'User data not available';
      }
      // Get user data
      final String studentId = userData!['id'] ?? '';
      final String firstName = userData!['firstName'] ?? '';
      final String lastName = userData!['lastName'] ?? '';
      final String studentName = '$firstName$lastName'.trim();
      final String academicYear = userData!['academicYear'] ?? '';
      log('Student ID: $studentId');
      // Validate required fields
      if (studentId.isEmpty) {
        throw 'Student ID not found';
      }
      if (studentName.isEmpty) {
        throw 'Student name not found';
      }
      if (academicYear.isEmpty) {
        throw 'Academic year not found';
      }

      try {
        // First attempt: Upload PDF to Firebase Storage
        log('Attempting to upload PDF to Firebase Storage...');
        fileUrl = await _storageService.uploadPdf(pdfFile!, studentId, 'Tuition Fees');
        
        if (fileUrl == null || fileUrl!.isEmpty) {
          throw 'Failed to upload PDF to storage';
        }
        
        log('PDF uploaded successfully to Firebase Storage');
        
        // Save to Firestore
        await updateDocument(
          collectionPath: 'requests',
          searchCriteria: {
            'student_id': studentId,
            'type': 'Tuition Fees',
            'created_at': widget.request.createdAt,
          },
          newData: {
            'file_name': fileName,
            'file_url': fileUrl,
            'status': 'Done',
          },
        );
        Navigator.pop(context);
        _showCustomSnackBar('PDF uploaded successfully!');
      } catch (storageError) {
        log('Error with Firebase Storage: $storageError');
        
        // Log additional details if it's a Firebase error
        if (storageError is FirebaseException) {
          log('Firebase error code: ${storageError.code}');
          log('Firebase error message: ${storageError.message}');
        }
        
        // Fallback to base64 if Firebase Storage fails
        log('Falling back to base64 encoding');
        
        // Encode file as base64
        final bytes = await pdfFile!.readAsBytes();
        final base64String = base64Encode(bytes);
        
        // Save to Firestore with base64 encoding
        await updateDocument(
          collectionPath: 'requests',
          searchCriteria: {
            'student_id': studentId,
            'type': 'Tuition Fees',
            'created_at': widget.request.createdAt,
          },
          newData: {
            'file_name': fileName,
            'pdfBase64': base64String,
            'status': 'Done',
          },
        );
        Navigator.pop(context);
        _showCustomSnackBar('PDF uploaded successfully (using legacy method)!');
      }
    } catch (e) {
      _showCustomSnackBar('Error: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 32.0,
          left: 16.0,
          right: 16.0,
          top: 22.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                'Tuition Fees',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF6C7072),
                ),
              ),
            ),
            const SizedBox(height: 15),
            FileUploadWidget(
              height: 350,
              width: double.infinity,
              allowedExtensions: const ['pdf'],
              buttonText: "Upload Your PDF",
              onFileSelected: (file) async {
                try {
                  if (file.path != null) {
                    // Get file name from path
                    setState(() {
                      fileName = path.basename(file.path!);
                      pdfFile = File(file.path!);
                    });
                    // Show filename in a snackbar
                    _showCustomSnackBar('Selected file: $fileName');
                  }
                } catch (e) {
                  _showCustomSnackBar('Error selecting PDF: $e',
                      isError: true);
                }
              },
            ),
            if (fileName != null) ...[
              const SizedBox(height: 10),
              Text(
                'Selected file: $fileName',
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 15),
            const Text(
              'Do you want to pay in installments ?',
              style: TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            widget.request.stamp
                ? Checkbox(
                    value: widget.request.stamp,
                    onChanged: null, // Disable interaction
                  )
                : const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.cancel_presentation_outlined, // Use a cross icon
                      color: kGrey, // Customize the color
                      size: 24, // Adjust the size
                    ),
                  ),
            const SizedBox(height: 15),
            KButton(
                text: _isLoading ? 'Uploading...' : 'Done',
                backgroundColor: kgreen,
                onPressed: _isLoading ? null : updatePdfForTuitionFees),
          ],
        ),
      ),
    );
  }
}
