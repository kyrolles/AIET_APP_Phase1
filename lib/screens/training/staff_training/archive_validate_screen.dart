import 'package:flutter/material.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/student_container.dart';

class ArchiveValidateScreen extends StatelessWidget {
  ArchiveValidateScreen({super.key});

  final List<Widget> periods = [
    const StudentContainer(
        onTap: null,
        name: 'Kyrolles Raafat',
        status: 'Rejected',
        statusColor: Colors.red,
        id: '20-0-60785',
        year: '4th',
        title: 'EGSA.pdf',
        image: 'assets/project_image/pdf.png'),
    const StudentContainer(
        onTap: null,
        name: 'Mahmoud Abdelnaser',
        status: 'Done',
        statusColor: Colors.green,
        id: '20-0-60785',
        year: '4th',
        title: 'EGSA.pdf',
        image: 'assets/project_image/pdf.png'),
    const StudentContainer(
        onTap: null,
        name: 'Youssef Abdelfatah',
        status: 'Rejected',
        statusColor: Colors.red,
        id: '20-0-60785',
        year: '4th',
        title: 'EGSA.pdf',
        image: 'assets/project_image/pdf.png'),
    const StudentContainer(
        onTap: null,
        name: 'Youssef Abdelfatah',
        status: 'Rejected',
        statusColor: Colors.red,
        id: '20-0-60785',
        year: '4th',
        title: 'EGSA.pdf',
        image: 'assets/project_image/pdf.png'),
    const StudentContainer(
        onTap: null,
        name: 'Ahmed Tarek',
        status: 'Done',
        statusColor: Colors.green,
        id: '20-0-60785',
        year: '4th',
        title: 'EGSA.pdf',
        image: 'assets/project_image/pdf.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Archive',
        onpressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          ListContainer(
            title: 'Requests',
            listOfWidgets: periods,
            emptyMessage: 'No Requests',
          ),
        ],
      ),
    );
  }
}
