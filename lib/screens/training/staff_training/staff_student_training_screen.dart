import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_item.dart';

class StaffstudentTrainingScreen extends StatelessWidget {
  const StaffstudentTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Staff-Student Training',
        onpressed: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.only(top: 15),
        children: [
          ServiceItem(
            title: 'Create\nAnnouncement',
            imageUrl: 'assets/project_image/loudspeaker.png',
            backgroundColor: const Color.fromRGBO(41, 128, 185, 1),
            onPressed: () {},
          ),
          ServiceItem(
            title: 'Validate',
            imageUrl: 'assets/project_image/validation.png',
            backgroundColor: const Color.fromRGBO(41, 128, 185, 1),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
