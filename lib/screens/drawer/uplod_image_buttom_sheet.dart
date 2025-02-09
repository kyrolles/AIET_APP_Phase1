import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/file_upload_with_progress.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/constants.dart';
import 'package:path/path.dart' as path;

class UploadProfileImageBottomSheet extends StatefulWidget {
  const UploadProfileImageBottomSheet({super.key});

  @override
  State<UploadProfileImageBottomSheet> createState() =>
      _UploadProfileImageBottomSheetState();
}

class _UploadProfileImageBottomSheetState
    extends State<UploadProfileImageBottomSheet> {
  String? imageBase64;
  bool _isLoading = false;
  String? fileName;

  @override
  void initState() {
    super.initState();
  }

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

  Future<void> _uploadProfileImage() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate inputs
      if (imageBase64 == null || imageBase64!.isEmpty) {
        throw 'Please upload an image';
      }
      if (fileName == null || fileName!.isEmpty) {
        throw 'File name is required';
      }

      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw 'User not logged in';
      }

      // Update user document with profile image
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'profileImage': imageBase64,
      });

      Navigator.pop(context);
      _showCustomSnackBar('Profile image uploaded successfully!');
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Upload Profile Image',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF6C7072),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              FileUploadWidget(
                height: 350,
                width: double.infinity,
                allowedExtensions: const ['jpg', 'jpeg', 'png'],
                buttonText: "Select Profile Image",
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
                        imageBase64 = base64String;
                      });
                      _showCustomSnackBar('Image selected: $fileName');
                    }
                  } catch (e) {
                    _showCustomSnackBar('Error processing image: $e',
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
              KButton(
                text: _isLoading ? 'Uploading...' : 'Upload',
                backgroundColor: kgreen,
                onPressed: _isLoading ? null : _uploadProfileImage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
