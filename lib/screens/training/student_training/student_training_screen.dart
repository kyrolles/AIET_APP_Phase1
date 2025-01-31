import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/constants.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class StudentTrainingScreen extends StatelessWidget {
  const StudentTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Student Training',
        onpressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              CircularPercentIndicator(
                animation: true,
                animationDuration: 1000,
                radius: 100,
                lineWidth: 20,
                percent: 0.25, // 15/60
                progressColor: kPrimaryColor,
                backgroundColor: Colors.blue.shade50,
                circularStrokeCap: CircularStrokeCap.round,
                center: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(fontSize: 33, color: Colors.blueGrey),
                    ),
                    Text('15 of 60',
                        style: TextStyle(fontSize: 32)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(
                  color: kLightGrey, indent: 10, endIndent: 10, height: 10),
              ServiceItem(
                title: 'Announcement',
                imageUrl: 'assets/project_image/loudspeaker.png',
                backgroundColor: const Color.fromRGBO(41, 128, 185, 1),
                onPressed: () => _showDepartmentBottomSheet(context),
              ),
              ServiceItem(
                title: 'Submit Training',
                imageUrl: 'assets/project_image/submit-training.png',
                backgroundColor: const Color.fromRGBO(41, 128, 185, 1),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDepartmentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
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
            children: _buildDepartmentButtons(context),
          ),
        );
      },
    );
  }

  List<Widget> _buildDepartmentButtons(BuildContext context) {
    final departments = [
      ('CE', 'Computer', 'assets/project_image/CE.jpeg', Colors.black, 1.0),
      ('EME', 'Mechatronics', 'assets/project_image/EME.png', Colors.white, 1.0),
      ('ECE', 'Communication & Electronics', 'assets/project_image/ECE.jpeg', Colors.black, 0.5),
      ('IE', 'Industrial', 'assets/project_image/IE.jpeg', Colors.white, 0.8),
    ];

    return [
      const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Department',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0XFF6C7072),
            ),
          ),
        ],
      ),
      ...departments.map((dept) => KButton(
        onPressed: () => Navigator.pushNamed(
          context,
          '/departmentTraining',
          arguments: dept.$2,
        ),
        text: dept.$1,
        fontSize: 34,
        textColor: dept.$4,
        borderWidth: 1,
        borderColor: Colors.black,
        backgroundImage: DecorationImage(
          image: AssetImage(dept.$3),
          fit: BoxFit.cover,
          opacity: dept.$5,
        ),
      )),
    ];
  }
}
