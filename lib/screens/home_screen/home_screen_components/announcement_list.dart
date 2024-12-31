import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/screens/home_screen/home_screen_components/announcement_item.dart';

class AnnouncementList extends StatefulWidget {
  const AnnouncementList({super.key});

  @override
  State<AnnouncementList> createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<DocumentSnapshot> _announcements = [];

  @override
  void initState() {
    super.initState();
    _setupAnnouncementsListener();
  }

  void _setupAnnouncementsListener() {
    FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _announcements.insert(0, change.doc);
          _listKey.currentState
              ?.insertItem(0, duration: const Duration(milliseconds: 300));
        } else if (change.type == DocumentChangeType.removed) {
          int index =
              _announcements.indexWhere((doc) => doc.id == change.doc.id);
          if (index != -1) {
            _announcements.removeAt(index);
            _listKey.currentState?.removeItem(
              index,
              (context, animation) => _buildRemovedItem(change.doc, animation),
              duration: const Duration(milliseconds: 300),
            );
          }
        }
      }
    });
  }

  Widget _buildRemovedItem(DocumentSnapshot doc, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: AnnouncementItem(doc: doc),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedList(
        key: _listKey,
        initialItemCount: _announcements.length,
        itemBuilder: (context, index, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: AnnouncementItem(doc: _announcements[index]),
            ),
          );
        },
      ),
    );
  }
}
