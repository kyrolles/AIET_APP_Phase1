import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/screens/home_screen/home_screen_components/upload_image.dart';
import 'package:graduation_project/screens/home_screen/home_screen_components/upload_pdf.dart';

import '../../../constants.dart';

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

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as String?;
    final imageBase64 = data['imageBase64'] as String?;
    final pdfBase64 = data['pdfBase64'] as String?;
    final pdfFileName = data['pdfFileName'] as String?;
    final title = data['title'] as String?;
    final text = data['text'] as String?;

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
                if (currentUserEmail == data['email'])
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text('Delete Announcement'),
                            content: const Text(
                                'Are you sure you want to delete this announcement?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancel',
                                    style: TextStyle(color: Colors.black)),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  deleteAnnouncement(doc.id);
                                },
                              ),
                            ],
                          );
                        },
                      );
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
              timestamp ?? 'No date',
              style: const TextStyle(
                color: Color(0XFF657786),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
