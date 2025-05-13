import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:graduation_project/screens/training/staff_training/filter_bottom_sheet.dart';
import 'package:graduation_project/screens/training/staff_training/validate_buttom_sheet.dart';

import '../../offline_feature/reusable_offline_bottom_sheet.dart';

class ValidateScreen extends StatefulWidget {
  const ValidateScreen({super.key});

  @override
  State<ValidateScreen> createState() => _ValidateScreenState();
}

class _ValidateScreenState extends State<ValidateScreen> {
  String? selectedYear;
  late Stream<QuerySnapshot> _requestsStream;

  @override
  void initState() {
    super.initState();
    _updateRequestsStream();
  }

  void _updateRequestsStream() {
    Query query = FirebaseFirestore.instance
        .collection('requests')
        .where('type', isEqualTo: 'Training')
        .where('status', whereIn: ['No status', 'Pending']);

    if (selectedYear != null) {
      query = query.where('year', isEqualTo: selectedYear);
    }

    _requestsStream = query.orderBy('created_at', descending: true).snapshots();
  }

  List<Request> requestsList = [];

  List<Widget> get studentreques {
    return requestsList.map((request) {
      return StudentContainer(
        onTap: (BuildContext context) {
          OfflineAwareBottomSheet.show(
            context: context,
            onlineContent: ValidateButtomSheet(request: request),
            backgroundColor: const Color.fromRGBO(250, 250, 250, 0.93),
          );
        },
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
        pdfBase64: request.pdfBase64,
        trainingScore: request.trainingScore,
        comment: request.comment,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Validate',
        onpressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              OfflineAwareBottomSheet.show(
                context: context,
                onlineContent: FilterBottomSheet(
                  onYearSelected: (year) {
                    setState(() {
                      selectedYear = year;
                      _updateRequestsStream();
                    });
                  },
                  currentYear: selectedYear,
                ),
                backgroundColor: const Color.fromRGBO(250, 250, 250, 0.93),
              );
            },
          ),
        ],
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
                  listOfWidgets: studentreques,
                  emptyMessage: 'No Requests',
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 8, right: 8),
            child: KButton(
              backgroundColor: Colors.black26,
              text: 'Archive',
              height: 62,
              svgPath: 'assets/project_image/Pin.svg',
              onPressed: () {
                Navigator.pushNamed(
                    context, '/staffStudentTraining/validate/archive');
              },
            ),
          ),
        ],
      ),
    );
  }
}
