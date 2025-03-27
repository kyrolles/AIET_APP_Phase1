import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // Add this import for json

class ProfessorQRScannerScreen extends StatefulWidget {
  final String documentId;
  
  const ProfessorQRScannerScreen({
    super.key,
    required this.documentId,
  });

  @override
  State<ProfessorQRScannerScreen> createState() => _ProfessorQRScannerScreenState();
}

class _ProfessorQRScannerScreenState extends State<ProfessorQRScannerScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Student QR Code'),
      ),
      body: Stack(
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
                  _showErrorDialog('Error processing QR code: ${e.toString()}');
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
      print("Raw QR code: $qrCode"); // Debug log
      
      // First try to parse as JSON (for attendance QR codes)
      Map<String, dynamic> qrData;
      try {
        qrData = json.decode(qrCode);
        print("Parsed QR data: $qrData"); // Debug log
        
        // If we got here, it's a JSON QR code
        if (qrData.containsKey('id')) {
          // This is a student QR code
          String studentId = qrData['id'].toString();
          print("Found student ID in JSON: $studentId"); // Debug log
          await _addStudentById(studentId);
        } else {
          // Try to extract ID from the QR code text directly
          String directId = qrCode.trim();
          // Remove any non-numeric characters if it's just a number
          if (RegExp(r'^\d+$').hasMatch(directId)) {
            print("Using direct numeric ID: $directId"); // Debug log
            await _addStudentById(directId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid QR code format')),
            );
          }
        }
      } catch (e) {
        print("JSON parse error: $e"); // Debug log
        
        // If not JSON, try to use it directly as a student ID
        // First check if it's just a number
        String directId = qrCode.trim();
        if (RegExp(r'^\d+$').hasMatch(directId)) {
          print("Using direct numeric ID after JSON fail: $directId"); // Debug log
          await _addStudentById(directId);
        } else {
          // Try to extract a number from the QR code
          RegExp regExp = RegExp(r'(\d{7,})'); // Look for 7+ digit numbers (typical student IDs)
          Match? match = regExp.firstMatch(qrCode);
          
          if (match != null && match.group(1) != null) {
            String extractedId = match.group(1)!;
            print("Extracted ID from text: $extractedId"); // Debug log
            await _addStudentById(extractedId);
          } else {
            print("No valid ID found in QR code"); // Debug log
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No valid student ID found in QR code')),
            );
          }
        }
      }
    } catch (e) {
      print("General error: $e"); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing QR code: $e')),
      );
    }
  }

  Future<void> _addStudentById(String studentId) async {
    try {
      print("Searching for student with ID: $studentId"); // Debug log
      
      // Clean up the student ID - remove any non-numeric characters
      studentId = studentId.replaceAll(RegExp(r'[^\d]'), '');
      
      // Check if student exists
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: studentId)
          .where('role', isEqualTo: 'Student')
          .get();
      
      if (userSnapshot.docs.isEmpty) {
        print("No student found with exact ID match, trying numeric conversion"); // Debug log
        // Try again with different data type
        int? numericId = int.tryParse(studentId);
        if (numericId != null) {
          userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('id', isEqualTo: numericId.toString())
              .where('role', isEqualTo: 'Student')
              .get();
        }
      }
      
      // If still not found, try without role filter
      if (userSnapshot.docs.isEmpty) {
        print("Trying without role filter"); // Debug log
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
      
      // Get student data
      DocumentSnapshot studentDoc = userSnapshot.docs.first;
      Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;
      
      // Check if student is already in attendance
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
      
      Map<String, dynamic> attendanceData = attendanceDoc.data() as Map<String, dynamic>;
      List<dynamic> studentList = attendanceData['studentList'] ?? [];
      
      // Check if student is already in the list
      bool studentExists = studentList.any((student) => student['id'] == studentId);
      
      if (studentExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student already in attendance list')),
        );
        return;
      }
      
      // Add student to attendance
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.documentId)
          .update({
        'studentList': FieldValue.arrayUnion([{
          'id': studentData['id'],
          'name': studentData['name'] ?? 
                 ((studentData['firstName'] != null ? 
                   studentData['firstName'] + " " + (studentData['lastName'] ?? "") : 
                   "Unknown")),
          'email': studentData['email'] ?? "",
          'timestamp': Timestamp.now(),
          'subjectName': attendanceData['subjectName'] ?? "",
          'academicYear': studentData['academicYear'] ?? ""
        }])
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully')),
      );
      
      // Navigate back to attendance screen
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
