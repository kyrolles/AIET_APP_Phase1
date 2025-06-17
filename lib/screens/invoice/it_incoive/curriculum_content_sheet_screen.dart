import 'dart:developer';

import 'package:flutter/material.dart';
import '../../../components/rpd_button.dart';
import '../../../models/request_model.dart';
import 'textAndDataWidget.dart';

class CurriculumContentSheetScreen extends StatelessWidget {
  const CurriculumContentSheetScreen({
    super.key,
    required this.doneFunctionality,
    required this.rejectedFunctionality,
    required this.pendingFunctionality,
    required this.request,
  });

  final Function() doneFunctionality;
  final Function() rejectedFunctionality;
  final Function() pendingFunctionality;
  final Request request;

  @override
  Widget build(BuildContext context) {
    // Log the initial state for debugging
    log('ProofOfEnrollmentSheetScreen opened for request:');
    log('Student ID: ${request.studentId}');
    log('Student Name: ${request.studentName}');
    log('Addressed To: ${request.addressedTo}');
    log('Current Status: ${request.status}');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 24.0,
        ),
        child: Column(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Academic Content',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF6C7072)),
                  ),
                ]),
            const SizedBox(height: 16),
            TextAndDataWidget(text: 'Name : ', data: request.studentName),
            TextAndDataWidget(
                text: 'Organization : ', data: request.addressedTo),
            TextAndDataWidget(text: 'Address : ', data: request.location),
            TextAndDataWidget(
                text: 'Phone Number : ', data: request.phoneNumber),
            TextAndDataWidget(
                text: 'Language : ', data: request.documentLanguage),
            TextAndDataWidget(
                text: 'Date of birth : ', data: request.birthDate),
            TextAndDataWidget(
                text: 'Location of birth : ', data: request.loctionOfBirth),
            TextAndDataWidget(text: 'Year : ', data: request.year),
            TextAndDataWidget(text: 'Department : ', data: request.department),
            TextAndDataWidget(text: 'The Cause : ', data: request.theCause),
            TextAndDataWidget(
                text: 'Date : ',
                data:
                    '${request.createdAt.toDate().year}-${request.createdAt.toDate().month}-${request.createdAt.toDate().day}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RejectPendinDoneButton(
                  onpressed: () {
                    log('Rejected button pressed for request: ${request.studentId}');
                    rejectedFunctionality();
                  },
                  color: const Color(0XFFFF7648),
                  content: 'Rejected',
                ),
                const SizedBox(width: 3),
                RejectPendinDoneButton(
                  onpressed: () {
                    log('Pending button pressed for request: ${request.studentId}');
                    pendingFunctionality();
                  },
                  color: const Color(0XFFFFDD29),
                  content: 'Pending',
                ),
                const SizedBox(width: 3),
                RejectPendinDoneButton(
                  onpressed: () {
                    log('Done button pressed for request: ${request.studentId}');
                    doneFunctionality();
                  },
                  color: const Color(0xFF34C759),
                  content: 'Done',
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
