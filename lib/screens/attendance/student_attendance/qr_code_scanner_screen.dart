import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? controller;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      // Get the current user's document
      QuerySnapshot userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: currentUser.email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        Map<String, dynamic> userData = userDoc.docs.first.data() as Map<String, dynamic>;
        return {
          'name': '${userData['firstName']} ${userData['lastName']}'.trim(),
          'id': userData['id']?.toString(),
          'academicYear': userData['academicYear']?.toString(),
          'email': currentUser.email,
        };
      }
      return null;
    } catch (e) {
      print('Error in getCurrentUserData: $e');
      return null;
    }
  }

  void handleScannedCode(String? rawValue) async {
    if (rawValue == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final qrData = json.decode(rawValue);
      final userData = await getCurrentUserData();

      if (userData == null) {
        throw Exception('User data not found - Please check your login status');
      }

      final docRef = _firestore.collection('attendance').doc(qrData['docId']);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw Exception('Attendance session not found');
      }

      final attendanceData = docSnapshot.data() as Map<String, dynamic>;
      final studentList = List<Map<String, dynamic>>.from(attendanceData['studentList'] ?? []);

      // Check if this specific student (using email) has already recorded attendance
      bool isAlreadyPresent = studentList.any((student) =>
      student['email']?.toString() == userData['email']);

      if (isAlreadyPresent) {
        throw Exception('You have already recorded your attendance for this session');
      }

      // Add student to attendance list with all details
      Map<String, dynamic> studentData = {
        'name': userData['name'],
        'id': userData['id'],
        'academicYear': userData['academicYear'],
        'email': userData['email'],
        'timestamp': DateTime.now().toIso8601String()
      };

      await docRef.update({
        'studentList': FieldValue.arrayUnion([studentData])
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance recorded successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        controller?.stop();
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      print('Error details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Scan QR Code',
        onpressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller!,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      handleScannedCode(barcode.rawValue);
                    }
                  },
                ),
                CustomPaint(
                  painter: ScannerOverlay(),
                  child: const SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                if (_isProcessing)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.width * 0.8,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRect(scanArea),
      ),
      paint,
    );

    paint
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(scanArea, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}