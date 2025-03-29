import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/screens/attendance/professor_attendance/attendance_screen.dart';
import 'package:graduation_project/screens/attendance/student_attendance/student_attendance_screen.dart';

class AttendanceRouter extends StatelessWidget {
  const AttendanceRouter({super.key});

  Future<String?> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return doc.data()?['role'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Error loading user data'),
            ),
          );
        }

        final role = snapshot.data;

        
        if (role == 'Student') {
          return StudentAttendanceScreen();
        }

        
        return const AttendanceScreen();
      },
    );
  }
}