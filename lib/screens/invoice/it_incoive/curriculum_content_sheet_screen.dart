import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final localizations = AppLocalizations.of(context);

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
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text(
                localizations?.academicContent ?? 'Academic Content',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF6C7072)),
              ),
            ]),
            const SizedBox(height: 16),
            TextAndDataWidget(
                text: '${localizations?.name ?? "Name"} : ',
                data: request.studentName),
            TextAndDataWidget(
                text: '${localizations?.organization ?? "Organization"} : ',
                data: request.addressedTo),
            TextAndDataWidget(
                text: '${localizations?.address ?? "Address"} : ',
                data: request.location),
            TextAndDataWidget(
                text: '${localizations?.phoneNumber ?? "Phone Number"} : ',
                data: request.phoneNumber),
            TextAndDataWidget(
                text: '${localizations?.language ?? "Language"} : ',
                data: request.documentLanguage),
            TextAndDataWidget(
                text: '${localizations?.dateOfBirth ?? "Date of birth"} : ',
                data: request.birthDate),
            TextAndDataWidget(
                text:
                    '${localizations?.locationOfBirth ?? "Location of birth"} : ',
                data: request.loctionOfBirth),
            TextAndDataWidget(
                text: '${localizations?.year ?? "Year"} : ',
                data: request.year),
            TextAndDataWidget(
                text: '${localizations?.department ?? "Department"} : ',
                data: request.department),
            TextAndDataWidget(
                text: '${localizations?.theCause ?? "The Cause"} : ',
                data: request.theCause),
            TextAndDataWidget(
                text: '${localizations?.date ?? "Date"} : ',
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
                  content: localizations?.rejected ?? 'Rejected',
                ),
                const SizedBox(width: 3),
                RejectPendinDoneButton(
                  onpressed: () {
                    log('Pending button pressed for request: ${request.studentId}');
                    pendingFunctionality();
                  },
                  color: const Color(0XFFFFDD29),
                  content: localizations?.pending ?? 'Pending',
                ),
                const SizedBox(width: 3),
                RejectPendinDoneButton(
                  onpressed: () {
                    log('Done button pressed for request: ${request.studentId}');
                    doneFunctionality();
                  },
                  color: const Color(0xFF34C759),
                  content: localizations?.done ?? 'Done',
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
