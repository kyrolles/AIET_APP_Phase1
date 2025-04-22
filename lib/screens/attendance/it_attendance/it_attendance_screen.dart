import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/attendance/attendance_model.dart';
import 'package:graduation_project/screens/attendance/professor_attendance/attendance_archive.dart';
import 'package:graduation_project/screens/attendance/it_attendance/it_attendance_archive.dart';
import 'package:graduation_project/screens/offline_feature/reusable_offline.dart';

class ITAttendanceScreen extends StatefulWidget {
  const ITAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<ITAttendanceScreen> createState() => _ITAttendanceScreenState();
}

class _ITAttendanceScreenState extends State<ITAttendanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'IT Attendance Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: kbabyblue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined, color: Colors.black),
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
      body: ReusableOffline(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('attendance')
                    .where('status', isEqualTo: 'pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: kbabyblue),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(fontSize: 16, color: kGrey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'No pending attendance records',
                            style: TextStyle(
                                fontSize: 18,
                                color: kGrey,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All attendance records have been processed',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

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
                        onApprove: () =>
                            _showApproveConfirmation(context, attendance),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveConfirmation(
      BuildContext context, AttendanceModel attendance) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Approve Attendance'),
        content: Text(
          'Are you sure you want to approve the attendance record for ${attendance.subjectName} (${attendance.period})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _approveAttendance(attendance.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveAttendance(String docId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('attendance').doc(docId).update({
        'status': 'approved',
        'approvalTimestamp': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance approved successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving attendance: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.class_, color: kDarkBlue, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    attendance.subjectName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kDarkBlue,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: kbabyblue,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    attendance.period,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.person, 'Professor',
                    attendance.profName ?? "Unknown"),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.people, 'Students',
                    '${attendance.studentsList?.length ?? 0}'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.access_time, 'Submitted',
                    _formatTimestamp(attendance.timestamp ?? "")),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo,
                        backgroundColor: Colors.indigo.shade50,
                        side:
                            const BorderSide(color: Colors.indigo, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: kGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
