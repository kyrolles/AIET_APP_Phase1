import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:graduation_project/screens/invoice/it_incoive/tuition_fees_upload.dart';
import 'package:graduation_project/screens/offline_feature/reusable_offline_bottom_sheet.dart';
import 'curriculum_content_sheet_screen.dart';
import 'grades_report_sheet_screen.dart';
import 'proof_sheet_screen.dart';
import '../../../constants.dart';

Future<void> updateDocument({
//* Update a document in Firestore
  required String collectionPath,
  required Map<String, dynamic> searchCriteria,
  required Map<String, dynamic> newData,
  bool isApproved = false,
}) async {
  try {
    log('Updating document: collectionPath=$collectionPath, criteria=$searchCriteria, newData=$newData');

    //* Start with the collection reference
    Query query = FirebaseFirestore.instance.collection(collectionPath);

    //* Add all search conditions
    searchCriteria.forEach((field, value) {
      query = query.where(field, isEqualTo: value);
    });

    //* Get the documents that match your criteria
    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isEmpty) {
      log('No documents found matching criteria');
      return;
    }

    log('Found ${querySnapshot.docs.length} documents to update');

    // Get the document to update
    final docRef = querySnapshot.docs.first.reference;
    final docData = querySnapshot.docs.first.data() as Map<String, dynamic>?;

    if (docData == null) {
      log('Document data is null');
      return;
    }

    // For status changes from non-Done to Done, do a separate update
    // to ensure the cloud function triggers properly
    if (newData.containsKey('status') &&
        newData['status'] == 'Done' &&
        docData['status'] != 'Done') {
      log('Updating status to Done - this should trigger notification');

      // First update everything except status
      Map<String, dynamic> nonStatusUpdates = Map.from(newData);
      nonStatusUpdates.remove('status');

      if (nonStatusUpdates.isNotEmpty) {
        await docRef.update(nonStatusUpdates);
        log('Updated non-status fields');
      }

      // Ensure the document contains the type field for the cloud function
      if (!docData.containsKey('type')) {
        await docRef.update({'type': 'Tuition Fees'});
        log('Added missing type field');
      }

      // Then update status separately to ensure it triggers properly
      await docRef.update({'status': 'Done'});
      log('Updated status to Done');
    } else {
      // For other updates, just do them all at once
      await docRef.update(newData);
      log('Updated document with new data');
    }
  } catch (e) {
    log('Error updating document: $e');
  }
}

class RequestContainer extends StatelessWidget {
  const RequestContainer({
    super.key,
    required this.request,
    required this.onStatusChanged, // Add this line
  });

