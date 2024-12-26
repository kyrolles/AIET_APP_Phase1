import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/components/activities_list_view.dart';
import 'package:graduation_project/components/text_link.dart';
import 'package:graduation_project/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    currentUserEmail = FirebaseAuth.instance.currentUser?.email;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/paragraph.png',
            width: 30.0, // Set desired width
            height: 30.0, // Set desired height
            fit: BoxFit.contain, // Ensure the image fits without distortion
          ),
          onPressed: () {
            // Define the action for when the icon is tapped
          },
        ),
        title: Row(
          children: [
            const Spacer(), // This pushes the content to the center from the start
            Text(
              userName.isNotEmpty ? 'Hi, $userName!' : 'Hi!',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 27),
            ),
            const SizedBox(
                width:
                    8), // Adds a small space between the Text and CircleAvatar
            const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/1704502172296.jfif'),
            ),
            const Spacer(
              flex: 2,
            ), // This pushes the content to the center from the end
          ],
        ),
      ),
      body: ListView(
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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('announcements')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final timestamp = data['timestamp'] as Timestamp?;
                  final formattedDate = timestamp != null
                      ? '${timestamp.toDate().hour}:${timestamp.toDate().minute} · ${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
                      : 'No date';

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
                                          title: const Text('Delete Announcement'),
                                          content: const Text('Are you sure you want to delete this announcement?'),
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () => Navigator.of(context).pop(),
                                            ),
                                            TextButton(
                                              child: const Text('Delete'),
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
                        Text(
                          data['text'] ?? '',
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Color(0XFF657786),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
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
                        backgroundImage:
                            AssetImage('assets/images/dr-sheshtawey.jpg'),
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
          )
        ],
      ),
    );
  }
}
