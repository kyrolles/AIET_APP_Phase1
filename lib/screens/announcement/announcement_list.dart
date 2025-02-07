import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'announcement_item.dart';

class AnnouncementList extends StatefulWidget {
  final Axis scrollDirection;
  const AnnouncementList({super.key, required this.scrollDirection});

  @override
  _AnnouncementListState createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No announcements found.'));
        }

        final announcements = snapshot.data!.docs;
        return ListView.builder(
          scrollDirection: widget.scrollDirection,
          itemCount: announcements.length,
          shrinkWrap: true,
          addAutomaticKeepAlives: true,
          cacheExtent: 100,
          // physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return AnnouncementItem(doc: announcements[index]);
          },
        );
      },
    );
  }
}
