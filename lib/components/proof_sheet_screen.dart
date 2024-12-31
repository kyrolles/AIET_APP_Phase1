import 'package:flutter/material.dart';
import 'rpd_button.dart';
import '../constants.dart';
import '../screens/it_invoice_screen.dart';

class ProofOfEnrollmentSheetScreen extends StatefulWidget {
  const ProofOfEnrollmentSheetScreen({
    super.key,
    required this.doneFunctionality,
    required this.rejectedFunctionality,
    required this.pendingFunctionality,
  });
  final Function() doneFunctionality;
  final Function() rejectedFunctionality;
  final Function() pendingFunctionality;

  @override
  State<ProofOfEnrollmentSheetScreen> createState() =>
      _ProofOfEnrollmentSheetScreenState();
}

class _ProofOfEnrollmentSheetScreenState
    extends State<ProofOfEnrollmentSheetScreen> {
  bool? isChecked = false;

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
            const SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'كيرلس رافت لمعي ابراهيم',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '   : الاسم',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'مصلحة الضرائب',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
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
                  Checkbox(
                    value: isChecked,
                    activeColor: kPrimary,
                    onChanged: (newBool) {
                      setState(() {
                        isChecked = newBool ?? false;
                      });
                    },
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
                  onpressed: widget.rejectedFunctionality,
                  color: const Color(0XFFFF7648),
                  content: 'Rejected',
                ),
                const SizedBox(width: 3),
                RejectPendinDoneButton(
                    onpressed: widget.pendingFunctionality,
                    color: const Color(0XFFFFDD29),
                    content: 'Pending'),
                const SizedBox(width: 3),
                RejectPendinDoneButton(
                    onpressed: widget.doneFunctionality,
                    color: const Color(0xFF34C759),
                    content: 'Done'),
              ],
            )
          ],
        ),
      ),
    );
  }
}
