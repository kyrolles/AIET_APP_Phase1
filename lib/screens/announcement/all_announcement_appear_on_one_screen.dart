import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/screens/announcement/announcement_list.dart';

class AllAnnouncementAppearOnOneScreen extends StatelessWidget {
  final String userYear;
  final String userDepartment;

  const AllAnnouncementAppearOnOneScreen(
      {super.key, this.userYear = '', this.userDepartment = ''});

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
      ),
    );
  }
}
