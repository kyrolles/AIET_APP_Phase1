import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_item.dart';

class StudentTrainingScreen extends StatelessWidget {
  const StudentTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Student Training',
        onpressed: () => Navigator.pop(context),
      ),
      body: ListView(
        children: [
          ServiceItem(
            title: 'Announcement',
            imageUrl: 'assets/project_image/loudspeaker.png',
            backgroundColor: const Color.fromRGBO(41, 128, 185, 1),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Department',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0XFF6C7072)),
                              ),
                            ]),
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, '/departmentTraining');
                            },
                            child: const Text('CE')),
                        TextButton(onPressed: () {}, child: const Text('EME')),
                        TextButton(onPressed: () {}, child: const Text('ECE')),
                        TextButton(onPressed: () {}, child: const Text('IE')),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          ServiceItem(
            title: 'Submit Training',
            imageUrl: 'assets/project_image/submit-training.png',
            backgroundColor: const Color.fromRGBO(41, 128, 185, 1),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
