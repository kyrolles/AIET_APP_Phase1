import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/screens/announcement/announcement_list.dart';

class AllAnnouncementAppearOnOneScreen extends StatelessWidget {
  final String userYear;
  final String userDepartment;
  final String userRole; // Add this parameter

  const AllAnnouncementAppearOnOneScreen({
    super.key,
    this.userYear = '',
    this.userDepartment = '',
    required this.userRole, // Make it required
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Announcements',
        onpressed: () => Navigator.pop(context),
      ),
      body: AnnouncementList(
        scrollDirection: Axis.vertical,
        year: userYear,
        department: userDepartment,
        userRole: userRole, // Pass it to AnnouncementList
      ),
    );
  }
}
