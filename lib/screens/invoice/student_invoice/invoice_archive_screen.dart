import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import '../../../components/list_container.dart';
import 'invoice_screen.dart';

class InvoiceArchiveScreen extends StatelessWidget {
  const InvoiceArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Archive',
        onpressed: () {
          Navigator.pop(context);
        },
      ),
      body: ListContainer(
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
    );
  }
}
