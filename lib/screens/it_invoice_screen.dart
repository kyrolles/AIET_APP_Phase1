import 'package:flutter/material.dart';
import 'package:graduation_project/components/it_invoice_request_contanier.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/it_archive.dart';

class ItInvoiceScreen extends StatefulWidget {
  const ItInvoiceScreen({super.key});

  @override
  State<ItInvoiceScreen> createState() => _ItInvoiceScreenState();
}

enum Status { pending, rejected, done }

class _ItInvoiceScreenState extends State<ItInvoiceScreen> {
  // Color? statusColor;
  // String status = "No Status";
  // Color circleColor = const Color(0XFFE5E5E5);

  // void updateContainer(Color newColor) {
  //   setState(() {
  //     circleColor = newColor;
  //   });
  // }

  List<RequestContainer> requests = [
    RequestContainer(),
    RequestContainer(),
    RequestContainer(),
    RequestContainer(),
  ];
  List<RequestContainer> itArchive = [];
  void transferRequest(int index) {
    setState(() {
      itArchive.add(requests[index]);
      requests.remove(requests[index]);
    });
  }

  void updatePending(int index) {
    return setState(() {
      requests[index].status = "Pending";
      requests[index].statusColor = const Color(0XFFFFDD29);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(kToolbarHeight), // Standard AppBar height
        child: DecoratedBox(
          decoration: const BoxDecoration(boxShadow: kShadow),
          child: MyAppBar(
            title: 'It-Invoice',
            onpressed: () => Navigator.pop(context),
          ),
        ),
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
                  return InkWell(
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Text('Modal BottomSheet'),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          requests[index].status = "Done";
                                          requests[index].statusColor =
                                              const Color(0XFF34C759);
                                          // Remove the item from the source list and add it to the destination list
                                          transferRequest(index);
                                          // transferRequest();
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Done'),
                                      ),
                                      const SizedBox(width: 3),
                                      ElevatedButton(
                                        onPressed: () {
                                          requests[index].status = "Rejected";
                                          requests[index].statusColor =
                                              const Color(0XFFFF7648);
                                          transferRequest(index);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Rejected'),
                                      ),
                                      const SizedBox(width: 3),
                                      ElevatedButton(
                                        child: const Text('Pending'),
                                        onPressed: () {
                                          updatePending(index);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: requests[index],
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ItArchiveScreen(itArchive: itArchive);
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
