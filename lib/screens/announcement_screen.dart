import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/constants.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  _AnnouncementScreenState createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> postAnnouncement() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an announcement')),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? userName;
        String email = user.email!;

        // Check staffs collection first
        QuerySnapshot staffDocs = await FirebaseFirestore.instance
            .collection('staffs')
            .where('email', isEqualTo: email)
            .get();

        if (staffDocs.docs.isNotEmpty) {
          // Access the name field and convert it to string if it's a list
          var nameField = staffDocs.docs.first.get('name');
          userName =
              nameField is List ? nameField.join(' ') : nameField.toString();
        }

        if (userName == null) {
          // If not found in staffs, check teaching_staff
          QuerySnapshot teacherDocs = await FirebaseFirestore.instance
              .collection('teaching_staff')
              .where('email', isEqualTo: email)
              .get();

          if (teacherDocs.docs.isNotEmpty) {
            var nameField = teacherDocs.docs.first.get('name');
            userName =
                nameField is List ? nameField.join(' ') : nameField.toString();
          }
        }

        if (userName != null) {
          await FirebaseFirestore.instance.collection('announcements').add({
            'text': _controller.text.trim(),
            'timestamp': FieldValue.serverTimestamp(),
            'author': userName,
            'email': email,
          });

          _controller.clear();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text('Announcement posted successfully!'),
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Only staff members can post announcements')),
          );
        }
      }
    } catch (e) {
      print('Error posting announcement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error posting announcement: $e'),
        ),
      );
    }
  }

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
            actions: [
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: postAnnouncement,
              ),
            ],
            onpressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Column(
        children: [
          // The main text input area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null, // Allows the TextField to grow vertically
                  expands:
                      true, // Makes the TextField take up all available space
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Write your announcement here...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
