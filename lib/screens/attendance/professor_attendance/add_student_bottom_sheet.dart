import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/screens/offline_feature/reusable_offline_bottom_sheet.dart';
import 'professor_qr_code_scanner_screen.dart';
import 'add_student_manually_bottom_sheet.dart';

class AddStudentBottomSheet extends StatelessWidget {
  final String documentId;

  const AddStudentBottomSheet({
    super.key,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Enter Student Name & ID",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
          const SizedBox(height: 20),
          KButton(
            onPressed: () {
              OfflineAwareBottomSheet.show(
                context: context,
                isScrollControlled: true,
                onlineContent: AddStudentManuallyBottmSheet(
                  documentId: documentId,
                ),
              );
            },
            text: 'Manual',
            fontSize: 22,
            textColor: Colors.white,
            backgroundColor: const Color(0xFF978ECB),
            borderColor: Colors.white,
          ),
          const SizedBox(height: 15),
          KButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfessorQRScannerScreen(
                    documentId: documentId,
                  ),
                ),
              );
            },
            text: 'Using Stu QR Code',
            fontSize: 22,
            textColor: Colors.white,
            backgroundColor: const Color(0xFF0ED290),
            borderColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
