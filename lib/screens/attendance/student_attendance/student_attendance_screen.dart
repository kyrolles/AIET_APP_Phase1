import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/screens/attendance/student_attendance/qr_code_scanner_screen.dart';

class StudentAttendanceScreen extends StatelessWidget {
  StudentAttendanceScreen({super.key});

  final List<Widget> periods = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
          title: 'Attendance', onpressed: () => Navigator.pop(context)),
      body: Column(
        children: [
          ListContainer(
            title: 'Current attendance',
            listOfWidgets: periods,
            emptyMessage: 'No recent attendance found',
          ),
          const Divider(
            color: kLightGrey,
            indent: 10,
            endIndent: 10,
            height: 10,
          ),
          generateQRcodeButton(context),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Column generateQRcodeButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ServiceItem(
          title: 'Scan QR Code',
          imageUrl: 'assets/project_image/qr-code.png',
          backgroundColor: Colors.blue,
          onPressed: () {
            // Replace showModalBottomSheet with Navigator.push
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QRScannerScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
