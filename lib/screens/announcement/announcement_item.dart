import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'upload_image.dart';
import 'upload_pdf.dart';

import '../../constants.dart';

class AnnouncementItem extends StatefulWidget {
  const AnnouncementItem({super.key, required this.doc});
  final DocumentSnapshot doc;

  @override
  State<AnnouncementItem> createState() => _AnnouncementItemState();
}

class _AnnouncementItemState extends State<AnnouncementItem> {
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  Future<void> deleteAnnouncement(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(docId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting announcement: $e')),
        );
      }
    }
  }

  bool _isArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  String _formatTimestamp(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final month = _getMonthName(dateTime.month);
    return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period · $month ${dateTime.day}, ${dateTime.year}';
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as Timestamp?; // Cast to Timestamp
    final formattedTimestamp = timestamp != null
        ? _formatTimestamp(timestamp.toDate())
        : 'No date'; // Convert to DateTime and format
    final imageBase64 = data['imageBase64'] as String?;
    final pdfBase64 = data['pdfBase64'] as String?;
    final pdfFileName = data['pdfFileName'] as String?;
    final title = data['title'] as String?;
    final text = data['text'] as String?;

    // Add role check for delete permission
    Future<bool> checkDeletePermission() async {
      if (currentUserEmail == null) return false;

      QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .get();

      if (userDocs.docs.isEmpty) return false;

      String userRole = userDocs.docs.first['role'];
      return userRole == 'Admin' || currentUserEmail == data['email'];
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: kShadow,
      ),
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(22.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      AssetImage('assets/images/dr-sheshtawey.jpg'),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      data['author'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                FutureBuilder<bool>(
                  future: checkDeletePermission(),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => showDeleteBottomSheet(context, doc.id),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Align(
                alignment: _isArabic(title)
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection:
                      _isArabic(title) ? TextDirection.rtl : TextDirection.ltr,
                ),
              ),
            ),
          Align(
            alignment: _isArabic(text ?? '')
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Text(
              text ?? '',
              style: const TextStyle(
                fontSize: 17,
              ),
              textDirection:
                  _isArabic(text ?? '') ? TextDirection.rtl : TextDirection.ltr,
            ),
          ),
          //! Image uploading widget
          UploadImage(imageBase64: imageBase64),
          //! PDF uploading widget
          UploadPdf(pdfBase64: pdfBase64, pdfFileName: pdfFileName),
          const SizedBox(height: 8),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              formattedTimestamp, // Use formatted timestamp
              style: const TextStyle(
                color: Color(0XFF657786),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showDeleteBottomSheet(BuildContext context, String docId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Delete Announcement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to delete this announcement?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      deleteAnnouncement(docId);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
