import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:graduation_project/screens/invoice/student_invoice/tuition_fees_download.dart';
import 'package:graduation_project/screens/offline_feature/reusable_offline.dart';
import 'package:graduation_project/utils/safe_json_extractor.dart';
import '../../../components/my_app_bar.dart';
import '../../offline_feature/reusable_offline_bottom_sheet.dart';
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
            studentId = SafeDocumentSnapshot.getField(userDoc, 'id', '');
          });
        }
      }
    } catch (e) {
      log('Error fetching id: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Invoice',
        onpressed: () => Navigator.pop(context),
      ),
      body: ReusableOffline(
        child: StreamBuilder<QuerySnapshot>(
            stream: _requestsStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                requestsList = [];
                for (var i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot doc = snapshot.data!.docs[i];

                  // Safely get fields using utility
                  String docStudentId =
                      SafeDocumentSnapshot.getField(doc, 'student_id', '');
                  String docType =
                      SafeDocumentSnapshot.getField(doc, 'type', '');

                  if (docStudentId == studentId &&
                      (docType == 'Proof of enrollment' ||
                          docType == 'Tuition Fees')) {
                    try {
                      requestsList.add(Request.fromJson(doc));
                    } catch (e) {
                      log('Error parsing request: $e');
                    }
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
      ),
    );
  }

  List<Widget> showRequestsList() {
    if (requestsList.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No requests found'),
          ),
        )
      ];
    }

    List<Widget> requestsWidgets = [];
    for (Request request in requestsList) {
      if (request.type == 'Tuition Fees') {
        requestsWidgets.add(
          StudentContainer(
            onTap: (BuildContext context) {
              OfflineAwareBottomSheet.show(
                context: context,
                onlineContent: TuitionFeesDownload(request: request),
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
            title: request.fileName.isEmpty
                ? 'Tuition Fees Request'
                : request.fileName,
            image: 'assets/project_image/pdf.png',
            pdfBase64: request.pdfBase64,
          ),
        );
      } else if (request.type == 'Proof of enrollment') {
        requestsWidgets.add(StudentContainer(
          onTap: (BuildContext context) {},
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
          title: "Proof of enrollment, To: ${request.addressedTo}",
          image: 'assets/project_image/pdf.png',
          pdfBase64: request.pdfBase64,
        ));
      }
    }
    return requestsWidgets;
  }

  ServiceItem proofOfEnrollmentButton(BuildContext context) {
    return ServiceItem(
      title: 'Proof of enrollment',
      imageUrl: 'assets/images/paragraph.png',
      backgroundColor: const Color.fromRGBO(241, 196, 15, 1),
      onPressed: () {
        OfflineAwareBottomSheet.show(
          context: context,
          onlineContent: const ProofOfEnrollment(),
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
        //? offline aware bottom sheet
        OfflineAwareBottomSheet.show(
          context: context,
          onlineContent: TuitionFeesPreview(requestsList: requestsList),
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
