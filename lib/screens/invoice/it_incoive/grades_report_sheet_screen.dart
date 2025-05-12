import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';
import '../../../components/rpd_button.dart';
import '../../../models/request_model.dart';
import 'textAndDataWidget.dart';

class GradesReportSheetScreen extends StatelessWidget {
  const GradesReportSheetScreen({
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

    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Grades Report',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF6C7072)),
                  ),
                ]),
            TextAndDataWidget(text: 'Name : ', data: request.studentName),
            TextAndDataWidget(
                text: 'Organization : ', data: request.addressedTo),
            TextAndDataWidget(text: 'Address : ', data: request.location),
            TextAndDataWidget(
                text: 'Phone Number : ', data: request.phoneNumber),
            TextAndDataWidget(
                text: '(Institute/Ministry) : ', data: request.stampType),
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
