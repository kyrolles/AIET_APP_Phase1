import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/screens/announcement/announcement_list.dart';

class AllAnnouncementAppearOnOneScreen extends StatelessWidget {
  const AllAnnouncementAppearOnOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Announcements',
        onpressed: () => Navigator.pop(context),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            AnnouncementList(
              scrollDirection: Axis.vertical,
            ),
          ],
        ),
      ),
    );
  }
}
