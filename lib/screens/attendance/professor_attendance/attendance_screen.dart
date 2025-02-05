import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/screens/attendance/attendance_model.dart';
import 'package:graduation_project/screens/attendance/professor_attendance/attendance_archive.dart';
import 'package:graduation_project/screens/attendance/professor_attendance/attendance_item.dart';

import 'attendance_buttom_sheet.dart';

class AttendanceScreen extends StatelessWidget {
  AttendanceScreen({super.key});

  final CollectionReference attendance =
      FirebaseFirestore.instance.collection('attendance');

  List<AttendanceModel> periods = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
          title: 'Attendance', onpressed: () => Navigator.pop(context)),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: attendance.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                periods = [];
                for (var i = 0; i < snapshot.data!.docs.length; i++) {
                  periods.add(AttendanceModel.fromJson(snapshot.data!.docs[i]));
                }
                return ListContainer(
                  title: 'Current attendance',
                  listOfWidgets: currentAttendanceItems(context, periods),
                  emptyMessage: 'No recent attendance found',
                );
              } else {
                return showLoadingIndicator();
              }
            },
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

  List<CurrentAttendanceItem> currentAttendanceItems(
      context, List<AttendanceModel> periods) {
    List<CurrentAttendanceItem> attendanceItems = [];
    for (var i = 0; i < periods.length; i++) {
      attendanceItems.add(
        CurrentAttendanceItem(
          subject: periods[i].subjectName,
          period: periods[i].period,
          startTime: '9:00',
          endTime: '10:30',
          total: periods[i].studentsList.length,
          ontapOnReview: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendanceArchive(
                  subjectName: periods[i].subjectName,
                  period: periods[i].period,
                  existingDocId: periods[i].id, // Pass the existing document ID
                ),
              ),
            );
          },
          ontapOnSend: () {},
        ),
      );
    }
    return attendanceItems;
  }

  Widget showLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Column generateQRcodeButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ServiceItem(
          title: 'Generate QR Code',
          imageUrl: 'assets/project_image/qr-code.png',
          backgroundColor: kDarkBlue,
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
