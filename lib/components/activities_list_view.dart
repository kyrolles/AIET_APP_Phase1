import 'package:flutter/material.dart';
import 'package:graduation_project/components/activities_container.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/map_screen.dart';
import 'package:graduation_project/screens/result_screen.dart';
import 'package:graduation_project/screens/services_screen.dart';

class ActivitiesListView extends StatelessWidget {
  const ActivitiesListView({super.key});

  @override
  Widget build(BuildContext context) {
    List<ActivitiesContainer> activities = [
      ActivitiesContainer(
        image: 'assets/project_image/result.png',
        title: 'Result',
        onpressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const ResultPage();
              },
            ),
          );
        },
      ),
      ActivitiesContainer(
        image: 'assets/project_image/customer-service.png',
        title: 'Services',
        onpressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const ServicesScreen();
              },
            ),
          );
        },
      ),
      ActivitiesContainer(
        image: 'assets/project_image/project.png',
        title: 'Map',
        onpressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const MapScreen();
              },
            ),
          );
        },
      ),
      ActivitiesContainer(
        image: 'assets/project_image/attendance.png',
        title: 'Attendance',
        onpressed: () {},
      ),
      ActivitiesContainer(
        image: 'assets/project_image/loudspeaker.png',
        title: 'Announce',
        onpressed: () {},
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        boxShadow: kShadow,
      ),
      margin: const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0),
      // padding: const EdgeInsets.all(12.0),
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: activities.length,
        itemBuilder: (context, index) {
          return activities[index];
        },
      ),
    );
  }
}
