import 'package:flutter/material.dart';
import 'package:graduation_project/components/announcement_card_training.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:convert';

class DepartementTrainingScreen extends StatelessWidget {
  const DepartementTrainingScreen({super.key});

  Future<bool> _canDeleteAnnouncement() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) return false;

    final String role = userDoc.data()?['role'] ?? '';
    return role == 'Admin' || role == 'Training Unit';
  }

  @override
  Widget build(BuildContext context) {
    // Get department from navigation arguments
    final String department =
        ModalRoute.of(context)!.settings.arguments as String? ?? 'Computer';

    return Scaffold(
      appBar: MyAppBar(
        title: 'Training Announcement',
        onpressed: () => Navigator.pop(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('training_announcements')
            .where('departments', arrayContains: department)
            .orderBy('timestamp',
                descending: true) // Add this back after index is created
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Firestore Error: ${snapshot.error}');
            print('Error Stack Trace: ${snapshot.stackTrace}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print(
                'No data available. HasData: ${snapshot.hasData}, IsEmpty: ${snapshot.data?.docs.isEmpty}');
            return const Center(child: Text('No announcements available'));
          }

          print('Number of documents: ${snapshot.data!.docs.length}');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Column(
                children: snapshot.data!.docs.map((doc) {
                  try {
                    final data = doc.data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: AnnouncementCard(
                        imageBase64: data['logo']
                            as String?, // Pass base64 string directly
                        title: data['companyName'] ?? 'Unknown Company',
                        onPressed: () {
                          Navigator.pushNamed(context, '/trainingDetails',
                              arguments: doc.id);
                        },
                        onLongPress: () async {
                          final canDelete = await _canDeleteAnnouncement();
                          if (!canDelete) return;

                          showModalBottomSheet(
                            backgroundColor:
                                const Color.fromRGBO(250, 250, 250, 1),
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            builder: (BuildContext context) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Confirm Deletion',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    KButton(
                                      text: 'Delete',
                                      textColor: Colors.red,
                                      backgroundColor: Colors.transparent,
                                      borderWidth: 2,
                                      borderColor: Colors.red,
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('training_announcements')
                                            .doc(doc.id)
                                            .delete();
                                        Navigator.pop(context);
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    KButton(
                                      text: 'Cancel',
                                      backgroundColor: Colors.grey.shade200,
                                      textColor: Colors.black,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  } catch (e) {
                    print('Error parsing document: $e'); // Add error logging
                    return const SizedBox.shrink();
                  }
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
