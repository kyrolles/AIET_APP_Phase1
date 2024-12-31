import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/components/activities_list_view.dart';
import 'package:graduation_project/components/text_link.dart';
import 'package:graduation_project/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/screens/home_screen/home_screen_components/announcement_list.dart';
import 'package:graduation_project/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String userName = '';
  String? currentUserEmail;

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
        await checkCollectionForUser('users', email);
        if (userName.isEmpty) {
          await checkCollectionForUser('staffs', email);
        }
        if (userName.isEmpty) {
          await checkCollectionForUser('teaching_staff', email);
        }
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  Future<void> checkCollectionForUser(String collection, String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      setState(() {
        userName = userDoc['name'][0];
      });
    }
  }

  Future<void> _logout() async {
    // Clear the saved token
    await storage.delete(key: 'token');

    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Navigate back to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeScreenAppBar(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              style: const TextStyle(
                color: Colors.black,
              ),
              decoration: kTextFeildInputDecoration,
              onChanged: (value) {},
            ),
          ),
          const TextLink(
            text: 'Activities',
            textLink: 'see more',
          ),
          const ActivitiesListView(),
          const TextLink(
            text: 'Announcements',
            textLink: 'View All',
          ),
          const AnnouncementList(),
        ],
      ),
    );
  }

  AppBar homeScreenAppBar() {
    return AppBar(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Image.asset(
          'assets/images/paragraph.png',
          width: 30.0,
          height: 30.0,
          fit: BoxFit.contain,
        ),
        onPressed: () {
          // Define the action for when the icon is tapped
        },
      ),
      title: Row(
        children: [
          const Spacer(),
          Text(
            userName.isNotEmpty ? 'Hi, $userName!' : 'Hi!',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 27),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage('assets/images/1704502172296.jfif'),
          ),
          const Spacer(flex: 2),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
        ),
      ],
    );
  }
}
