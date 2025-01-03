import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/components/list_container.dart';

import 'attendance_buttom_sheet.dart';

class AttendanceScreen extends StatelessWidget {
  AttendanceScreen({super.key});

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
          title: 'Generate QR Code',
          imageUrl: 'assets/project_image/qr-code.png',
          backgroundColor: Colors.blue,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return const AttendanceButtomSheet();
              },
            );
          },
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
