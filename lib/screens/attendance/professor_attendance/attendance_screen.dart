import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/screens/attendance/attendance_model.dart';
import 'package:graduation_project/screens/attendance/professor_attendance/attendance_archive.dart';
import 'package:graduation_project/screens/attendance/professor_attendance/attendance_item.dart';
import 'package:graduation_project/screens/offline_feature/reusable_offline.dart';
import 'package:graduation_project/screens/offline_feature/reusable_offline_bottom_sheet.dart';

import 'attendance_buttom_sheet.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final CollectionReference attendance =
      FirebaseFirestore.instance.collection('attendance');
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  List<AttendanceModel> periods = [];
  void _showDeleteConfirmation(BuildContext context, String documentId) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(localizations?.deleteAttendance ?? 'Delete Attendance'),
        content: Text(localizations?.deleteAttendanceConfirmation ??
            'Are you sure you want to delete this attendance record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(localizations?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteAttendance(documentId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAttendance(String documentId) async {
    final localizations = AppLocalizations.of(context);

    try {
      await attendance.doc(documentId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations?.attendanceDeletedSuccess ??
                  'Attendance record deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${localizations?.errorDeletingAttendance ?? "Error deleting attendance record"}: $e')),
        );
      }
    }
  }

  Future<void> _updateAttendanceStatus(String documentId) async {
    try {
      await attendance.doc(documentId).update({'status': 'pending'});
      setState(() {
        periods.removeWhere((period) => period.id == documentId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance status updated to pending')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating attendance status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: MyAppBar(
          title: localizations?.attendance ?? 'Attendance',
          onpressed: () => Navigator.pop(context)),
      body: ReusableOffline(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('attendance')
                  .where('status', isEqualTo: 'none')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return showLoadingIndicator();
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        '${localizations?.error ?? "Error"}: ${snapshot.error}'),
                  );
                }

                if (snapshot.hasData) {
                  final docs = snapshot.data!.docs;

                  return ListContainer(
                    title: localizations?.currentAttendance ??
                        'Current attendance',
                    listOfWidgets: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      List? studentsList;
                      if (data.containsKey('studentList')) {
                        studentsList = data['studentList'] as List?;
                      } else if (data.containsKey('studentsList')) {
                        studentsList = data['studentsList'] as List?;
                      }

                      final studentCount = studentsList?.length ?? 0;

                      return CurrentAttendanceItem(
                        subject: data['subjectName'] ?? '',
                        period: data['period'] ?? '',
                        startTime: _getStartTimeForPeriod(data['period'] ?? ''),
                        endTime: _getEndTimeForPeriod(data['period'] ?? ''),
                        total: studentCount,
                        className: data['className'] ?? '',
                        ontapOnReview: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendanceArchive(
                                subjectName: data['subjectName'] ?? '',
                                period: data['period'] ?? '',
                                existingDocId: doc.id,
                              ),
                            ),
                          );
                        },
                        ontapOnSend: () => _updateAttendanceStatus(doc.id),
                        onDelete: () =>
                            _showDeleteConfirmation(context, doc.id),
                      );
                    }).toList(),
                    emptyMessage: localizations?.noRecentAttendance ??
                        'No recent attendance found',
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
      ),
    );
  }

  Widget showLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Column generateQRcodeButton(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ServiceItem(
          title: localizations?.generateQRCode ?? 'Generate QR Code',
          imageUrl: 'assets/project_image/qr-code.png',
          backgroundColor: kDarkBlue,
          onPressed: () {
            OfflineAwareBottomSheet.show(
              context: context,
              onlineContent: const AttendanceButtomSheet(defaultStatus: 'none'),
            );
          },
        ),
      ],
    );
  }
}

String _getStartTimeForPeriod(String period) {
  switch (period) {
    case '1':
      return '9:00';
    case '2':
      return '10:40';
    case '3':
      return '12:20';
    case '4':
      return '2:00';
    default:
      return '9:00';
  }
}

String _getEndTimeForPeriod(String period) {
  switch (period) {
    case '1':
      return '10:30';
    case '2':
      return '12:10';
    case '3':
      return '1:50';
    case '4':
      return '3:30';
    default:
      return '10:30';
  }
}
