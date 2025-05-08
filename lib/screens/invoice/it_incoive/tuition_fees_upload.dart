import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graduation_project/components/file_upload_with_progress.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:graduation_project/services/storage_service.dart';
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
  bool _isLoading = false;
  String? fileName;
  Map<String, dynamic>? userData;
  File? _selectedFile;
  final StorageService _storageService = StorageService();

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

      if (data.docs.isEmpty) {
        throw 'Student not found in database';
      }

      userData = data.docs.first.data();
      log('Fetched user data: $userData');
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
      if (_selectedFile == null) {
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

      // Get user UID for storage folder - fallback to student ID if no UID found
      final String uid = userData!['uid'] ?? userData!['user_uid'] ?? studentId;

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

      log('Using UID for storage: $uid');

      // Upload to Firebase Storage
      final String downloadUrl = await _storageService.uploadFile(
        file: _selectedFile!,
        studentUid: uid,
        customFileName: fileName,
      );

      // For backward compatibility, also save as base64
      final bytes = await _selectedFile!.readAsBytes();
      final base64String = base64Encode(bytes);

      // First, find the specific document using precise criteria
      final QuerySnapshot requestQuerySnapshot = await FirebaseFirestore
          .instance
          .collection('requests')
          .where('student_id', isEqualTo: studentId)
          .where('type', isEqualTo: 'Tuition Fees')
          .where('created_at', isEqualTo: widget.request.createdAt)
          .get();

      if (requestQuerySnapshot.docs.isEmpty) {
        throw 'Request document not found';
      }

      // Reference to the document to update
      final DocumentReference requestDocRef =
          requestQuerySnapshot.docs[0].reference;
      final Map<String, dynamic> requestData =
          requestQuerySnapshot.docs[0].data() as Map<String, dynamic>;

      log('Found request document to update: ${requestDocRef.id}');
      log('Current status: ${requestData['status']}');

      // Update non-status fields first
      await requestDocRef.update({
        'file_name': fileName,
        'pdfBase64': base64String,
        'file_storage_url': downloadUrl,
      });

      // Then update status separately to trigger the cloud function properly
      await requestDocRef.update({
        'status': 'Done',
      });

      log('Document updated with Done status');

      Navigator.pop(context);
      _showCustomSnackBar('PDF uploaded successfully!');
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
        child: Padding(
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
                        _selectedFile = File(file.path!);
                      });

                      // Also store base64 for backward compatibility
                      final bytes = await _selectedFile!.readAsBytes();
                      final base64String = base64Encode(bytes);
                      setState(() {
                        pdfBase64 = base64String;
                      });

                      // Show filename in a snackbar
                      _showCustomSnackBar('Selected file: $fileName');
                    }
                  } catch (e) {
                    _showCustomSnackBar('Error processing file: $e',
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
              widget.request.payInInstallments
                  ? Checkbox(
                      value: widget.request.payInInstallments,
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
      ),
    );
  }
}
