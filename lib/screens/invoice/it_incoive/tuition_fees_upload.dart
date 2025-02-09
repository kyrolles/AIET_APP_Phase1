import 'package:flutter/material.dart';
import 'package:graduation_project/components/file_upload_with_progress.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/models/request_model.dart';
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
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data();
          });
        }
      }
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
      if (pdfBase64 == null || pdfBase64!.isEmpty) {
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
      // Save to Firestore
      updateDocument(
        collectionPath: 'requests',
        searchCriteria: {
          'student_id': studentId,
          'type': 'Tuition Fees',
        },
        newData: {
          'file_name': fileName,
          'pdfBase64': pdfBase64,
          'status': 'Done',
        },
      );
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
                      });
                      final bytes = await File(file.path!).readAsBytes();
                      final base64String = base64Encode(bytes);
                      setState(() {
                        pdfBase64 = base64String;
                      });
                      // Show filename in a snackbar
                      _showCustomSnackBar('Selected file: $fileName');
                    }
                  } catch (e) {
                    _showCustomSnackBar('Error encoding PDF: $e',
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
      ),
    );
  }
}
