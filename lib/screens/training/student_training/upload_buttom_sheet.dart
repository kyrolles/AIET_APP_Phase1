import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/file_upload_with_progress.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/constants.dart';
import 'package:path/path.dart' as path;

class UploadButtomSheet extends StatefulWidget {
  const UploadButtomSheet({super.key});
  @override
  State<UploadButtomSheet> createState() => _UploadButtomSheetState();
}

class _UploadButtomSheetState extends State<UploadButtomSheet> {
  File? pdfFile;
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

  Future<String> _uploadFileToStorage(File file, String studentId) async {
    try {
      // Generate a unique file path in Firebase Storage
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String storagePath = 'training_pdfs/$studentId/$timestamp-${path.basename(file.path)}';
      
      // Create a reference to the file location in Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      
      // Upload the file
      final uploadTask = storageRef.putFile(file);
      
      // Wait for the upload to complete and get the download URL
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload file: $e';
    }
  }

  Future<void> _saveAnnouncement() async {
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
      final String studentName = '$firstName $lastName'.trim();
      final String academicYear = userData!['academicYear'] ?? '';
      final String department = userData!['department'] ?? '';
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
      
      // Upload file to Firebase Storage and get download URL
      final String downloadUrl = await _uploadFileToStorage(pdfFile!, studentId);
      
      // Save to Firestore
      await FirebaseFirestore.instance.collection('requests').add({
        'file_name': fileName,
        'student_id': studentId,
        'student_name': studentName,
        'type': 'Training',
        'year': academicYear,
        'created_at': Timestamp.now(),
        'status': 'No status',
        'addressed_to': '',
        'comment': '',
        'pay_in_installments': false,
        'training_score': 0,
        'file_storage_url': downloadUrl,
        'location': '',
        'phone_number': '',
        'stamp_type': '',
        'document_language': '',
        'department': department,
      });
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
                  'Submit Training',
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
                      _showCustomSnackBar('Selected file: $fileName');
                    }
                  } catch (e) {
                    _showCustomSnackBar('Error selecting PDF: $e', isError: true);
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
                backgroundColor: kgreen,
                onPressed: _isLoading ? null : _saveAnnouncement,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
