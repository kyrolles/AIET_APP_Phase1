import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/proof_of_enrollment.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/tuition_fees_download.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight), 
        child: DecoratedBox(
          decoration: const BoxDecoration(boxShadow: kShadow),
          child: MyAppBar(
            title: 'Invoice',
            onpressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 350,
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: const Color(0XFFFAFAFA),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      ' Status',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    ListView(
                      shrinkWrap: true,  
                      children: [
                        statusTile(
                          imagePath:
                              'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
                          label: 'Proof of enrollment',
                          status: 'Done',
                          statusColor: Colors.green,
                        ),
                        statusTile(
                          imagePath:
                              'assets/images/9e1e8dc1064bb7ac5550ad684703fb30.png',
                          label: 'Tuition fees',
                          status: 'Done',
                          statusColor: Colors.green,
                        ),
                        statusTile(
                          imagePath:
                              'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
                          label: 'Proof of enrollment',
                          status: 'Rejected',
                          statusColor: Colors.orange,
                        ),
                        statusTile(
                          imagePath:
                              'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
                          label: 'Proof of enrollment',
                          status: 'Pending',
                          statusColor: Colors.yellow,
                        ),
                        statusTile(
                          imagePath:
                              'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
                          label: 'Proof of enrollment',
                          status: 'No Status',
                          statusColor: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                 Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ArchiveScreen()),
      );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.archive,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Archive',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Ask for',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet<void>(
                        backgroundColor: const Color(0XFFF1F1F2),
                        context: context,
                        builder: (BuildContext context) {
                          return const TuitionFeesDownload();
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/9e1e8dc1064bb7ac5550ad684703fb30.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Text(
                            'Tuition fees',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor: const Color(0XFFF1F1F2),
                        context: context,
                        builder: (BuildContext context) {
                          return const ProofOfEnrollment();
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Text(
                            'Proof of enrollment',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
    margin: const EdgeInsets.symmetric(vertical: 5),
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

class ArchiveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archive'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  
                  ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    title: Text('Proof of enrollment'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Done', style: TextStyle(color: Colors.green)),
                        SizedBox(width: 8),
                        Icon(Icons.circle, color: Colors.green, size: 16),
                      ],
                    ),
                  ),
                  Divider(),
                  
                  ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        'assets/images/9e1e8dc1064bb7ac5550ad684703fb30.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    title: Text('Tuition fees'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Done', style: TextStyle(color: Colors.green)),
                        SizedBox(width: 8),
                        Icon(Icons.circle, color: Colors.green, size: 16),
                      ],
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        'assets/images/daca1c3b78a2c352c89eabda54e640ce.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    title: Text('Proof of enrollment'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Rejected', style: TextStyle(color: Colors.orange)),
                        SizedBox(width: 8),
                        Icon(Icons.circle, color: Colors.orange, size: 16),
                      ],
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        'assets/images/9e1e8dc1064bb7ac5550ad684703fb30.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    title: Text('Tuition fees'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Rejected', style: TextStyle(color: Colors.orange)),
                        SizedBox(width: 8),
                        Icon(Icons.circle, color: Colors.orange, size: 16),
                      ],
                    ),
                  ),
                  Divider(),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
