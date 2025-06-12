import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/my_app_bar.dart';

class TrianingDetailsScreen extends StatelessWidget {
  const TrianingDetailsScreen({super.key});

  Future<void> _launchURL(BuildContext context, String urlString) async {
    try {
      urlString = urlString.trim();
      if (!urlString.startsWith('http://') &&
          !urlString.startsWith('https://')) {
        urlString = 'https://' + urlString.replaceAll('www.', '');
      }

      final Uri uri = Uri.parse(urlString);
      if (!await canLaunchUrl(uri)) {
        throw 'Could not launch $urlString';
      }

      final bool success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!success) {
        throw 'Failed to launch $urlString';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open link: $urlString\nError: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildClickableLinks(BuildContext context, String links) {
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
              onTap: () => _launchURL(context, trimmedLink),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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
    final localizations = AppLocalizations.of(context);
    final String announcementId =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: MyAppBar(
        title: localizations?.trainingDetails ?? 'Training Details',
        onpressed: () => Navigator.pop(context),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('training_announcements')
            .doc(announcementId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text(localizations?.errorLoadingDetails ??
                    'Error loading details'));
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
                if (data['logo'] != null)
                  Center(
                    child: Image.memory(
                      base64Decode(data['logo']),
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  data['companyName'] ?? 'Unknown Company',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  data['description'] ?? 'No description available',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations?.importantLinks ?? 'Important Links:',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildClickableLinks(
                    context,
                    data['links'] ??
                        (localizations?.noLinksAvailable ??
                            'No links available')),
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