  final Request request;
  final VoidCallback onStatusChanged; // Add this line

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        switch (request.type) {
          case 'Tuition Fees':
            showModalBottomSheetForTuitionFees(context);
            break;
          case 'Proof of enrollment':
            showModalBottomSheetForProofOfEnrollment(context);
            break;
          case 'Grades Report':
            showModalBottomSheetForGradesReport(context);
            break;
          case 'Academic Content':
            showModalBottomSheetForCurriculumContent(context);
            break;
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
        ),
        // height: 100,
        child: Column(
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    request.studentName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: kTextStyleNormal,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Text(
                    request.studentId,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0XFFFF8504),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Text(
                    request.year,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: Colors.black,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      request.type == 'Tuition Fees'
                          ? 'assets/images/9e1e8dc1064bb7ac5550ad684703fb30.png'
                          : 'assets/images/image 29 (2).png',
                    ),
                  ),
                ),
                Text(
                  request.type,
                  style: const TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    Text(
                      request.status,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0XFF6C7072)),
                    ),
                    const SizedBox(width: 3),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: request.status == 'Pending'
                            ? const Color(0XFFFFDD29)
                            : request.status == 'Rejected'
                                ? const Color(0XFFFF7648)
                                : request.status == 'Done'
                                    ? const Color(0xFF34C759)
                                    : kGreyLight,
                      ),
                      height: 22,
                      width: 22,
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> showModalBottomSheetForProofOfEnrollment(BuildContext context) {
    // Get navigator reference while the widget is still active
    final NavigatorState navigator =
        Navigator.of(context, rootNavigator: false);

    return OfflineAwareBottomSheet.show(
      isScrollControlled: true,
      backgroundColor: const Color(0XFFF1F1F2),
      context: context,
      onlineContent: ProofOfEnrollmentSheetScreen(
        request: request,
        doneFunctionality: () async {
          try {
            log('Setting proof of enrollment request status to Done');
            // Use the updateDocument function for consistency
            await updateDocument(
              collectionPath: 'student_affairs_requests',
              searchCriteria: {
                'student_id': request.studentId,
                'addressed_to': request.addressedTo,
                'type': 'Proof of enrollment',
              },
              newData: {
                'status': 'Done',
              },
            );
            onStatusChanged(); // Add this line
            log('Successfully updated proof of enrollment status to Done');
            // BlocProvider.of<GetRequestsCubit>(context).getRequests();
          } catch (e) {
            log('Error updating status: $e');
          }
          if (navigator.mounted) {
            navigator.pop();
          }
        },
        rejectedFunctionality: () async {
          await updateDocument(
            collectionPath: 'student_affairs_requests',
            searchCriteria: {
              'student_id': request.studentId,
              'addressed_to': request.addressedTo,
            },
            newData: {
              'status': 'Rejected',
            },
          );
          onStatusChanged(); // Add this line
          // BlocProvider.of<GetRequestsCubit>(context).getRequests();
          if (navigator.mounted) {
            navigator.pop();
          }
        },
        pendingFunctionality: () async {
          await updateDocument(
            collectionPath: 'student_affairs_requests',
            searchCriteria: {
              'student_id': request.studentId,
              'addressed_to': request.addressedTo,
            },
            newData: {
              'status': 'Pending',
            },
          );
          onStatusChanged(); // Add this line
          // BlocProvider.of<GetRequestsCubit>(context).getRequests();
          if (navigator.mounted) {
            navigator.pop();
          }
        },
      ),
    );
  }

  Future<dynamic> showModalBottomSheetForTuitionFees(BuildContext context) {
    Navigator.of(context, rootNavigator: false);

    return OfflineAwareBottomSheet.show(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      onlineContent: TuitionFeesSheet(
        request: request,
        doneFunctionality: () {
          onStatusChanged(); // This will trigger the UI refresh
        },
      ),
    );
  }

  Future<void> showModalBottomSheetForGradesReport(BuildContext context) {
    final NavigatorState navigator =
        Navigator.of(context, rootNavigator: false);

    return OfflineAwareBottomSheet.show(
      isScrollControlled: true,
      backgroundColor: const Color(0XFFF1F1F2),
      context: context,
      onlineContent: GradesReportSheetScreen(
        request: request,
        doneFunctionality: () async {
          try {
            await updateDocument(
              collectionPath: 'student_affairs_requests',
              searchCriteria: {
                'student_id': request.studentId,
                'addressed_to': request.addressedTo,
                'type': 'Grades Report',
              },
              newData: {
                'status': 'Done',
              },
            );
            onStatusChanged();
          } catch (e) {
            log('Error updating status: $e');
          }
          if (navigator.mounted) {
            navigator.pop();
          }
        },
        rejectedFunctionality: () async {
          await updateDocument(
            collectionPath: 'student_affairs_requests',
            searchCriteria: {
              'student_id': request.studentId,
              'addressed_to': request.addressedTo,
              'type': 'Grades Report',
            },
            newData: {
              'status': 'Rejected',
            },
          );
          onStatusChanged();
          if (navigator.mounted) {
            navigator.pop();
          }
        },
        pendingFunctionality: () async {
          await updateDocument(
            collectionPath: 'student_affairs_requests',
            searchCriteria: {
              'student_id': request.studentId,
              'addressed_to': request.addressedTo,
              'type': 'Grades Report',
            },
            newData: {
              'status': 'Pending',
            },
          );
          onStatusChanged();
          if (navigator.mounted) {
            navigator.pop();
          }
        },
      ),
    );
  }

  Future<void> showModalBottomSheetForCurriculumContent(BuildContext context) {
    final NavigatorState navigator =
        Navigator.of(context, rootNavigator: false);

    return OfflineAwareBottomSheet.show(
      isScrollControlled: true,
      backgroundColor: const Color(0XFFF1F1F2),
      context: context,
      onlineContent: CurriculumContentSheetScreen(
        request: request,
        doneFunctionality: () async {
          try {
            await updateDocument(
              collectionPath: 'student_affairs_requests',
              searchCriteria: {
                'student_id': request.studentId,
                'addressed_to': request.addressedTo,
                'type': 'Academic Content',
              },
              newData: {
                'status': 'Done',
              },
            );
            onStatusChanged();
          } catch (e) {
            log('Error updating status: $e');
          }
          if (navigator.mounted) {
            navigator.pop();
          }
        },
        rejectedFunctionality: () async {
          await updateDocument(
            collectionPath: 'student_affairs_requests',
            searchCriteria: {
              'student_id': request.studentId,
              'addressed_to': request.addressedTo,
              'type': 'Academic Content',
            },
            newData: {
              'status': 'Rejected',
            },
          );
          onStatusChanged();
          if (navigator.mounted) {
            navigator.pop();
          }
        },
        pendingFunctionality: () async {
          await updateDocument(
            collectionPath: 'student_affairs_requests',
            searchCriteria: {
              'student_id': request.studentId,
              'addressed_to': request.addressedTo,
              'type': 'Academic Content',
            },
            newData: {
              'status': 'Pending',
            },
          );
          onStatusChanged();
          if (navigator.mounted) {
            navigator.pop();
          }
        },
      ),
    );
  }
}
