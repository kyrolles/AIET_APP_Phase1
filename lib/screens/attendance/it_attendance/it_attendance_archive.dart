import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/attendance/attendance_model.dart';
import 'package:graduation_project/screens/offline_feature/reusable_offline.dart';

class ITAttendanceArchive extends StatefulWidget {
  const ITAttendanceArchive({Key? key}) : super(key: key);

  @override
  State<ITAttendanceArchive> createState() => _ITAttendanceArchiveState();
}

class _ITAttendanceArchiveState extends State<ITAttendanceArchive> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Approved Attendance Records'),
        backgroundColor: kbabyblue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ReusableOffline(
        child: StreamBuilder<QuerySnapshot>(
          // Remove the orderBy clause to avoid requiring an index
          stream: _firestore
              .collection('attendance')
              .where('status', isEqualTo: 'approved')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No approved attendance records found',
                  style: TextStyle(fontSize: 16, color: kGrey),
                ),
              );
            }

            // Convert documents to AttendanceModel objects
            List<AttendanceModel> attendanceList = snapshot.data!.docs
                .map((doc) => AttendanceModel.fromJson(doc))
                .toList();

            // Sort the list by approvalTimestamp (newest first)
            attendanceList.sort((a, b) {
              if (a.approvalTimestamp == null) return 1;
              if (b.approvalTimestamp == null) return -1;
              return b.approvalTimestamp!.compareTo(a.approvalTimestamp!);
            });

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: attendanceList.length,
              itemBuilder: (context, index) {
                final attendance = attendanceList[index];
                return ArchivedAttendanceCard(attendance: attendance);
              },
            );
          },
        ),
      ),
    );
  }
}

class ArchivedAttendanceCard extends StatelessWidget {
  final AttendanceModel attendance;

  const ArchivedAttendanceCard({
    Key? key,
    required this.attendance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  attendance.subjectName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    attendance.period,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: kGrey),
                const SizedBox(width: 4),
                Text(
                  'Professor: ${attendance.profName ?? "Unknown"}',
                  style: const TextStyle(color: kGrey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: kGrey),
                const SizedBox(width: 4),
                Text(
                  'Students: ${attendance.studentsList?.length ?? 0}',
                  style: const TextStyle(color: kGrey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: kGrey),
                const SizedBox(width: 4),
                Text(
                  'Submitted: ${_formatTimestamp(attendance.timestamp ?? "")}',
                  style: const TextStyle(color: kGrey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Approved: ${_formatTimestamp(attendance.data?['approvalTimestamp'] ?? "")}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            ExpansionTile(
              title: const Text('View Student List'),
              children: [
                if (attendance.studentsList != null &&
                    attendance.studentsList!.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: attendance.studentsList!.length,
                    itemBuilder: (context, index) {
                      final student = attendance.studentsList![index];
                      return ListTile(
                        dense: true,
                        title: Text(student['name'] ?? 'Unknown'),
                        subtitle: Text(student['id'] ?? 'No ID'),
                        trailing: Icon(
                          student['status'] == 'present'
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: student['status'] == 'present'
                              ? Colors.green
                              : Colors.red,
                        ),
                      );
                    },
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No student data available'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return "Unknown";

    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}
