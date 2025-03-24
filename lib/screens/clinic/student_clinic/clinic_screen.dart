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

class ClinicBody extends StatefulWidget {
  const ClinicBody({
    super.key,
  });

  @override
  State<ClinicBody> createState() => _ClinicBodyState();
}

class _ClinicBodyState extends State<ClinicBody> {
  bool isBooked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          SvgPicture.asset('assets/project_image/Frame 879.svg'),
          KButton(
            onPressed: () {},
            text: 'New Appointment',
            backgroundColor: kPrimaryColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your Appointment',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'lexend',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          isBooked
              ? const AppointmentItem()
              : const Center(
                  child: Text(
                    'No appointment has been booked',
                    style: TextStyle(color: kGrey),
                  ),
                ),
        ],
      ),
    );
  }
}
