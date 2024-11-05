import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/it_archive.dart';

class ItInvoiceScreen extends StatefulWidget {
  const ItInvoiceScreen({super.key});

  @override
  State<ItInvoiceScreen> createState() => _ItInvoiceScreenState();
}

enum Status { pending, rejected, done }

Color statusColor = const Color(0XFFE5E5E5);
String status = "No Status";

List<RequestContainer> requests = [
  RequestContainer(),
  RequestContainer(),
  RequestContainer(),
];
List<RequestContainer> itArchive = [RequestContainer()];
void transferRequest(RequestContainer request) {
  // Remove the item from the source list and add it to the destination list
  requests.remove(request);
  itArchive.add(request);
}

class _ItInvoiceScreenState extends State<ItInvoiceScreen> {
  // List<RequestContainer> requests = const [
  //   RequestContainer(),
  //   RequestContainer(),
  //   RequestContainer(),
  // ];
  // List<RequestContainer> itArchive = const [RequestContainer()];

  // void transferRequest(RequestContainer request) {
  //   setState(() {
  //     // Remove the item from the source list and add it to the destination list
  //     requests.remove(request);
  //     itArchive.add(request);
  //   });
  // }

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
          color: const Color(0XFFE5E5E5),
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

class RequestContainer extends StatefulWidget {
  const RequestContainer({super.key});

  @override
  State<RequestContainer> createState() => _RequestContainerState();
}

class _RequestContainerState extends State<RequestContainer> {
  // void transferRequest(RequestContainer request) {
  //   // Remove the item from the source list and add it to the destination list
  //   setState(() {
  //     requests.remove(request);
  //     itArchive.add(request);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // print('Pressed');
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
                          child: const Text('Done'),
                          onPressed: () {
                            setState(() {});
                            status = "Done";
                            statusColor = const Color(0XFF34C759);
                            transferRequest(requests[requests.length - 1]);
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 3),
                        ElevatedButton(
                          child: const Text('Rejected'),
                          onPressed: () {
                            setState(() {});
                            status = "Rejected";
                            statusColor = const Color(0XFFFF7648);
                            transferRequest(requests[requests.length - 1]);
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 3),
                        ElevatedButton(
                          child: const Text('Pending'),
                          onPressed: () {
                            setState(() {});
                            status = "Pending";
                            statusColor = const Color(0XFFFFDD29);
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
                const Text(
                  'Kyrolles Raafat',
                  style: kTextStyleNormal,
                ),
                const SizedBox(width: 5),
                Container(
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: const Text(
                    '20-0-60785',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0XFFFF8504),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: const Text(
                    '4th',
                    style: TextStyle(color: Colors.white, fontSize: 12),
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
                    child: Image.asset('assets/images/image 29 (2).png'),
                  ),
                ),
                const Text(
                  'Proof of enrollment',
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    Text(
                      status,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0XFF6C7072)),
                    ),
                    const SizedBox(width: 3),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
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
}
