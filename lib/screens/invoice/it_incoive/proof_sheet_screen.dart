import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';
import 'dart:developer';
import '../../../components/rpd_button.dart';
import '../../../models/request_model.dart';

class ProofOfEnrollmentSheetScreen extends StatelessWidget {
  const ProofOfEnrollmentSheetScreen(
      {super.key,
      required this.doneFunctionality,
      required this.rejectedFunctionality,
      required this.pendingFunctionality,
      required this.request});

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
                    'Proof of enrollment',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF6C7072)),
                  ),
                ]),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                children: [
                  const Text(
                    'Name : ',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    request.studentName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                children: [
                  const Text(
                    'Organization : ',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    request.addressedTo,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                children: [
                  const Text(
                    'Address : ',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    request.location,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                children: [
                  const Text(
                    'Phone Number : ',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    request.phoneNumber,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                children: [
                  const Text(
                    '(Institute/Ministry) : ',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    request.stampType,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
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
