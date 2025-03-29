import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/attendance/attendance_model.dart';
import 'package:graduation_project/screens/attendance/professor_attendance/attendance_archive.dart';
import 'package:graduation_project/screens/attendance/it_attendance/it_attendance_archive.dart';

class ITAttendanceScreen extends StatefulWidget {
  const ITAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<ITAttendanceScreen> createState() => _ITAttendanceScreenState();
}

class _ITAttendanceScreenState extends State<ITAttendanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('IT Attendance Management'),
        backgroundColor: kbabyblue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ITAttendanceArchive(),
                ),
              );
            },
            tooltip: 'View Archive',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('attendance')
            .where('status', isEqualTo: 'pending')
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
                'No pending attendance records found',
                style: TextStyle(fontSize: 16, color: kGrey),
              ),
            );
          }

          // Convert documents to AttendanceModel objects
          List<AttendanceModel> attendanceList = snapshot.data!.docs
              .map((doc) => AttendanceModel.fromJson(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: attendanceList.length,
            itemBuilder: (context, index) {
              final attendance = attendanceList[index];
              return AttendanceCard(
                attendance: attendance,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceArchive(
                        subjectName: attendance.subjectName,
                        period: attendance.period,
                        existingDocId: attendance.id,
                      ),
                    ),
                  );
                },
                onApprove: () => _approveAttendance(attendance.id),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _approveAttendance(String docId) async {
    try {
      await _firestore.collection('attendance').doc(docId).update({
        'status': 'approved',
        'approvalTimestamp': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class AttendanceCard extends StatelessWidget {
  final AttendanceModel attendance;
  final VoidCallback onEdit;
  final VoidCallback onApprove;

  const AttendanceCard({
    Key? key,
    required this.attendance,
    required this.onEdit,
    required this.onApprove,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    attendance.period,
                    style: const TextStyle(
                      color: kDarkBlue,
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
            // Inside the AttendanceCard build method
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kBlue,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
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