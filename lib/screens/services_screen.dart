import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_items.dart';
import 'package:graduation_project/constants.dart';

class ServicesScreen extends StatelessWidget {
  ServicesScreen({super.key});

  final List<ServiceItemData> _serviceItems = [
    ServiceItemData(
      title: 'Clinic',
      imageUrl: 'assets/project_image/health-clinic.png',
      backgroundColor: Color(0xFFFFDD29),
    ),
    ServiceItemData(
      title: 'Student Training',
      imageUrl: 'assets/project_image/analysis.png',
      backgroundColor: Color(0xFFED1C24),
    ),
    ServiceItemData(
      title: 'Moodle',
      imageUrl: 'assets/project_image/education.png',
      backgroundColor: Color(0xFFFF9811),
    ),
    ServiceItemData(
      title: 'Unofficial Transcript',
      imageUrl: 'assets/project_image/transcription.png',
      backgroundColor: Color(0xFF0ED290),
    ),
    ServiceItemData(
      title: 'GPA Calculator',
      imageUrl: 'assets/project_image/gpa.png',
      backgroundColor: Color(0xFF006DF0),
    ),
    ServiceItemData(
      title: 'Invoices',
      imageUrl: 'assets/project_image/invoice.png',
      backgroundColor: Color(0xFF8AC9FE),
    ),
    ServiceItemData(
      title: 'E-Payment',
      imageUrl: 'assets/project_image/e-wallet.png',
      backgroundColor: Color(0xFFFFBCAB),
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

class ServiceItemData {
  final String title;
  final String imageUrl;
  final Color backgroundColor;

  ServiceItemData({
    required this.title,
    required this.imageUrl,
    required this.backgroundColor,
  });
}
