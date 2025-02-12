import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:graduation_project/screens/invoice/student_invoice/tuition_fees_download.dart';
import '../../../components/my_app_bar.dart';
import 'proof_of_enrollment.dart';
import 'tuition_fees_request.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final Stream<QuerySnapshot> _requestsStream = FirebaseFirestore.instance
      .collection('requests')
      .orderBy('created_at', descending: true)
      .snapshots();

  List<Request> requestsList = [];
  String? email;
  String? studentId;

  @override
  void initState() {
    super.initState();
    fetchUserId();
    // email = FirebaseAuth.instance.currentUser?.email;
  }

  Future<void> fetchUserId() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;

        // Check in the users collection
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          setState(() {
            studentId = userDoc['id'];
          });
        }
      }
    } catch (e) {
      log('Error fetching id: $e');
    }
  }

  Future<String> getStuentId() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    Future<String> stuentid = snapshot.docs[0]['id'];
    return stuentid;
    // print(studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Invoice',
        onpressed: () => Navigator.pop(context),
        // actions: [
        //   IconButton(
        //     onPressed: () => Navigator.pushNamed(context, '/invoice/archive'),
        //     icon: const Icon(Icons.archive),
        //   ),
        // ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _requestsStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              requestsList = [];
              for (var i = 0; i < snapshot.data!.docs.length; i++) {
                if (snapshot.data!.docs[i]['student_id'] == studentId &&
                    (snapshot.data!.docs[i]['type'] == 'Proof of enrollment' ||
                        snapshot.data!.docs[i]['type'] == 'Tuition Fees')) {
                  requestsList.add(
                    Request.fromJson(snapshot.data!.docs[i]),
                  );
                }
              }
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListContainer(
                  title: 'Status',
                  listOfWidgets: showRequestsList(),
                ),
                const Divider(
                    color: kLightGrey, indent: 10, endIndent: 10, height: 10),
                const SizedBox(
                  height: 8,
                ),
                // archiveButton(context),
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Ask for',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                tuitionFeesButton(context, requestsList),
                proofOfEnrollmentButton(context),
              ],
            );
          }),
    );
  }

  List<StudentContainer> showRequestsList() {
    List<StudentContainer> requests = [];
    for (var i = 0; i < requestsList.length; i++) {
      requests.add(
        StudentContainer(
          onTap: (context) {
            if (requestsList[i].type == 'Proof of enrollment') {
              showModalSheetForRequestStatusOfProofOfEnrollment(
                  requestsList[i]);
            } else if (requestsList[i].type == 'Tuition Fees') {
              showModalSheetForRequestStatusOfTuitionFees(requestsList[i]);
            }
          },
          title: requestsList[i].type,
          image: requestsList[i].type == 'Tuition Fees'
              ? 'assets/images/9e1e8dc1064bb7ac5550ad684703fb30.png'
              : 'assets/images/image 29 (2).png',
          status: requestsList[i].status,
          statusColor: requestsList[i].status == 'Pending'
              ? const Color(0XFFFFDD29)
              : requestsList[i].status == 'Rejected'
                  ? const Color(0XFFFF7648)
                  : requestsList[i].status == 'Done'
                      ? const Color(0xFF34C759)
                      : kGreyLight,
        ),
      );
    }
    return requests;
  }

  Future<dynamic> showModalSheetForRequestStatusOfTuitionFees(Request request) {
    return showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (context) {
          return request.status == 'Done'
              ? TuitionFeesDownload(request: request)
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 32.0, horizontal: 12.0),
                  child: KButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('requests')
                          .where('student_id', isEqualTo: request.studentId)
                          .where('type', isEqualTo: request.type)
                          .where('created_at', isEqualTo: request.createdAt)
                          .get()
                          .then(
                        (value) {
                          value.docs.first.reference.delete();
                        },
                      );
                      Navigator.pop(context);
                    },
                    text: 'Delete',
                    fontSize: 21.7,
                    textColor: Colors.white,
                    backgroundColor: Colors.red,
                    borderColor: Colors.white,
                  ),
                );
        });
  }

  Future<dynamic> showModalSheetForRequestStatusOfProofOfEnrollment(
      Request request) {
    return showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 40,
              children: <Widget>[
                Text(
                  request.type,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF6C7072),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        request.status == 'Pending'
                            ? 'Your request is currently under review.'
                            : request.status == 'Rejected'
                                ? 'Your request has been rejected due to insufficient information.'
                                : request.status == 'Done'
                                    ? 'Go to Student Affairs to receive your application.'
                                    : 'Status not yet assigned.',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 0),
              ],
            ),
          ),
        );
      },
    );
  }

  GestureDetector archiveButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/invoice/archive');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0XFF888C94),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.archive,
              color: Colors.white,
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Archive',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ServiceItem proofOfEnrollmentButton(BuildContext context) {
    return ServiceItem(
      title: 'Proof of enrollment',
      imageUrl: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
      backgroundColor: const Color.fromRGBO(41, 128, 185, 1),
      onPressed: () {
        showModalBottomSheet<void>(
          backgroundColor: const Color(0XFFF1F1F2),
          context: context,
          builder: (BuildContext context) {
            return const ProofOfEnrollment();
          },
        );
      },
    );
  }

  ServiceItem tuitionFeesButton(
      BuildContext context, List<Request> requestsList) {
    return ServiceItem(
      title: 'Tuition fees',
      imageUrl: 'assets/images/9e1e8dc1064bb7ac5550ad684703fb30.png',
      backgroundColor: const Color.fromRGBO(41, 128, 185, 1),
      onPressed: () {
        showModalBottomSheet<void>(
          backgroundColor: const Color(0XFFF1F1F2),
          context: context,
          builder: (BuildContext context) {
            return TuitionFeesPreview(requestsList: requestsList);
          },
        );
      },
    );
  }
}

// Widget statusTile({
//   required String imagePath,
//   required String label,
//   required String status,
//   required Color statusColor,
// }) {
//   return Container(
//     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//     margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(10),
//     ),
//     child: Row(
//       children: [
//         CircleAvatar(
//           backgroundColor: Colors.grey[200],
//           child: Image.asset(
//             imagePath,
//             width: 24,
//             height: 24,
//           ),
//         ),
//         const SizedBox(width: 15),
//         Expanded(
//           child: Text(
//             label,
//             style: const TextStyle(fontSize: 16),
//           ),
//         ),
//         Text(
//           status,
//           style: TextStyle(
//             color: statusColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(width: 10),
//         CircleAvatar(
//           radius: 8,
//           backgroundColor: statusColor,
//         ),
//       ],
//     ),
//   );
// }
