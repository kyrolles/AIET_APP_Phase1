import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/constants.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceArchive extends StatefulWidget {
  final String? subjectCode;
  final String? period;

  const AttendanceArchive({
    super.key,
    this.subjectCode,
    this.period,
  });

  @override
  State<AttendanceArchive> createState() => _AttendanceArchiveState();
}

class _AttendanceArchiveState extends State<AttendanceArchive> {
  String? qrData;
  // Hardcoded attendance list to match screenshot
  final List<Map<String, String>> attendanceList = [
    {'name': 'Youssef Abdelfatah'},
    {'name': 'Mahmoud Abdelnaser'},
    {'name': 'Sotiri Tamer'},
    {'name': 'Kyrolles Raafat'},
    {'name': 'Youssef saleh'},
    {'name': 'Mohamed Mardy'},
    {'name': 'Ahamed Tarek'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.subjectCode != null && widget.period != null) {
      generateQRCode();
    }
  }

  void generateQRCode() {
    qrData = '{"subjectCode":"${widget.subjectCode}","period":"${widget.period}","timestamp":"${DateTime.now().toIso8601String()}"}';
    setState(() {});
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
          // QR Code Container
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

          // Attendance List
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
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          attendanceList.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Stu +',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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