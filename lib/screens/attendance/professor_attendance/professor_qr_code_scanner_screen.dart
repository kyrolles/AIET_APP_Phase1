import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessorQRScannerScreen extends StatefulWidget {
  const ProfessorQRScannerScreen({super.key});

  @override
  State<ProfessorQRScannerScreen> createState() => _ProfessorQRScannerScreenState();
}

class _ProfessorQRScannerScreenState extends State<ProfessorQRScannerScreen> {
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

  Future<Map<String, dynamic>?> getStudentDataFromQRCode(String qrCode) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('qrCode', isEqualTo: qrCode)
          .where('role', isEqualTo: 'Student')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      DocumentSnapshot studentDoc = querySnapshot.docs.first;
      Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;

      return {
        'name': '${studentData['firstName']} ${studentData['lastName']}'.trim(),
        'id': studentData['id'],
        'academicYear': studentData['academicYear'],
        'email': studentData['email'],
      };
    } catch (e) {
      print('Error getting student data: $e');
      return null;
    }
  }

  void handleScannedCode(String? rawValue) async {
    if (rawValue == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final studentData = await getStudentDataFromQRCode(rawValue);

      if (studentData == null) {
        throw Exception('Invalid student QR code');
      }

      final attendanceCollection = _firestore.collection('attendance');
      final querySnapshot = await attendanceCollection
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No active attendance session found');
      }

      final currentAttendanceDoc = querySnapshot.docs.first;
      final attendanceData = currentAttendanceDoc.data();
      final studentList = List<Map<String, dynamic>>.from(attendanceData['studentList'] ?? []);

      bool isAlreadyPresent = studentList.any((student) =>
      student['id']?.toString() == studentData['id']?.toString());

      if (isAlreadyPresent) {
        throw Exception('Student is already in the attendance list');
      }

      Map<String, dynamic> newStudentData = {
        'name': studentData['name'],
        'id': studentData['id'],
        'academicYear': studentData['academicYear'],
        'email': studentData['email'],
        'timestamp': DateTime.now().toIso8601String(),
      };

      await currentAttendanceDoc.reference.update({
        'studentList': FieldValue.arrayUnion([newStudentData])
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student added successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        controller?.stop();
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
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
        title: 'Scan Student QR Code',
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