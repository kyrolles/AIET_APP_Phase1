import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/components/list_container.dart';

import 'attendance_buttom_sheet.dart';

class AttendanceScreen extends StatelessWidget {
  AttendanceScreen({super.key});

  final List<Widget> periods = [
    CurrentAttendanceItem(
      subject: 'Microprocessor',
      period: 'P1',
      startTime: '9:00',
      endTime: '10:30',
      total: 34,
      ontapOnReview: () {},
      ontapOnSend: () {},
    ),
    CurrentAttendanceItem(
      subject: 'Data Structure',
      period: 'P2',
      startTime: '10:40',
      endTime: '12:10',
      total: 32,
      ontapOnReview: () {},
      ontapOnSend: () {},
    ),
  ];

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
}

class CurrentAttendanceItem extends StatelessWidget {
  const CurrentAttendanceItem({
    super.key,
    required this.subject,
    required this.period,
    required this.startTime,
    required this.endTime,
    required this.total,
    required this.ontapOnReview,
    required this.ontapOnSend,
  });

  final String subject;
  final String period;
  final String startTime;
  final String endTime;
  final int total;
  final Function() ontapOnReview;
  final Function() ontapOnSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          spacing: 10,
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFEB8991),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(child: Text(period, style: kTextStyleBold)),
            ),
            Text(startTime, style: kTextStyleNormal),
            Text(
              endTime,
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 16,
                color: kGrey,
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
              decoration: BoxDecoration(
                color: kGreyLight,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(subject, style: kTextStyleBold),
                      const Icon(Icons.close, color: kGrey),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Total: ', style: kTextStyleNormal),
                      Text(
                        "$total",
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w600,
                          fontSize: 34,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: ontapOnReview,
                        child: const Text('Review'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: ontapOnSend,
                        child: const Text('Send'),
                      ),
                    ],
                  )
                ],
              )),
        ),
      ],
    );
  }
}
