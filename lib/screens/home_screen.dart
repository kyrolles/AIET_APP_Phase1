import 'package:flutter/material.dart';
import 'package:graduation_project/components/activities_list_view.dart';
import 'package:graduation_project/components/text_link.dart';
import 'package:graduation_project/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        title: const Row(
          children: [
            Spacer(), // This pushes the content to the center from the start
            Text(
              'Hi, Youssef!',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 27),
            ),
            SizedBox(
                width:
                    8), // Adds a small space between the Text and CircleAvatar
            CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/1704502172296.jfif'),
            ),
            Spacer(
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
                            AssetImage('assets/images/1704502172296.jfif'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Text(
                          'DR.Mohamed',
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
