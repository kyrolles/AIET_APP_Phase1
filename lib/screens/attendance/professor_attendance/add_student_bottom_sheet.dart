import 'package:flutter/material.dart';
import 'professor_qr_code_scanner_screen.dart';
import 'add_student_manually_bottom_sheet.dart';

class AddStudentBottomSheet extends StatelessWidget {
  const AddStudentBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Enter Student Name & ID",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return const AddStudentManuallyBottmSheet();
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF978ECB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              minimumSize: const Size(double.infinity, 55),
            ),
            child: const Text("Manual",
                style: TextStyle(color: Color(0xFFFFFFFF))),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfessorQRScannerScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0ED290),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              minimumSize: const Size(double.infinity, 55),
            ),
            child: const Text("Using Stu QR Code",
                style: TextStyle(color: Color(0xFFFFFFFF))),
          ),
        ],
      ),
    );
  }
}