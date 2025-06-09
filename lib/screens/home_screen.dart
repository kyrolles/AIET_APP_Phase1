import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/screens/announcement/all_announcement_appear_on_one_screen.dart';
import 'dart:convert';
import 'package:graduation_project/screens/drawer/app_drawer.dart';
import 'package:graduation_project/screens/invoice/it_incoive/get_requests_cubit/get_requests_cubit.dart';
import 'package:graduation_project/services/notification_service.dart';
import '../components/activities_list_view.dart';
import '../components/schedule/home_schedule_view.dart';
import '../components/text_link.dart';
import '../constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'announcement/announcement_list.dart';
import 'package:graduation_project/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String userRule = '';
  String userName = '';
  String? currentUserEmail;
  String? imageBase64; // Added missing variable declaration
  String userDepartment = '';
  String userYear = '';

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchUserName();
    currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  }

  Future<void> fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;

        // Check in the users collection
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          userRule = userDoc['role'];
          log(userRule);
          setState(() {
            userName = '${userDoc['firstName']} ${userDoc['lastName']}'.trim();
            imageBase64 = userDoc['profileImage'] as String?; // Fixed casting

            userDepartment = userDoc['department'] ?? '';
            userYear = userDoc['academicYear'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint(
          'Error fetching user name: $e'); // Using debugPrint instead of print
    }
  }

  Future<void> _logout() async {
    try {
      // Clean up FCM token
      final notificationService = NotificationService();
      await notificationService.cleanupOnLogout();

      // Clear the saved token
      await storage.delete(key: 'token');

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      if (!mounted) return; // Added mounted check

      // Navigate back to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeScreenAppBar(context),
      drawer: AppDrawer(_logout, userRole: userRule),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                style: const TextStyle(
                  color: Colors.black,
                ),
                decoration: kTextFeildInputDecoration,
                onChanged: (value) {},
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: TextLink(
              text: 'Activities',
            ),
          ),
          SliverToBoxAdapter(
            child: ActivitiesListView(userRule: userRule),
          ),
          SliverToBoxAdapter(
            child: TextLink(
              text: 'Announcements',
              textLink: 'View All',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllAnnouncementAppearOnOneScreen(
                      userYear: userYear,
                      userDepartment: userDepartment,
                      userRole: userRule, // Pass the user role here
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: AnnouncementList(
              scrollDirection: Axis.vertical,
              showOnlyLast: true,
              year: userYear,
              department: userDepartment,
              userRole: userRule, // Pass the user role here
            ),
          ),
          // Schedule Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextLink(
                text: 'My Schedule',
                onTap: () {
                  // Navigate to full schedule view if needed
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: HomeScheduleView(),
            ),
          ),
        ],
      ),
    );
  }

  AppBar homeScreenAppBar(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: Image.asset(
              'assets/images/paragraph.png',
              width: 30.0,
              height: 30.0,
              fit: BoxFit.contain,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      title: Row(
        children: [
          const Spacer(),
          Text(
            userName.isNotEmpty ? 'Hi, ${userName.split(' ')[0]}!' : 'Hi!',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 27),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            child: imageBase64 != null
                ? ClipOval(
                    child: Image.memory(
                      base64Decode(imageBase64!),
                      fit: BoxFit.cover,
                      width: 50, // Adjusted width to match radius
                      height: 50, // Adjusted height to match radius
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error displaying image: $error');
                        return const Icon(Icons.person, size: 25);
                      },
                    ),
                  )
                : const Icon(Icons.person, size: 25),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
