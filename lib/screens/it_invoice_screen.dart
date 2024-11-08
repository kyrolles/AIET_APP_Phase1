import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool? isChecked = false;
  bool isStaff = false;

  @override
  void initState() {
    super.initState();
    checkIfStaff();
  }

  Future<void> checkIfStaff() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('staffs')
            .where('email', isEqualTo: email)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            isStaff = true;
          });
        } else {
          // Redirect to another screen or show a message
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => NotAuthorizedScreen()),
          );
        }
      }
    } catch (e) {
      print('Error checking staff status: $e');
    }
  }

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
    if (!isStaff) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                        backgroundColor: const Color(0XFFF1F1F2),
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          'اثبات القيد',
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0XFF6C7072)),
                                        ),
                                      ]),
                                  const SizedBox(height: 20),
                                  const SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'كيرلس رافت لمعي ابراهيم',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          '   : الاسم',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'مصلحة الضرائب',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          '   : الجهة الموجه إليها',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Checkbox(
                                          value: isChecked,
                                          activeColor: kPrimary,
                                          onChanged: (newBool) {
                                            setState(() {
                                              isChecked = newBool ?? false;
                                            });
                                          },
                                        ),
                                        const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'هل تريد ختم النسر ؟',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            Text(
                                              '(!ملحوظة: سيأخذ الكثير من الوقت)',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0XFFFF7648),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () {
                                            requests[index].status = "Rejected";
                                            requests[index].statusColor =
                                                const Color(0XFFFF7648);
                                            transferRequest(index);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Rejected',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0XFFFFDD29),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Pending',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          onPressed: () {
                                            updatePending(index);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF34C759),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () {
                                            requests[index].status = "Done";
                                            requests[index].statusColor =
                                                const Color(0XFF34C759);
                                            // Remove the item from the source list and add it to the destination list
                                            transferRequest(index);
                                            // transferRequest();
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Done',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
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

class NotAuthorizedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: MyAppBar(
          title: 'Not Authorized',
          onpressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text('You are not authorized to view this screen.'),
      ),
    );
  }
}
