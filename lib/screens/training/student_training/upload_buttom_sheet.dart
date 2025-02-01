import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/file_upload_with_progress.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:path/path.dart' as path;

class UploadButtomSheet extends StatefulWidget {
  const UploadButtomSheet({super.key});

  @override
  State<UploadButtomSheet> createState() => _UploadButtomSheetState();
}

class _UploadButtomSheetState extends State<UploadButtomSheet> {
  String? pdfBase64;
  bool _isLoading = false;
  String? fileName;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  Future<void> _saveAnnouncement() async {
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
      await FirebaseFirestore.instance.collection('requests').add({
        'file_name': fileName,
        'pdfBase64': pdfBase64,
        'student_id': studentId,
        'student_name': studentName,
        'type': 'Training',
        'year': academicYear,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'No status',
        'addressed_to': '',
        'comment': '',
        'stamp': false,
        'training_score': 0,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
                  'Submit Training',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF6C7072),
                  ),
                ),
              ),
              // if (userData != null) ...[
              //   const SizedBox(height: 10),
              //   Text(
              //     'Student: ${userData!['firstName']} ${userData!['lastName']}',
              //     style: const TextStyle(fontSize: 16),
              //     textAlign: TextAlign.center,
              //   ),
              //   Text(
              //     'ID: ${userData!['id']}',
              //     style: const TextStyle(fontSize: 16),
              //     textAlign: TextAlign.center,
              //   ),
              // ],
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected file: $fileName')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error encoding PDF: $e')),
                    );
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
              KButton(
                text: _isLoading ? 'Uploading...' : 'Done',
                padding: const EdgeInsets.all(0),
                backgroundColor: Colors.green,
                onPressed: _isLoading ? null : _saveAnnouncement,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
