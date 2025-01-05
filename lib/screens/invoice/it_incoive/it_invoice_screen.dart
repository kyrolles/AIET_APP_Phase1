import 'package:flutter/material.dart';
import 'it_invoice_request_contanier.dart';
import '../../../components/my_app_bar.dart';
import '../student_invoice/tuition_container.dart';
import '../../../constants.dart';
import 'it_archive.dart';

// Color? statusColor;
// String status = "No Status";
// Color circleColor = const Color(0XFFE5E5E5);

// void updateContainer(Color newColor) {
//   setState(() {
//     circleColor = newColor;
//   });
// }

class ItInvoiceScreen extends StatefulWidget {
  const ItInvoiceScreen({super.key});

  @override
  State<ItInvoiceScreen> createState() => _ItInvoiceScreenState();
}

class _ItInvoiceScreenState extends State<ItInvoiceScreen> {
  void updateRequestList() {
    //!requests list
    for (var i = 0; i < requests.length; i++) {
      if (requests[i].status == 'Done' || requests[i].status == 'Rejected') {
        setState(() {
          //! add it to the archive list
          itArchive.add(requests[i]);
        });
      }
    }
    setState(() {
      //!Remove the item from the requests list
      requests.removeWhere((request) =>
          request.status == 'Done' || request.status == 'Rejected');
    });

    // //!archive list
    // for (var i = 0; i < itArchive.length; i++) {
    //   if (itArchive[i].status == 'Pending') {
    //     setState(() {
    //       //* add it to the requests list
    //       requests.add(requests[i]);
    //     });
    //   }
    // }
    // setState(() {
    //   //*Remove the item from the archive list
    //   itArchive.removeWhere((archive) => archive.status == 'Pending');
    // });
  }

  final List<RequestContainer> requests = [
    RequestContainer(),
    RequestContainer(),
    RequestContainer(),
  ];

  final List<RequestContainer> itArchive = [];

  @override
  Widget build(BuildContext context) {
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
              child: ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  return requests[index];
                },
              ),
            ),
            TuitionContainer(),
            TextButton(
              onPressed: () {
                updateRequestList();
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ItArchiveScreen(
                      itArchive: itArchive, requests: requests);
                }));
              },
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
