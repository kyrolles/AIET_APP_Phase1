import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/attendance/professor_attendance/add_student_bottom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'dart:convert';

class AttendanceArchive extends StatefulWidget {
  final String? subjectName;
  final String? period;
  final String? existingDocId;

  const AttendanceArchive({
    super.key,
    this.subjectName,
    this.period,
    this.existingDocId,
  });

  @override
  State<AttendanceArchive> createState() => _AttendanceArchiveState();
}

class _AttendanceArchiveState extends State<AttendanceArchive> {
  String userName = '';
  String? qrData;
  String? currentDocId;
  String? originalTimestamp;
  List<Map<String, dynamic>> attendanceList = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _attendanceSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.existingDocId != null) {
      currentDocId = widget.existingDocId;
      fetchExistingDocument();
    } else if (widget.subjectName != null && widget.period != null) {
      createAttendanceDocument();
    }
    fetchUserName();
  }

  @override
  void dispose() {
    _attendanceSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchExistingDocument() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('attendance').doc(currentDocId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        originalTimestamp = data['timestamp'];
        generateQRCode();
        listenToAttendanceDocument();
      }
    } catch (e) {
      print('Error fetching existing document: $e');
    }
  }

  void listenToAttendanceDocument() {
    if (currentDocId != null) {
      _attendanceSubscription = _firestore
          .collection('attendance')
          .doc(currentDocId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final List<dynamic> studentList = data['studentList'] ?? [];

          setState(() {
            attendanceList = studentList.map<Map<String, dynamic>>((student) {
              return {
                'name': student['name'] ?? '',
                'id': student['id'] ?? '',
                'academicYear': student['academicYear'] ?? '',
                'email': student['email'] ?? '',
              };
            }).toList();
          });
        }
      });
    }
  }

  Future<void> fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;

        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          setState(() {
            userName = '${userDoc['firstName']} ${userDoc['lastName']}'.trim();
          });
        }
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  Future<void> createAttendanceDocument() async {
    try {
      String timestamp = DateTime.now().toIso8601String();
      DocumentReference docRef = await _firestore.collection('attendance').add({
        'email': FirebaseAuth.instance.currentUser?.email,
        'period': widget.period,
        'subjectName': widget.subjectName,
        'profName': userName,
        'studentList': [],
        'timestamp': timestamp,
      });

      setState(() {
        currentDocId = docRef.id;
        originalTimestamp = timestamp;
      });

      generateQRCode();
      listenToAttendanceDocument();
    } catch (e) {
      print('Error creating attendance document: $e');
    }
  }

  void generateQRCode() {
    qrData = json.encode({
      'subjectName': widget.subjectName,
      'period': widget.period,
      'docId': currentDocId,
      'timestamp': originalTimestamp // Use the original timestamp
    });
    setState(() {});
  }

  void removeStudent(int index) async {
    try {
      if (currentDocId != null) {
        final studentToRemove = attendanceList[index];

        setState(() {
          attendanceList.removeAt(index);
        });

        await _firestore.collection('attendance').doc(currentDocId).update({
          'studentList': FieldValue.arrayRemove([studentToRemove])
        });
      }
    } catch (e) {
      print('Error removing student: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error removing student'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> confirmAttendance() async {
    try {
      if (currentDocId != null) {
        await _firestore.collection('attendance').doc(currentDocId).update({
          'status': 'confirmed',
          'confirmationTimestamp': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance confirmed successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      print('Error confirming attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error confirming attendance'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: MyAppBar(
        title: 'Attendance',
        onpressed: () => Navigator.pop(context),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: qrData != null
                    ? QrImageView(
                        data: qrData!,
                        version: QrVersions.auto,
                        size: 180,
                        backgroundColor: Colors.white,
                      )
                    : const SizedBox(
                        height: 180,
                        width: 180,
                        child: Center(child: Text('QR Code')),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Attendance List',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ListView.builder(
                itemCount: attendanceList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[100],
                      child: Icon(Icons.person, color: Colors.grey[400]),
                    ),
                    title: Text(
                      attendanceList[index]['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      'ID: ${attendanceList[index]['id']} - Year: ${attendanceList[index]['academicYear']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => removeStudent(index),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: KButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddStudentBottomSheet();
                        },
                      );
                    },
                    text: 'Add Stu +',
                    fontSize: 20,
                    textColor: Colors.black87,
                    backgroundColor: Colors.black12,
                    borderColor: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KButton(
                    onPressed: confirmAttendance,
                    text: 'Confirm',
                    fontSize: 20,
                    textColor: Colors.white,
                    backgroundColor: kBlue,
                    borderColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
