import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../../../components/my_app_bar.dart';

class TrianingDetailsScreen extends StatefulWidget {  // Changed to StatefulWidget
  const TrianingDetailsScreen({super.key});

  @override
  State<TrianingDetailsScreen> createState() => _TrianingDetailsScreenState();
}

class _TrianingDetailsScreenState extends State<TrianingDetailsScreen> {
  late ScaffoldMessengerState scaffoldMessenger;
  bool _isDisposed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _launchURL(String urlString) async {
    if (_isDisposed) return;

    try {
      urlString = urlString.trim();
      if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
        urlString = 'https://$urlString';
      }

      final Uri uri = Uri.parse(urlString);
      if (!await canLaunchUrl(uri)) {
        if (!_isDisposed) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Could not launch $urlString')),
          );
        }
        return;
      }

      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!_isDisposed) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildClickableLinks(String links) {  // Removed BuildContext parameter
    final linksList = links.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: linksList.map((link) {
        final trimmedLink = link.trim();
        if (trimmedLink.isEmpty) return const SizedBox.shrink();
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => _launchURL(trimmedLink),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  trimmedLink,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String announcementId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: MyAppBar(
        title: 'Training Details',
        onpressed: () => Navigator.pop(context),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('training_announcements')
            .doc(announcementId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading details'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['logo'] != null) Center(
                  child: Image.memory(
                    base64Decode(data['logo']),
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  data['companyName'] ?? 'Unknown Company',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  data['description'] ?? 'No description available',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Important Links:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildClickableLinks(data['links'] ?? 'No links available'),
                if (data['image'] != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Image.memory(
                      base64Decode(data['image']),
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
