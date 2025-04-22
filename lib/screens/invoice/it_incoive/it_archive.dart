import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/screens/invoice/it_incoive/it_invoice_request_contanier.dart';
import 'package:graduation_project/models/request_model.dart';
import 'package:graduation_project/utils/safe_json_extractor.dart';
import 'dart:developer';
import '../../../components/my_app_bar.dart';

class ItArchiveScreen extends StatefulWidget {
  const ItArchiveScreen({super.key});

  @override
  State<ItArchiveScreen> createState() => _ItArchiveScreenState();
}

class _ItArchiveScreenState extends State<ItArchiveScreen> {
  final Stream<QuerySnapshot> _requestsStream = FirebaseFirestore.instance
      .collection('requests')
      .orderBy('created_at', descending: true)
      .snapshots();

  List<Request> requestsList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Invoice Archive',
        onpressed: () {
          Navigator.pop(context);
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _requestsStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              requestsList = [];
              for (var i = 0; i < snapshot.data!.docs.length; i++) {
                DocumentSnapshot doc = snapshot.data!.docs[i];

                // Safely get fields using utility
                String docType = SafeDocumentSnapshot.getField(doc, 'type', '');
                String docStatus =
                    SafeDocumentSnapshot.getField(doc, 'status', '');

                if ((docType == 'Proof of enrollment' ||
                        docType == 'Tuition Fees') &&
                    (docStatus == 'Done' || docStatus == 'Rejected')) {
                  try {
                    requestsList.add(Request.fromJson(doc));
                  } catch (e) {
                    log('Error parsing request: $e');
                  }
                }
              }
            }
            return ListContainer(
              title: 'Requests',
              listOfWidgets: archiveRequestsList(),
            );
          }),
    );
  }

  List<RequestContainer> archiveRequestsList() {
    List<RequestContainer> archiveRequests = [];
    for (var i = 0; i < requestsList.length; i++) {
      archiveRequests.add(RequestContainer(request: requestsList[i]));
    }
    return archiveRequests;
  }
}
