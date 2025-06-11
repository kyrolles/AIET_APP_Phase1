import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/screens/invoice/it_incoive/get_requests_cubit/get_requests_cubit.dart';
import '../components/my_app_bar.dart';
import '../components/service_item.dart';
import 'invoice/student_invoice/invoice_screen.dart';
import 'create_user_screen.dart';
import 'calculator_screen.dart';
import 'invoice/it_incoive/it_invoice_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'announcement/announcement_screen.dart';
import 'admin/assign_results_screen.dart'; // added import for the new screen
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  bool isStaff = false;
  bool isAdmin = false;
  bool canAssignResults = false; // New field for results access

  @override
  void initState() {
    super.initState();
    checkIfStaff();
  }

  String userRole = ''; // Add this variable to store the user's role

  Future<void> checkIfStaff() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          String role = querySnapshot.docs.first['role'];
          setState(() {
            userRole = role; // Store the user's role
            isAdmin = role == 'Admin';
            isStaff = isAdmin ||
                [
                  'IT',
                  'Professor',
                  'Assistant',
                  'Secretary',
                  'Training Unit',
                  'Student Affair'
                ].contains(role);
            // Check if user can assign results
            canAssignResults = ['Admin', 'IT', 'Professor'].contains(role);
          });
        }
      }
    } catch (e) {
      print('Error checking staff status: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final List<ServiceItem> serviceItems = [
      ServiceItem(
        title: localizations?.clinic ?? 'Clinic',
        imageUrl: 'assets/project_image/health-clinic.png',
        backgroundColor: const Color(0xFFFFDD29),
        onPressed: () {
          // Navigate based on user role
          if (userRole == 'Doctor') {
            Navigator.pushNamed(context, '/doctorClinicScreen');
          } else if (userRole == 'Student') {
            Navigator.pushNamed(context, '/clinicStudentScreen');
          } else {
            // Show message for users with other roles            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations?.noPermission ?? 'You do not have access to this feature'),
              ),
            );
          }
        },
      ),
      ServiceItem(
        title: localizations?.trainingAnnouncement ?? 'Student Training',
        imageUrl: 'assets/project_image/analysis.png',
        backgroundColor: const Color(0xFFED1C24),
        onPressed: () {
          Navigator.pushNamed(context, '/studentTraining');
        },
      ),      if (isStaff)
        ServiceItem(
          title: localizations?.staffStudentTraining ?? 'Staff-Student\nTraining',
          imageUrl: 'assets/project_image/analysis.png',
          backgroundColor: const Color(0xFFED1C24),
          onPressed: () {
            Navigator.pushNamed(context, '/staffStudentTraining');
          },
        ),
      // ServiceItem(
      //   title: 'Moodle',
      //   imageUrl: 'assets/project_image/education.png',
      //   backgroundColor: const Color(0xFFFF9811),
      //   onPressed: () {},
      // ),
      // ServiceItem(
      //   title: 'Unofficial Transcript',
      //   imageUrl: 'assets/project_image/transcription.png',
      //   backgroundColor: const Color(0xFF0ED290),
      //   onPressed: () {},
      // ),      ServiceItem(
        title: localizations?.gpaCalculator ?? 'GPA Calculator',
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
        title: localizations?.studentAffairs ?? 'Student Affairs',
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
        title: localizations?.staffStudentAffairs ?? 'Staff Student Affairs',
        imageUrl: 'assets/project_image/invoice.png',
        backgroundColor: const Color(0xFF8AC9FE),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return BlocProvider(
                  create: (context) => GetRequestsCubit(),
                  child: const ItInvoiceScreen(),
                );
              },
            ),
          );
        },
      ),

      if (canAssignResults) // Only show for Admin, IT, or Professor
        ServiceItem(
          title: localizations?.grades ?? 'Assign Results',
          imageUrl: 'assets/project_image/result.png',
          backgroundColor: const Color(0xFFCC70EC),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AssignResultsScreen(),
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
        title: localizations?.ePayment ?? 'E-Payment',
        imageUrl: 'assets/project_image/e-wallet.png',
        backgroundColor: const Color(0xFFFFBCAB),
        onPressed: () {},
      ),
      if (isStaff)
        ServiceItem(
          title: localizations?.announcements ?? 'Announcements',
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
                SnackBar(
                    content: Text(localizations?.announcementPosted ?? 'Announcement posted successfully!')),
              );
            }
          },
        ),
      if (isAdmin)
        ServiceItem(
          title: localizations?.createUser ?? 'Create User',
          imageUrl: 'assets/project_image/invoice.png',
          backgroundColor: const Color(0xFFCC70EC),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const CreateUserScreen();
                },
              ),
            );
          },
        ),
      // Add more service items here
    ];

    return Scaffold(
      appBar: MyAppBar(
        title: localizations?.services ?? 'Services',
        onpressed: () {
          Navigator.pop(context);
        },
      ),
      body: ListView(
        children: [
          const SizedBox(height: 18),          ...serviceItems
              .where((item) => item.title != localizations?.staffStudentAffairs && item.title != 'Staff Student Affairs' || isStaff)
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
