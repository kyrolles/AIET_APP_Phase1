import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/training/student_training/announcement_buttom_sheet.dart';
import 'package:graduation_project/screens/training/student_training/requests_buttom_sheet.dart';
import 'package:graduation_project/screens/training/student_training/upload_buttom_sheet.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:graduation_project/models/request_model.dart';

import '../../offline_feature/reusable_offline_bottom_sheet.dart';

class StudentTrainingScreen extends StatefulWidget {
  const StudentTrainingScreen({super.key});

  @override
  State<StudentTrainingScreen> createState() => _StudentTrainingScreenState();
}

class _StudentTrainingScreenState extends State<StudentTrainingScreen> {
  Stream<QuerySnapshot>? _requestsStream;
  List<Request> requestsList = [];
  int totalTrainingScore = 0; // Add this variable to store the score

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  Future<void> _initializeStream() async {
    // Get current user
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get user document from users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Get student_id from user document
        final studentId = userDoc.data()?['id'];
        final trainingScore = userDoc.data()?['totalTrainingScore'] ?? 0;

        if (studentId != null) {
          // Initialize the stream with the student_id
          setState(() {
            _requestsStream = FirebaseFirestore.instance
                .collection('requests')
                .where('type', isEqualTo: 'Training')
                .where('student_id', isEqualTo: studentId)
                .orderBy('created_at', descending: true)
                .snapshots();
            totalTrainingScore =
                trainingScore; // Store the score in the state variable
          });
        }
      }
    }
  }

  List<Widget> get uplodedfiles {
    return requestsList.map((request) {
      return StudentContainer(
        onTap: (BuildContext context) {
          showModalBottomSheet(
            backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (BuildContext context) {
              return RequestsButtomSheet(request: request);
            },
          );
        },
        status: request.status,
        statusColor: request.status == 'Pending'
            ? Colors.yellow
            : request.status == 'Rejected'
                ? Colors.red
                : request.status == 'Done'
                    ? const Color(0xFF34C759)
                    : kGreyLight,
        title: request.fileName,
        image: 'assets/project_image/pdf.png',
        trainingScore: request.trainingScore,
        comment: request.comment,
      );
    }).toList();
  }

  // the value of the progressbar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Student Training',
        onpressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height, // Prevents shrinking
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              CircularPercentIndicator(
                animation: true,
                animationDuration: 1000,
                radius: 100,
                lineWidth: 20,
                percent:
                    (totalTrainingScore / 60), // Use the state variable here
                progressColor: kPrimaryColor,
                backgroundColor: Colors.blue.shade50,
                circularStrokeCap: CircularStrokeCap.round,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(fontSize: 33, color: Colors.blueGrey),
                    ),
                    Text('$totalTrainingScore of 60',
                        style: const TextStyle(fontSize: 32)),
                  ],
                ),
              ),
              SizedBox(
                  height: 350,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _requestsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        requestsList = [];
                        int currentTotal = 0; // Initialize a local sum variable

                        for (var i = 0; i < snapshot.data!.docs.length; i++) {
                          var request =
                              Request.fromJson(snapshot.data!.docs[i]);
                          requestsList.add(request);

                          // Only add to total if status is "Done"
                          if (request.status == "Done") {
                            currentTotal += request.trainingScore;
                          }
                        }

                        // Update the state if the total has changed
                        if (currentTotal != totalTrainingScore) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) {
                              setState(() {
                                totalTrainingScore = currentTotal;
                              });
                            },
                          );
                        }

                        return ListContainer(
                          title: 'Requests',
                          listOfWidgets: uplodedfiles,
                          emptyMessage: 'No Requests',
                        );
                      } else {
                        return ListContainer(
                          title: 'Requests',
                          emptyMessage: 'No Requests',
                          listOfWidgets: uplodedfiles,
                        );
                      }
                      // else if (snapshot.hasError) {
                      //   return Center(child: Text('Error: ${snapshot.error}'));
                      // }
                      // else {
                      //   return const Center(child: CircularProgressIndicator());
                      // }
                    },
                  )),
              const Divider(
                  color: kLightGrey, indent: 10, endIndent: 10, height: 10),
              ServiceItem(
                title: 'Announcement',
                imageUrl: 'assets/project_image/loudspeaker.png',
                backgroundColor: const Color.fromRGBO(41, 128, 185, 1),
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (BuildContext context) {
                      return const AnnouncementButtomSheet();
                    },
                  );
                },
              ),
              ServiceItem(
                title: 'Submit Training',
                imageUrl: 'assets/project_image/submit-training.png',
                backgroundColor: const Color.fromRGBO(41, 128, 185, 1),
                onPressed: () {
                  OfflineAwareBottomSheet.show(
                    backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    onlineContent: const UploadButtomSheet(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
