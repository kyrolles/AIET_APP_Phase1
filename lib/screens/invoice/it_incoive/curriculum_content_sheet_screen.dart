import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';
import '../../../components/rpd_button.dart';
import '../../../models/request_model.dart';

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
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Name: ${request.studentName}',
                style: kTextStyleNormal),
            const SizedBox(height: 10),
            Text('ID: ${request.studentId}', style: kTextStyleNormal),
            const SizedBox(height: 10),
            Text('Organization: ${request.addressedTo}',
                style: kTextStyleNormal),
            const SizedBox(height: 10),
            Text('Address: ${request.location}', style: kTextStyleNormal),
            const SizedBox(height: 10),
            Text('Phone Number: ${request.phoneNumber}',
                style: kTextStyleNormal),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RejectPendinDoneButton(
                  onpressed: rejectedFunctionality,
                  color: const Color(0XFFFF7648),
                  content: 'Rejected',
                ),
                const SizedBox(width: 3),
                RejectPendinDoneButton(
                  onpressed: pendingFunctionality,
                  color: const Color(0XFFFFDD29),
                  content: 'Pending',
                ),
                const SizedBox(width: 3),
                RejectPendinDoneButton(
                  onpressed: doneFunctionality,
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
