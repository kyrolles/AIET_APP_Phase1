import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/constants.dart';

class NewAppointmentScreen extends StatelessWidget {
  const NewAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'New Appointment',
        onpressed: () {
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'lexend',
              ),
            ),
            const Text('Here will be the widget for selecting the time'),
            const Text(
              'Write your problem',
              style: TextStyle(fontFamily: 'lexend'),
            ),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your problem',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            KButton(
              onPressed: () {},
              text: 'Set Appointment',
              backgroundColor: kPrimaryColor,
            )
          ],
        ),
      ),
    );
  }
}
