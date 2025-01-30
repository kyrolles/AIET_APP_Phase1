import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/screens/invoice/it_incoive/it_invoice_request_contanier.dart';
import 'package:graduation_project/screens/invoice/it_incoive/request_model.dart';
import '../../../components/my_app_bar.dart';
import '../student_invoice/tuition_container.dart';
import '../../../constants.dart';

class ItInvoiceScreen extends StatefulWidget {
  const ItInvoiceScreen({super.key});

  @override
  State<ItInvoiceScreen> createState() => _ItInvoiceScreenState();
}

class _ItInvoiceScreenState extends State<ItInvoiceScreen> {
  final Stream<QuerySnapshot> _requestsStream =
      FirebaseFirestore.instance.collection('requests').snapshots();

  List<Request> requestsList = [];

  @override
  Widget build(BuildContext context) {
    Widget showRequestsList(context) {
      return ListView.builder(
        itemCount: requestsList.length,
        itemBuilder: (context, index) {
          return RequestContainer(
            request: requestsList[index],
          );
        },
      );
    }

    return Scaffold(
      appBar: MyAppBar(
        title: 'It-Invoice',
        onpressed: () => Navigator.pop(context),
      ),
      body: Container(
        // height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: const Color(0XFFFAFAFA),
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(15.0),
              child: const Text(
                'Requests',
                style: kTextStyleBold,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: _requestsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      requestsList = [];
                      for (var i = 0; i < snapshot.data!.docs.length; i++) {
                        requestsList
                            .add(Request.fromJson(snapshot.data!.docs[i]));
                      }
                      // print(snapchot.data!.docs[0]['name']);
                      // print(patientsList[0].name);
                    }
                    return showRequestsList(context);
                  }),
            ),
            TuitionContainer(),
            TextButton(
              onPressed: () {},
              child: Container(
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
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
