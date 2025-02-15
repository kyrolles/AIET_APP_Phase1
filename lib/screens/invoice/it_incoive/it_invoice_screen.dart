import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/screens/invoice/it_incoive/it_invoice_request_contanier.dart';
import 'package:graduation_project/models/request_model.dart';
import '../../../components/my_app_bar.dart';

class ItInvoiceScreen extends StatefulWidget {
  const ItInvoiceScreen({super.key});

  @override
  State<ItInvoiceScreen> createState() => _ItInvoiceScreenState();
}

class _ItInvoiceScreenState extends State<ItInvoiceScreen> {
  final Stream<QuerySnapshot> _requestsStream = FirebaseFirestore.instance
      .collection('requests')
      .orderBy('created_at', descending: true)
      .snapshots();

  List<Request> requestsList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Invoice',
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
              if ((snapshot.data!.docs[i]['type'] == 'Proof of enrollment' ||
                      snapshot.data!.docs[i]['type'] == 'Tuition Fees') &&
                  (snapshot.data!.docs[i]['status'] == 'Pending' ||
                      snapshot.data!.docs[i]['status'] == 'No Status')) {
                requestsList.add(Request.fromJson(snapshot.data!.docs[i]));
              }
            }
          }
          return Column(
            children: [
              ListContainer(
                title: 'Requests',
                listOfWidgets: showRequestsList(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: KButton(
                  backgroundColor: Colors.black38,
                  text: 'Archive',
                  height: 62,
                  svgPath: 'assets/project_image/Pin.svg',
                  onPressed: () {
                    Navigator.pushNamed(context, '/it_invoice/archive');
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<RequestContainer> showRequestsList() {
    List<RequestContainer> requests = [];
    for (var i = 0; i < requestsList.length; i++) {
      requests.add(RequestContainer(request: requestsList[i]));
    }
    return requests;
  }

//   TextButton archiveButton(BuildContext context) {
//     return TextButton(
//       onPressed: () {
//         Navigator.pushNamed(context, '/it_invoice/archive');
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0XFF888C94),
//           borderRadius: BorderRadius.circular(15.0),
//         ),
//         child: const Row(
//           children: [
//             Icon(
//               Icons.archive,
//               color: Colors.white,
//             ),
//             Expanded(
//               child: Center(
//                 child: Text(
//                   'Archive',
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
}
