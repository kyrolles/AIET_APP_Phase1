import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'professor_qr_code_scanner_screen.dart';
import 'add_student_manually_bottom_sheet.dart';

class AddStudentBottomSheet extends StatelessWidget {
  const AddStudentBottomSheet({super.key});

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
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return const AddStudentManuallyBottmSheet();
                },
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
                  builder: (context) => const ProfessorQRScannerScreen(),
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
