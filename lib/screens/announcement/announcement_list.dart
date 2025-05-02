import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'announcement_item.dart';

class AnnouncementList extends StatefulWidget {
  final Axis scrollDirection;
  final bool showOnlyLast; // New parameter to control display mode
  final String year;
  final String department;

  const AnnouncementList({
    super.key,
    required this.scrollDirection,
    this.showOnlyLast = false, // Default to showing all announcements
    required this.year,
    required this.department,
  });

  @override
  _AnnouncementListState createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('announcements');

    if (widget.department.isNotEmpty && widget.year.isNotEmpty) {
      // Both department and year are provided
      // We need to show announcements that:
      // 1. Match the specific department_year combination, OR
      // 2. Match just the department, OR
      // 3. Match just the year, OR
      // 4. Are global announcements
      final String compositeKey = '${widget.department}_${widget.year}';

      query = query.where(Filter.or(
          Filter('targetAudience', arrayContains: compositeKey),
          Filter('targetAudience', arrayContains: widget.department),
          Filter('targetAudience', arrayContains: widget.year),
          Filter('isGlobal', isEqualTo: true)));
    } else if (widget.department.isNotEmpty) {
      // Only department is provided
      query = query.where(Filter.or(
          Filter('targetAudience', arrayContains: widget.department),
          Filter('isGlobal', isEqualTo: true)));
    } else if (widget.year.isNotEmpty) {
      // Only year is provided
      query = query.where(Filter.or(
          Filter('targetAudience', arrayContains: widget.year),
          Filter('isGlobal', isEqualTo: true)));
    } else {
      // Neither is provided, show global announcements only
      query = query.where('isGlobal', isEqualTo: true);
    }

    return StreamBuilder(
      stream: query
          .orderBy('timestamp', descending: true)
          .limit(widget.showOnlyLast ? 1 : 100)
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
