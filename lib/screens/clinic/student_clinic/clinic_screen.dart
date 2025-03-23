import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/constants.dart';

import 'appointment_item.dart';

class ClinicScreen extends StatelessWidget {
  const ClinicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Clinic',
        onpressed: () {
          Navigator.pop(context);
        },
      ),
      body: const ClinicBody(),
    );
  }
}

class ClinicBody extends StatelessWidget {
  const ClinicBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ListView(
        children: [
          SvgPicture.asset('assets/project_image/Frame 879.svg'),
          const KButton(
            text: 'New Appointment',
            backgroundColor: kPrimaryColor,
            margin: EdgeInsets.symmetric(horizontal: 16),
          ),
          const AppointmentItem(),
        ],
      ),
    );
  }
}

class AppointmentsList extends StatelessWidget {
  const AppointmentsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
