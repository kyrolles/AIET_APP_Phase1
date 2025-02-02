import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/training/student_training/upload_buttom_sheet.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:graduation_project/screens/invoice/it_incoive/request_model.dart';

class StudentTrainingScreen extends StatefulWidget {
  StudentTrainingScreen({super.key});

  @override
  State<StudentTrainingScreen> createState() => _StudentTrainingScreenState();
}

class _StudentTrainingScreenState extends State<StudentTrainingScreen> {
  Stream<QuerySnapshot>? _requestsStream;
  List<Request> requestsList = [];
  final int precent = 15;

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

        if (studentId != null) {
          // Initialize the stream with the student_id
          setState(() {
            _requestsStream = FirebaseFirestore.instance
                .collection('requests')
                .where('type', isEqualTo: 'Training')
                .where('student_id', isEqualTo: studentId)
                .snapshots();
          });
        }
      }
    }
  }

  List<Widget> get uplodedfiles {
    return requestsList.map((request) {
      return StudentContainer(
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
                percent: (precent / 60),
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
                    Text('$precent of 60',
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
                      for (var i = 0; i < snapshot.data!.docs.length; i++) {
                        requestsList
                            .add(Request.fromJson(snapshot.data!.docs[i]));
                      }
                      return ListContainer(
                        title: 'Requests',
                        listOfWidgets: uplodedfiles,
                        emptyMessage: 'No Requests',
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
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
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Department',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0XFF6C7072)),
                                  ),
                                ]),
                            KButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/departmentTraining',
                                    arguments:
                                        'Computer' // Make sure this matches the department name in create_announcement.dart
                                    );
                              },
                              text: 'CE',
                              fontSize: 34,
                              textColor: Colors.black,
                              borderWidth: 1,
                              borderColor: Colors.black,
                              backgroundImage: const DecorationImage(
                                  image: AssetImage(
                                      'assets/project_image/CE.jpeg'),
                                  fit: BoxFit.cover),
                            ),
                            KButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/departmentTraining',
                                    arguments: 'Mechatronics');
                              },
                              text: 'EME',
                              fontSize: 34,
                              textColor: Colors.white,
                              borderWidth: 1,
                              borderColor: Colors.black,
                              backgroundImage: const DecorationImage(
                                  image: AssetImage(
                                      'assets/project_image/EME.png'),
                                  fit: BoxFit.cover),
                            ),
                            KButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/departmentTraining',
                                    arguments: 'Communication & Electronics');
                              },
                              text: 'ECE',
                              fontSize: 34,
                              textColor: Colors.black,
                              borderWidth: 1,
                              borderColor: Colors.black,
                              backgroundImage: const DecorationImage(
                                  image: AssetImage(
                                      'assets/project_image/ECE.jpeg'),
                                  fit: BoxFit.cover,
                                  opacity: 0.5),
                            ),
                            KButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/departmentTraining',
                                    arguments: 'Industrial');
                              },
                              text: 'IE',
                              fontSize: 34,
                              textColor: Colors.white,
                              borderWidth: 1,
                              borderColor: Colors.black,
                              backgroundImage: const DecorationImage(
                                  image: AssetImage(
                                      'assets/project_image/IE.jpeg'),
                                  fit: BoxFit.cover,
                                  opacity: 0.8),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              ServiceItem(
                title: 'Submit Training',
                imageUrl: 'assets/project_image/submit-training.png',
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
                      return UploadButtomSheet();
                    },
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
