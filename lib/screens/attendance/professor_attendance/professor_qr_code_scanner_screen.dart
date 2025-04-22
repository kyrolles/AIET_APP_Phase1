import 'package:flutter/material.dart';
import 'package:graduation_project/screens/offline_feature/reusable_offline.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class ProfessorQRScannerScreen extends StatefulWidget {
  final String documentId;

  const ProfessorQRScannerScreen({
    super.key,
    required this.documentId,
  });

  @override
  State<ProfessorQRScannerScreen> createState() =>
      _ProfessorQRScannerScreenState();
}

class _ProfessorQRScannerScreenState extends State<ProfessorQRScannerScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Student QR Code'),
      ),
      body: ReusableOffline(
        child: Stack(
          children: [
            MobileScanner(
              onDetect: (capture) async {
                if (_isProcessing) return;

                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  setState(() {
                    _isProcessing = true;
                  });

                  try {
                    final String qrCode = barcodes.first.rawValue ?? '';
                    await _processScannedQRCode(qrCode);
                  } catch (e) {
                    _showErrorDialog(
                        'Error processing QR code: ${e.toString()}');
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isProcessing = false;
                      });
                    }
                  }
                }
              },
            ),
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _processScannedQRCode(String qrCode) async {
    try {
      Map<String, dynamic> qrData;
      try {
        qrData = json.decode(qrCode);

        if (qrData.containsKey('id')) {
          String studentId = qrData['id'].toString();
          await _addStudentById(studentId);
        } else {
          String directId = qrCode.trim();
          if (RegExp(r'^\d+$').hasMatch(directId)) {
            await _addStudentById(directId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid QR code format')),
            );
          }
        }
      } catch (e) {
        String directId = qrCode.trim();
        if (RegExp(r'^\d+$').hasMatch(directId)) {
          await _addStudentById(directId);
        } else {
          RegExp regExp = RegExp(r'(\d{7,})');
          Match? match = regExp.firstMatch(qrCode);

          if (match != null && match.group(1) != null) {
            String extractedId = match.group(1)!;
            await _addStudentById(extractedId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No valid student ID found in QR code')),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing QR code: $e')),
      );
    }
  }

  Future<void> _addStudentById(String studentId) async {
    try {
      studentId = studentId.replaceAll(RegExp(r'[^\d]'), '');

      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: studentId)
          .where('role', isEqualTo: 'Student')
          .get();

      if (userSnapshot.docs.isEmpty) {
        int? numericId = int.tryParse(studentId);
        if (numericId != null) {
          userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('id', isEqualTo: numericId.toString())
              .where('role', isEqualTo: 'Student')
              .get();
        }
      }

      if (userSnapshot.docs.isEmpty) {
        userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('id', isEqualTo: studentId)
            .get();
      }

      if (userSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No student found with ID: $studentId')),
        );
        return;
      }

      DocumentSnapshot studentDoc = userSnapshot.docs.first;
      Map<String, dynamic> studentData =
          studentDoc.data() as Map<String, dynamic>;

      DocumentSnapshot attendanceDoc = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.documentId)
          .get();

      if (!attendanceDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance record not found')),
        );
        return;
      }

      Map<String, dynamic> attendanceData =
          attendanceDoc.data() as Map<String, dynamic>;
      List<dynamic> studentList = attendanceData['studentList'] ?? [];

      bool studentExists =
          studentList.any((student) => student['id'] == studentId);

      if (studentExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student already in attendance list')),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.documentId)
          .update({
        'studentList': FieldValue.arrayUnion([
          {
            'id': studentData['id'],
            'name': studentData['name'] ??
                ((studentData['firstName'] != null
                    ? studentData['firstName'] +
                        " " +
                        (studentData['lastName'] ?? "")
                    : "Unknown")),
            'email': studentData['email'] ?? "",
            'timestamp': Timestamp.now(),
            'subjectName': attendanceData['subjectName'] ?? "",
            'academicYear': studentData['academicYear'] ?? ""
          }
        ])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully')),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding student: $e')),
      );
    }
  }
}
