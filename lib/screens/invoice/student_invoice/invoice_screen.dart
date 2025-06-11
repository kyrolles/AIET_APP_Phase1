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
import 'package:graduation_project/utils/safe_json_extractor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../components/my_app_bar.dart';
import '../../offline_feature/reusable_offline_bottom_sheet.dart';
import 'proof_of_enrollment.dart';
import 'tuition_fees_request.dart';
import 'grades_report_request.dart';
import 'curriculum_content_request.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final Stream<QuerySnapshot> _requestsStream = FirebaseFirestore.instance
      .collection('student_affairs_requests')
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
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: MyAppBar(
        title: localizations?.studentAffairs ?? 'Student Affairs',
        onpressed: () => Navigator.pop(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _requestsStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              requestsList = [];
              for (var i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot doc = snapshot.data!.docs[i];

                // Safely get fields using utility
                String docStudentId =
                    SafeDocumentSnapshot.getField(doc, 'student_id', '');

                if (docStudentId == studentId) {
                  try {
                    requestsList.add(Request.fromJson(doc));
                  } catch (e) {
                    log('Error parsing request: $e');
                  }
                }
              }
            }
            final localizations = AppLocalizations.of(context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListContainer(
                  title: localizations?.status ?? 'Status',
                  listOfWidgets: showRequestsList(localizations),
                ),
                const Divider(
                    color: kLightGrey, indent: 10, endIndent: 10, height: 10),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    localizations?.askFor ?? 'Ask for',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                tuitionFeesButton(context, requestsList, localizations),
                proofOfEnrollmentButton(context, localizations),
                gradesReportButton(context, localizations),
                curriculumContentButton(context, localizations),
              ],
            );
          }),
    );
  }

  List<Widget> showRequestsList([AppLocalizations? localizations]) {
    if (requestsList.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(localizations?.noRequestsFound ?? 'No requests found'),
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
                ? localizations?.tuitionFeesRequest ?? 'Tuition Fees Request'
                : request.fileName,
            image: 'assets/project_image/pdf.png',
            pdfBase64: request.pdfBase64,
          ),
        );
      } else {
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
          title: "${request.type}, To: ${request.addressedTo}",
          image: 'assets/project_image/pdf.png',
          pdfBase64: request.pdfBase64,
        ));
      }
    }
    return requestsWidgets;
  }

  ServiceItem proofOfEnrollmentButton(BuildContext context,
      [AppLocalizations? localizations]) {
    return ServiceItem(
      title: localizations?.proofOfEnrollment ?? 'Proof of enrollment',
      imageUrl: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
      backgroundColor: const Color.fromRGBO(241, 196, 15, 1),
      onPressed: () {
        OfflineAwareBottomSheet.show(
          isScrollControlled: true,
          context: context,
          onlineContent: const ProofOfEnrollment(),
        );
      },
    );
  }

  ServiceItem tuitionFeesButton(
      BuildContext context, List<Request> requestsList,
      [AppLocalizations? localizations]) {
    return ServiceItem(
      title: localizations?.tuitionFees ?? 'Tuition fees',
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

  ServiceItem gradesReportButton(BuildContext context,
      [AppLocalizations? localizations]) {
    return ServiceItem(
      title: localizations?.gradesReport ?? 'Grades Report',
      imageUrl: 'assets/images/image 29 (2).png', // Update with correct image
      backgroundColor: const Color.fromRGBO(46, 204, 113, 1),
      onPressed: () {
        OfflineAwareBottomSheet.show(
          isScrollControlled: true,
          context: context,
          onlineContent: const GradesReportRequest(),
        );
      },
    );
  }

  ServiceItem curriculumContentButton(BuildContext context,
      [AppLocalizations? localizations]) {
    return ServiceItem(
      title: localizations?.academicContent ?? 'Academic Content',
      imageUrl: 'assets/images/image 29 (2).png', // Update with correct image
      backgroundColor: const Color.fromRGBO(155, 89, 182, 1),
      onPressed: () {
        OfflineAwareBottomSheet.show(
          isScrollControlled: true,
          context: context,
          onlineContent: const CurriculumContentRequest(),
        );
      },
    );
  }
}
