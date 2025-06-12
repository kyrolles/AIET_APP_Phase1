import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/student_container.dart';
import '../../../components/list_container.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InvoiceArchiveScreen extends StatelessWidget {
  const InvoiceArchiveScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: MyAppBar(
        title: localizations?.archive ?? 'Archive',
        onpressed: () {
          Navigator.pop(context);
        },
      ),
      body: ListContainer(
        title: localizations?.status ?? 'Status',
        listOfWidgets: [
          StudentContainer(
            title: localizations?.proofOfEnrollment ?? 'Proof of enrollment',
            image: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
            status: localizations?.done ?? 'Done',
            statusColor: Colors.green,
          ),
          StudentContainer(
            title: localizations?.tuitionFees ?? 'Tuition fees',
            image: 'assets/images/9e1e8dc1064bb7ac5550ad684703fb30.png',
            status: localizations?.done ?? 'Done',
            statusColor: Colors.green,
          ),
          StudentContainer(
            title: localizations?.proofOfEnrollment ?? 'Proof of enrollment',
            image: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
            status: localizations?.rejected ?? 'Rejected',
            statusColor: Colors.red,
          ),
          StudentContainer(
            title: localizations?.proofOfEnrollment ?? 'Proof of enrollment',
            image: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
            status: localizations?.rejected ?? 'Rejected',
            statusColor: Colors.red,
          ),
          StudentContainer(
            title: localizations?.proofOfEnrollment ?? 'Proof of enrollment',
            image: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
            status: localizations?.done ?? 'Done',
            statusColor: Colors.green,
          ),
          // statusTile(
          //   imagePath: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
          //   label: 'Proof of enrollment',
          //   status: 'Done',
          //   statusColor: Colors.green,
          // ),
          // statusTile(
          //   imagePath: 'assets/images/9e1e8dc1064bb7ac5550ad684703fb30.png',
          //   label: 'Tuition fees',
          //   status: 'Done',
          //   statusColor: Colors.green,
          // ),
          // statusTile(
          //   imagePath: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
          //   label: 'Proof of enrollment',
          //   status: 'Rejected',
          //   statusColor: Colors.orange,
          // ),
          // statusTile(
          //   imagePath: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
          //   label: 'Proof of enrollment',
          //   status: 'Pending',
          //   statusColor: Colors.yellow,
          // ),
          // statusTile(
          //   imagePath: 'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
          //   label: 'Proof of enrollment',
          //   status: 'No Status',
          //   statusColor: Colors.grey,
          // ),
        ],
      ),
    );
  }
}
