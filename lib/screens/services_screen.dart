import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_items.dart';
import 'package:graduation_project/constants.dart';

class ServicesScreen extends StatelessWidget {
  ServicesScreen({super.key});

  final List<ServiceItem> _serviceItems = [
    ServiceItem(
      title: 'Clinic',
      imageUrl: 'assets/project_image/health-clinic.png',
      backgroundColor: const Color(0xFFFFDD29),
      onPressed: () {},
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
      onPressed: () {},
    ),
    ServiceItem(
      title: 'Invoices',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(kToolbarHeight), // Standard AppBar height
        child: DecoratedBox(
          decoration: const BoxDecoration(boxShadow: kShadow),
          child: MyAppBar(
            title: 'Services',
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            width: 375,
            height: 788,
            padding: const EdgeInsets.symmetric(vertical: 10),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _serviceItems
                  .map((item) => ServiceItem(
                        title: item.title,
                        imageUrl: item.imageUrl,
                        backgroundColor: item.backgroundColor,
                        onPressed: () {
                          // Handle the button press here
                          // print('Button pressed: ${item.title}');
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
