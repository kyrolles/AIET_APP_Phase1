import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/components/custom_text_field.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/pdf_view.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/screens/invoice/it_incoive/request_model.dart';

class ValidateButtomSheet extends StatefulWidget {
  const ValidateButtomSheet({super.key, required this.request});
  final Request request;

  @override
  State<ValidateButtomSheet> createState() => _ValidateButtomSheetState();
}

class _ValidateButtomSheetState extends State<ValidateButtomSheet> {
  final TextEditingController scoreController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    scoreController.dispose();
    commentController.dispose();
    super.dispose();
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
        await querySnapshot.docs.first.reference.update(newData);
      }
      log('Document updated successfully');
    } catch (e) {
      log('Error updating document: $e');
    }
  }

  void _updateStatus(String status) {
    int score = int.tryParse(scoreController.text) ?? 0;
    String comment = commentController.text;

    if (status == 'Done' && score == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Score must be filled to mark as Done')),
      );
      return;
    }

    if (status == 'Rejected' && comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Comment must be filled to mark as Rejected')),
      );
      return;
    }

    updateDocument(
      collectionPath: 'requests',
      searchCriteria: {
        'type': 'Training',
        'student_id': widget.request.studentId,
        'file_name': widget.request.fileName
      },
      newData: {
        'status': status,
        'training_score': score,
        'comment': comment,
      },
    );
    Navigator.pop(context);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  'Review',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF6C7072)),
                ),
              ),
              StudentContainer(
                  button: (BuildContext context) {
                    return KButton(
                        onPressed: () {
                          if (widget.request.pdfBase64 != null) {
                            PDFViewer.open(
                              context,
                              widget.request.pdfBase64!,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('PDF data is not available')),
                            );
                          }
                        },
                        text: 'view',
                        backgroundColor: const Color.fromRGBO(6, 147, 241, 1),
                        width: 115,
                        height: 50,
                        fontSize: 16.55,
                        padding: const EdgeInsets.only(bottom: 8, top: 8));
                  },
                  title: widget.request.fileName,
                  image: 'assets/project_image/pdf.png'),
              CustomTextField(
                controller: scoreController,
                label: 'Score(in Days)',
                hintText: 'Enter student Score',
                isRequired: true,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: commentController,
                label: 'Comment',
                hintText: 'Enter any notes (optional)',
                isRequired: false,
              ),
              Row(
                children: [
                  Flexible(
                    child: KButton(
                      onPressed: () {
                        _updateStatus('Rejected');
                      },
                      text: null,
                      svgPath: 'assets/project_image/false.svg',
                      svgHeight: 50,
                      svgWidth: 50,
                      height: 65,
                      backgroundColor: const Color.fromRGBO(255, 118, 72, 1),
                    ),
                  ),
                  Flexible(
                    child: KButton(
                      onPressed: () {
                        _updateStatus('Pending');
                      },
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
                      onPressed: () {
                        _updateStatus('Done');
                      },
                      text: null,
                      svgPath: 'assets/project_image/true.svg',
                      svgHeight: 50,
                      svgWidth: 50,
                      height: 65,
                      backgroundColor: const Color.fromRGBO(52, 199, 89, 1),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
