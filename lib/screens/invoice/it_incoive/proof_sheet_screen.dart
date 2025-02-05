import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';
import '../../../components/rpd_button.dart';
import 'request_model.dart';

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
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'اثبات القيد',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF6C7072)),
                  ),
                ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    request.studentName,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Text(
                    '   : الاسم',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    request.addressedTo,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Text(
                    '   : الجهة الموجه إليها',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  request.stamp
                      ? Checkbox(
                          value: request.stamp,
                          onChanged: null, // Disable interaction
                        )
                      : const Icon(
                          Icons
                              .cancel_presentation_outlined, // Use a cross icon
                          color: kGrey, // Customize the color
                          size: 24, // Adjust the size
                        ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'هل تريد ختم النسر ؟',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        '(!ملحوظة: سيأخذ الكثير من الوقت)',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
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
