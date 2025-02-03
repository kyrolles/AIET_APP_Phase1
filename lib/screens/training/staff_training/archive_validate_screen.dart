import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/invoice/it_incoive/request_model.dart';

class ArchiveValidateScreen extends StatefulWidget {
  const ArchiveValidateScreen({super.key});

  @override
  State<ArchiveValidateScreen> createState() => _ArchiveValidateScreenState();
}

class _ArchiveValidateScreenState extends State<ArchiveValidateScreen> {
  final Stream<QuerySnapshot> _requestsStream = FirebaseFirestore.instance
      .collection('requests')
      .where('type', isEqualTo: 'Training')
      .where('status', whereIn: ['Done', 'Rejected']).snapshots();

  List<Request> requestsList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Archive',
        onpressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _requestsStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                requestsList = [];
                for (var i = 0; i < snapshot.data!.docs.length; i++) {
                  requestsList.add(Request.fromJson(snapshot.data!.docs[i]));
                }
                return ListContainer(
                  title: 'Requests',
                  listOfWidgets: archiveRequestsList(),
                  emptyMessage: 'No Requests',
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }

  List<Widget> archiveRequestsList() {
    return requestsList.map((request) {
      return StudentContainer(
        name: request.studentName,
        status: request.status,
        statusColor: request.status == 'Pending'
            ? Colors.yellow
            : request.status == 'Rejected'
                ? Colors.red
                : request.status == 'Done'
                    ? const Color(0xFF34C759)
                    : kGreyLight,
        id: request.studentId,
        year: request.year,
        title: request.fileName,
        image: 'assets/project_image/pdf.png',
      );
    }).toList();
  }
}
