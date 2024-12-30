import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/components/activities_list_view.dart';
import 'package:graduation_project/components/text_link.dart';
import 'package:graduation_project/constants.dart';
import 'dart:convert';
import 'dart:ui'; // Required for ImageFilter.blur

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  String? currentUserEmail;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<DocumentSnapshot> _announcements = [];

  @override
  void initState() {
    super.initState();
    fetchUserName();
    currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    _setupAnnouncementsListener();
  }

  Future<void> fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        await checkCollectionForUser('users', email);
        if (userName.isEmpty) {
          await checkCollectionForUser('staffs', email);
        }
        if (userName.isEmpty) {
          await checkCollectionForUser('teaching_staff', email);
        }
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  Future<void> checkCollectionForUser(String collection, String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      setState(() {
        userName = userDoc['name'][0]; // Get the first character of the name
      });
    }
  }

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

  void _setupAnnouncementsListener() {
    FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _announcements.insert(0, change.doc);
          _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
        } else if (change.type == DocumentChangeType.removed) {
          int index = _announcements.indexWhere((doc) => doc.id == change.doc.id);
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
      child: _buildAnnouncementItem(doc),
    );
  }

  // Function to show the image in full screen with a blurred background
  void _showFullScreenImage(BuildContext context, String imageBase64) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero, // Remove default padding
          backgroundColor: Colors.transparent, // Make the dialog background transparent
          child: Stack(
            children: [
              // Blurred background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Adjust blur intensity
                child: Container(
                  color: Colors.black.withOpacity(0.5), // Semi-transparent black overlay
                ),
              ),
              // Full-screen image
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Close the dialog when tapped
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: InteractiveViewer(
                    panEnabled: true, // Allow panning
                    boundaryMargin: EdgeInsets.all(0), // No margin
                    minScale: 1.0, // Minimum scale
                    maxScale: 3.0, // Maximum scale for zooming
                    child: Center(
                      child: Image.memory(
                        base64Decode(imageBase64),
                        fit: BoxFit.contain, // Ensure the image fits within the screen
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as String?;
    final imageBase64 = data['imageBase64'] as String?;
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
                  backgroundImage: AssetImage('assets/images/dr-sheshtawey.jpg'),
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
                            content: const Text('Are you sure you want to delete this announcement?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
                alignment: _isArabic(title) ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: _isArabic(title) ? TextDirection.rtl : TextDirection.ltr,
                ),
              ),
            ),
          Align(
            alignment: _isArabic(text ?? '') ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              text ?? '',
              style: const TextStyle(
                fontSize: 17,
              ),
              textDirection: _isArabic(text ?? '') ? TextDirection.rtl : TextDirection.ltr,
            ),
          ),
          if (imageBase64 != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                onTap: () {
                  _showFullScreenImage(context, imageBase64); // Show full screen image
                },
                child: Image.memory(
                  base64Decode(imageBase64), // Decode the Base64 string
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
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

  // Helper function to check if the text is in Arabic
  bool _isArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]'); // Arabic Unicode range
    return arabicRegex.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: DecoratedBox(
          decoration: const BoxDecoration(boxShadow: kShadow),
          child: AppBar(
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Image.asset(
                'assets/images/paragraph.png',
                width: 30.0,
                height: 30.0,
                fit: BoxFit.contain,
              ),
              onPressed: () {
                // Define the action for when the icon is tapped
              },
            ),
            title: Row(
              children: [
                const Spacer(),
                Text(
                  userName.isNotEmpty ? 'Hi, $userName!' : 'Hi!',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 27),
                ),
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage('assets/images/1704502172296.jfif'),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              style: const TextStyle(
                color: Colors.black,
              ),
              decoration: kTextFeildInputDecoration,
              onChanged: (value) {},
            ),
          ),
          const TextLink(
            text: 'Activities',
            textLink: 'see more',
          ),
          const ActivitiesListView(),
          const TextLink(
            text: 'Announcements',
            textLink: 'View All',
          ),
          Expanded(
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
                    child: _buildAnnouncementItem(_announcements[index]),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: kShadow,
            ),
            margin: const EdgeInsets.all(12.0),
            padding: const EdgeInsets.all(22.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: AssetImage('assets/images/dr-sheshtawey.jpg'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Text(
                          'DR.Reda El-Sheshtawy',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'أهلاً بكم في العام الدراسي الجديد! أتمنى لكم سنة مليئة بالنجاح والتقدم. استعدوا للغوص في عالم المعرفة واكتشاف إمكانياتكم. بالتوفيق!',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    '5:25 PM · Sep 1, 2024',
                    style: TextStyle(
                      color: Color(0XFF657786),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}