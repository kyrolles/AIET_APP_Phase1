import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/models/request_model.dart';

import '../pdf_service.dart';
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
      final data = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .where('id', isEqualTo: widget.request.studentId)
          .get();
      userData = data.docs.first.data();
      // log('User doc: ${data.docs.first['id']}');
      // if (userData.exists) {
      //   setState(() {
      //     userData = userDoc.data();
      //   });
      // }
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
      // Save to Firestore
      updateDocument(
        collectionPath: 'requests',
        searchCriteria: {
          'student_id': studentId,
          'type': 'Tuition Fees',
          'created_at': widget.request.createdAt,
        },
        newData: {
          'file_name': fileName,
          'pdfBase64': pdfBase64, //! Here is the pdf base 64
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

  //!---------------------------------------------------------------------------------------
  final PDFService _pdfService = PDFService();
  bool _isUploading = false;
  //!---------------------------------------------------------------------------------------

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
              // PDF Picker Button
              ElevatedButton.icon(
                onPressed: () async {
                  final bool picked = await _pdfService.pickPDF();
                  if (picked) {
                    setState(() {
                      // Update UI to show selected file
                    });
                  }
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Select PDF'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),

              const SizedBox(height: 20),

              // Show selected file name if any
              if (_pdfService.selectedFileName != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Selected file: ${_pdfService.selectedFileName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

              const SizedBox(height: 20),

              // Done Button
              ElevatedButton(
                onPressed: _pdfService.selectedFileName == null || _isUploading
                    ? null // Disable button if no file selected or upload in progress
                    : () async {
                        setState(() {
                          _isUploading = true;
                        });

                        // Upload PDF and save reference to Firestore
                        final String? documentId =
                            await _pdfService.uploadPDFAndSaveReference(
                          'requests', // Collection name
                          widget.request,
                        );

                        setState(() {
                          _isUploading = false;
                        });

                        if (documentId != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('PDF uploaded successfully!')),
                          );

                          // Optional: Navigate back or to another screen
                          Navigator.pop(context, documentId);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to upload PDF')),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  backgroundColor: Colors.green,
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('DONE'),
              ),
              //!---------------------------------------------------------------------------------------
              // FileUploadWidget(
              //   height: 350,
              //   width: double.infinity,
              //   allowedExtensions: const ['pdf'],
              //   buttonText: "Upload Your PDF",
              //   onFileSelected: (file) async {
              //     try {
              //       if (file.path != null) {
              //         // Get file name from path
              //         setState(() {
              //           fileName = path.basename(file.path!);
              //         });
              //         final bytes = await File(file.path!).readAsBytes();
              //         final base64String = base64Encode(bytes);
              //         setState(() {
              //           pdfBase64 = base64String;
              //         });
              //         // Show filename in a snackbar
              //         _showCustomSnackBar('Selected file: $fileName');
              //       }
              //     } catch (e) {
              //       _showCustomSnackBar('Error encoding PDF: $e',
              //           isError: true);
              //     }
              //   },
              // ),
              // if (fileName != null) ...[
              //   const SizedBox(height: 10),
              //   Text(
              //     'Selected file: $fileName',
              //     style: const TextStyle(fontSize: 14),
              //     textAlign: TextAlign.center,
              //   ),
              // ],
              //!---------------------------------------------------------------------------------------
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
