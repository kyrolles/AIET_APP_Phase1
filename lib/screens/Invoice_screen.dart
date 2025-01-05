import 'package:flutter/material.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:graduation_project/components/list_container.dart';
import '../components/my_app_bar.dart';
import '../components/proof_of_enrollment.dart';
import 'tuition_fees_download.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Invoice',
        onpressed: () => Navigator.pop(context),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListContainer(
            title: 'Status',
            listOfWidgets: [
              statusTile(
                imagePath: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
                label: 'Proof of enrollment',
                status: 'Done',
                statusColor: Colors.green,
              ),
              statusTile(
                imagePath: 'assets/images/9e1e8dc1064bb7ac5550ad684703fb30.png',
                label: 'Tuition fees',
                status: 'Done',
                statusColor: Colors.green,
              ),
              statusTile(
                imagePath: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
                label: 'Proof of enrollment',
                status: 'Rejected',
                statusColor: Colors.orange,
              ),
              statusTile(
                imagePath: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
                label: 'Proof of enrollment',
                status: 'Pending',
                statusColor: Colors.yellow,
              ),
              statusTile(
                imagePath: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
                label: 'Proof of enrollment',
                status: 'No Status',
                statusColor: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              'Ask for',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ServiceItem(
              title: 'Tuition fees',
              imageUrl: 'assets/images/9e1e8dc1064bb7ac5550ad684703fb30.png',
              backgroundColor: Colors.blue,
              onPressed: () {
                showModalBottomSheet<void>(
                  backgroundColor: const Color(0XFFF1F1F2),
                  context: context,
                  builder: (BuildContext context) {
                    return const TuitionFeesDownload();
                  },
                );
              }),
          const SizedBox(height: 10),
          ServiceItem(
            title: 'Proof of enrollment',
            imageUrl: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
            backgroundColor: Colors.blue,
            onPressed: () {
              showModalBottomSheet<void>(
                backgroundColor: const Color(0XFFF1F1F2),
                context: context,
                builder: (BuildContext context) {
                  return const ProofOfEnrollment();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget statusTile({
  required String imagePath,
  required String label,
  required String status,
  required Color statusColor,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Image.asset(
            imagePath,
            width: 24,
            height: 24,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        CircleAvatar(
          radius: 8,
          backgroundColor: statusColor,
        ),
      ],
    ),
  );
}
