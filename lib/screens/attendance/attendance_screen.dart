import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:graduation_project/constants.dart';

class AttendanceScreen extends StatelessWidget {
  AttendanceScreen({super.key});

  final List periods = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
          title: 'Attendance', onpressed: () => Navigator.pop(context)),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: const Color(0XFFFAFAFA),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  currentAttendanceText(),
                  currentAttendanceList(),
                ],
              ),
            ),
          ),
          const Divider(
            color: kLightGrey,
            indent: 10,
            endIndent: 10,
            height: 10,
          ),
          generateQRcodeButton(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Column generateQRcodeButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ServiceItem(
          title: 'Generate QR Code',
          imageUrl: 'assets/project_image/qr-code.png',
          backgroundColor: Colors.blue,
          onPressed: () {},
        ),
      ],
    );
  }

  Expanded currentAttendanceList() {
    return Expanded(
      child: periods.isEmpty
          ? const Center(
              child: Text(
                'No recent attendance found',
                style: TextStyle(color: kGrey),
              ),
            )
          : ListView.builder(
              itemBuilder: (context, index) {
                return Container();
              },
              itemCount: 10,
            ),
    );
  }

  Container currentAttendanceText() {
    return Container(
      margin: const EdgeInsets.only(top: 15.0, left: 15.0),
      child: const Text('Current attendance', style: kTextStyleBold),
    );
  }
}
