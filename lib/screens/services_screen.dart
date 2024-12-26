import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_items.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/invoice_screen.dart';
import 'package:graduation_project/screens/calculator_screen.dart';
import 'package:graduation_project/screens/it_invoice_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/screens/announcement_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  bool isStaff = false;

  @override
  void initState() {
    super.initState();
    checkIfStaff();
  }

  Future<void> checkIfStaff() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('staffs')
            .where('email', isEqualTo: email)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            isStaff = true;
          });
        }
      }
    } catch (e) {
      print('Error checking staff status: $e');
    }
  }

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const InvoiceScreen();
              },
            ),
          );
        },
      ),
      ServiceItem(
        title: 'IT-Invoices',
        imageUrl: 'assets/project_image/invoice.png',
        backgroundColor: const Color(0xFF8AC9FE),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const ItInvoiceScreen();
              },
            ),
          );
        },
      ),
      // ServiceItem(
      //   title: 'Tuition Fees Upload',
      //   imageUrl: 'assets/project_image/invoice.png',
      //   backgroundColor: const Color(0xFF8AC9FE),
      //   onPressed: () {
      //     showModalBottomSheet(
      //       context: context,
      //       isScrollControlled: true,
      //       shape: const RoundedRectangleBorder(
      //         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      //       ),
      //       builder: (BuildContext context) {
      //         return const TuitionFeesSheet();
      //       },
      //     );
      //   },
      // ),
      ServiceItem(
        title: 'E-Payment',
        imageUrl: 'assets/project_image/e-wallet.png',
        backgroundColor: const Color(0xFFFFBCAB),
        onPressed: () {},
      ),
      if (isStaff)
        ServiceItem(
          title: 'Announcements',
          imageUrl: 'assets/project_image/announcement.png',
          backgroundColor: const Color(0xFFFFBCAB),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AnnouncementScreen(),
              ),
            );
            if (result == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Announcement posted successfully!')),
              );
            }
          },
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
          ...serviceItems
              .where((item) => item.title != 'IT-Invoices' || isStaff)
              .map((item) => ServiceItem(
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
