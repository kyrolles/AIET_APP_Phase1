import 'package:flutter/material.dart';
import 'package:graduation_project/components/announcement_card_training.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class DepartementTrainingScreen extends StatelessWidget {
  const DepartementTrainingScreen({super.key});

  Future<bool> _checkUserPermission() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) return false;

    final role = userDoc.data()?['role'] as String?;
    return role == 'Admin' || role == 'Training Unit';
  }

  Future<void> _deleteAnnouncement(BuildContext context, String docId) async {
    // Create a scaffold messenger key to show snackbar after navigation
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      await FirebaseFirestore.instance
          .collection('training_announcements')
          .doc(docId)
          .delete();

      // Only show snackbar if mounted
      if (scaffoldMessenger.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Announcement deleted successfully')),
        );
      }
    } catch (e) {
      if (scaffoldMessenger.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error deleting announcement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get department from navigation arguments
    final String department = ModalRoute.of(context)!.settings.arguments as String? ?? 'Computer';

    return Scaffold(
      appBar: MyAppBar(
        title: 'Training Announcement',
        onpressed: () => Navigator.pop(context),
      ),
      body: FutureBuilder<bool>(
        future: _checkUserPermission(),
        builder: (context, permissionSnapshot) {
          final bool canDelete = permissionSnapshot.data ?? false;
          
          return StreamBuilder<QuerySnapshot>(
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
                            canDelete: canDelete,
                            onDelete: canDelete 
                              ? () => _showDeleteConfirmation(context, doc.id)
                              : null,
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
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, String docId) async {
    final scaffoldContext = context;
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Announcement'),
          content: const Text('Are you sure you want to delete this announcement?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Pop dialog first
                Navigator.of(dialogContext).pop();
                // Then delete using the original scaffold context
                await _deleteAnnouncement(scaffoldContext, docId);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}


