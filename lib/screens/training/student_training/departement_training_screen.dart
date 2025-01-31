import 'package:flutter/material.dart';
import 'package:graduation_project/components/announcement_card_training.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class DepartementTrainingScreen extends StatelessWidget {
  const DepartementTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get department from navigation arguments
    final String department = ModalRoute.of(context)!.settings.arguments as String? ?? 'Computer';

    return Scaffold(
      appBar: MyAppBar(
        title: 'Training Announcement',
        onpressed: () => Navigator.pop(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('training_announcements')
            .where('departments', arrayContains: department)
            .orderBy('timestamp', descending: true)  // Add this back after index is created
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
            print('No data available. HasData: ${snapshot.hasData}, IsEmpty: ${snapshot.data?.docs.isEmpty}');
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
                        imageBase64: data['logo'] as String?, // Pass base64 string directly
                        title: data['companyName'] ?? 'Unknown Company',
                        onPressed: () {
                          Navigator.pushNamed(
                            context, 
                            '/trainingDetails',
                            arguments: doc.id
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


