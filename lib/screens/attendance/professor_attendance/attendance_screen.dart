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

// Change to StatefulWidget
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final CollectionReference attendance =
      FirebaseFirestore.instance.collection('attendance');

  List<AttendanceModel> periods = [];

  // Add the delete confirmation dialog method
  void _showDeleteConfirmation(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete Attendance'),
        content: const Text('Are you sure you want to delete this attendance record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteAttendance(documentId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Add the delete method
  Future<void> _deleteAttendance(String documentId) async {
    try {
      await attendance.doc(documentId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance record deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting attendance record: $e')),
        );
      }
    }
  }

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
                  existingDocId: periods[i].id,
                ),
              ),
            );
          },
          ontapOnSend: () {},
          onDelete: () => _showDeleteConfirmation(context, periods[i].id),
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
