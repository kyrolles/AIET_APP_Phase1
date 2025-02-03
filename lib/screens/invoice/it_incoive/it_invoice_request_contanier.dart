import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/screens/invoice/it_incoive/request_model.dart';
import 'package:graduation_project/screens/invoice/it_incoive/tuition_fees_upload.dart';
import 'proof_sheet_screen.dart';
import '../../../constants.dart';

Future<void> updateDocument({
//* Update a document in Firestore
  required String collectionPath,
  required Map<String, dynamic> searchCriteria,
  required Map<String, dynamic> newData,
}) async {
  try {
    //* Start with the collection reference
    Query query = FirebaseFirestore.instance.collection(collectionPath);

    //* Add all search conditions
    searchCriteria.forEach((field, value) {
      query = query.where(field, isEqualTo: value);
    });

    //* Get the documents that match your criteria
    QuerySnapshot querySnapshot = await query.get();

    //* Update the first matching document
    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.update(newData);
    }
    log('Document updated successfully');
  } catch (e) {
    log('Error updating document: $e');
  }
}

class RequestContainer extends StatelessWidget {
  const RequestContainer({super.key, required this.request});
  final Request request;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        request.type == 'Tuition Fees'
            ? showModalBottomSheetForTuitionFees(context)
            : showModalBottomSheetForProofOfEnrollment(context);
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
                Text(
                  request.studentName,
                  style: kTextStyleNormal,
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
    return showModalBottomSheet<void>(
      backgroundColor: const Color(0XFFF1F1F2),
      context: context,
      builder: (BuildContext context) {
        return ProofOfEnrollmentSheetScreen(
          request: request,
          doneFunctionality: () {
            updateDocument(
              collectionPath: 'requests',
              searchCriteria: {
                'student_id': request.studentId,
                'addressed_to': request.addressedTo,
              },
              newData: {
                'status': 'Done',
              },
            );
            Navigator.pop(context);
          },
          rejectedFunctionality: () {
            updateDocument(
              collectionPath: 'requests',
              searchCriteria: {
                'student_id': request.studentId,
                'addressed_to': request.addressedTo,
              },
              newData: {
                'status': 'Rejected',
              },
            );
            Navigator.pop(context);
          },
          pendingFunctionality: () {
            updateDocument(
              collectionPath: 'requests',
              searchCriteria: {
                'student_id': request.studentId,
                'addressed_to': request.addressedTo,
              },
              newData: {
                'status': 'Pending',
              },
            );
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<dynamic> showModalBottomSheetForTuitionFees(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return TuitionFeesSheet(
          doneFunctionality: () {},
        );
      },
    );
  }
}
