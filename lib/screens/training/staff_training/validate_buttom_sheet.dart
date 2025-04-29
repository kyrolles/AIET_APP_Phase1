import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/pdf_view.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:graduation_project/services/training_notification_service.dart';

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
        final String message = status == 'Done' 
            ? 'Request approved. Student will be notified.' 
            : status == 'Rejected'
                ? 'Request rejected. Student will be notified.'
                : 'Request status updated.';
                
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error viewing PDF: $e')),
      );
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
              bottom: 32.0, left: 16.0, right: 16.0, top: 22.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'Review',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF6C7072),
                    ),
                  ),
                ),
                StudentContainer(
                  button: (BuildContext context) {
                    return KButton(
                      onPressed: _canViewPdf ? () => _viewPdf(context) : null,
                      text: 'view',
                      backgroundColor: _canViewPdf
                          ? const Color.fromRGBO(6, 147, 241, 1)
                          : Colors.grey,
                      width: 115,
                      height: 50,
                      fontSize: 16.55,
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                    );
                  },
                  title: widget.request.fileName,
                  image: 'assets/project_image/pdf.png',
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
                        return 'Score cannot be zero for Done status';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      score = int.tryParse(value);
                    });
                  },
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Score(in Days)',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (currentStatus == 'Rejected') {
                      if (value == null || value.isEmpty) {
                        return 'Comment must be filled to mark as Rejected';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      comment = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Comment',
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
