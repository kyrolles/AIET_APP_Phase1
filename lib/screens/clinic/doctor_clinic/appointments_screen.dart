import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/screens/clinic/student_clinic/appointment_item.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Appointments',
        onpressed: () {
          Navigator.pop(context);
        },
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: AppointmentItem(),
          );
        },
      ),
    );
  }
}
