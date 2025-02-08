import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'announcement_item.dart';

class AnnouncementList extends StatefulWidget {
  final Axis scrollDirection;
  final bool showOnlyLast; // New parameter to control display mode

  const AnnouncementList({
    super.key,
    required this.scrollDirection,
    this.showOnlyLast = false, // Default to showing all announcements
  });

  @override
  _AnnouncementListState createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('timestamp', descending: true)
          .limit(widget.showOnlyLast
              ? 1
              : 100) // Limit to 1 if showOnlyLast is true
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

        // If showing only last announcement, use a single item instead of ListView
        if (widget.showOnlyLast) {
          return AnnouncementItem(doc: announcements.first);
        }

        return ListView.builder(
          scrollDirection: widget.scrollDirection,
          itemCount: announcements.length,
          shrinkWrap: true,
          addAutomaticKeepAlives: true,
          cacheExtent: 100,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return AnnouncementItem(doc: announcements[index]);
          },
        );
      },
    );
  }
}
