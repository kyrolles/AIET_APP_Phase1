import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/components/activities_list_view.dart';
import 'package:graduation_project/components/text_link.dart';
import 'package:graduation_project/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:graduation_project/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String userName = '';
  String? currentUserEmail;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<DocumentSnapshot> _announcements = [];
  final storage = FlutterSecureStorage();

  // Animation controller for blur effect
  late AnimationController _blurController;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    _setupAnnouncementsListener();

    // Initialize the animation controller
    _blurController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Define the blur animation
    _blurAnimation = Tween<double>(begin: 0, end: 10).animate(_blurController);
  }

  @override
  void dispose() {
    _blurController.dispose();
    super.dispose();
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
        userName = userDoc['name'][0];
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
          _listKey.currentState
              ?.insertItem(0, duration: const Duration(milliseconds: 300));
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

  void _showFullScreenImage(BuildContext context, String imageBase64) {
    _blurController.forward();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: AnimatedBuilder(
            animation: _blurAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _blurAnimation.value,
                      sigmaY: _blurAnimation.value,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _blurController.reverse().then((_) {
                        Navigator.of(context).pop();
                      });
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: InteractiveViewer(
                        panEnabled: true,
                        boundaryMargin: const EdgeInsets.all(0),
                        minScale: 1.0,
                        maxScale: 3.0,
                        child: Center(
                          child: Image.memory(
                            base64Decode(imageBase64),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showFullScreenPDF(BuildContext context, String pdfBase64) {
    final pdfBytes = base64Decode(pdfBase64);
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/temp.pdf');
    tempFile.writeAsBytesSync(pdfBytes);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('PDF Viewer'),
          ),
          body: PDFView(
            filePath: tempFile.path,
          ),
        ),
      ),
    );
  }

  Widget _buildPDFWidget(String pdfBase64, String fileName) {
    return GestureDetector(
      onTap: () {
        _showFullScreenPDF(context, pdfBase64);
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/4726010.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Center(
                child: Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementItem(DocumentSnapshot doc) {
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
          if (imageBase64 != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                onTap: () {
                  _showFullScreenImage(context, imageBase64);
                },
                child: Image.memory(
                  base64Decode(imageBase64),
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (pdfBase64 != null && pdfFileName != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildPDFWidget(
                pdfBase64,
                pdfFileName,
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

  bool _isArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  Future<void> _logout() async {
    // Clear the saved token
    await storage.delete(key: 'token');

    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Navigate back to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
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
        ],
      ),
    );
  }
}