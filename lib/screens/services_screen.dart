import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_items.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/calculator_screen.dart';
import 'package:graduation_project/screens/tuition_fees_request.dart';
import 'package:graduation_project/screens/tuition_fees_download.dart';
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ServiceItem> serviceItems = [
      ServiceItem(
        title: 'Clinic',
        imageUrl: 'assets/project_image/health-clinic.png',
        backgroundColor: const Color(0xFFFFDD29),
        onPressed: () {
          // print('Button pressed:');
        },
      ),
      ServiceItem(
        title: 'Student Training',
        imageUrl: 'assets/project_image/analysis.png',
        backgroundColor: const Color(0xFFED1C24),
        onPressed: () {},
      ),
      ServiceItem(
        title: 'Moodle',
        imageUrl: 'assets/project_image/education.png',
        backgroundColor: const Color(0xFFFF9811),
        onPressed: () {},
      ),
      ServiceItem(
        title: 'Unofficial Transcript',
        imageUrl: 'assets/project_image/transcription.png',
        backgroundColor: const Color(0xFF0ED290),
        onPressed: () {},
      ),
      ServiceItem(
        title: 'GPA Calculator',
        imageUrl: 'assets/project_image/gpa.png',
        backgroundColor: const Color(0xFF006DF0),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const GPACalculatorScreen();
              },
            ),
          );
        },
      ),
      ServiceItem(
        title: 'Invoices',
        imageUrl: 'assets/project_image/invoice.png',
        backgroundColor: const Color(0xFF8AC9FE),
        onPressed: () {
          showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return TuitionFeesPreview();
          },
        );},
      ),
      ServiceItem(
        title: 'IT-Invoices',
        imageUrl: 'assets/project_image/invoice.png',
        backgroundColor: const Color(0xFF8AC9FE),
        onPressed: () {},
      ),
      ServiceItem(
        title: 'E-Payment',
        imageUrl: 'assets/project_image/e-wallet.png',
        backgroundColor: const Color(0xFFFFBCAB),
        onPressed: () {},
      ),
      // Add more service items here
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(kToolbarHeight), // Standard AppBar height
        child: DecoratedBox(
          decoration: const BoxDecoration(boxShadow: kShadow),
          child: MyAppBar(
            title: 'Services',
            onpressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 18),
          ...serviceItems.map((item) => ServiceItem(
                title: item.title,
                imageUrl: item.imageUrl,
                backgroundColor: item.backgroundColor,
                onPressed: item.onPressed,
              )),
        ],
      ),
    );
  }
}
