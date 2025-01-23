import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/components/list_container.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:graduation_project/components/student_container.dart';
import 'package:graduation_project/constants.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class StudentTrainingScreen extends StatelessWidget {
  StudentTrainingScreen({super.key});

  final List<Widget> uplodedfiles = [
    const StudentContainer(
        status: 'Done',
        statusColor: Colors.green,
        title: 'Telecom Egypt training.pdf',
        image: 'assets/project_image/pdf.png'),
    const StudentContainer(
        status: 'Reject',
        statusColor: Colors.red,
        title: 'EES.pdf',
        image: 'assets/project_image/pdf.png'),
    const StudentContainer(
        status: 'pending',
        statusColor: Colors.yellow,
        title: 'EPC.pdf',
        image: 'assets/project_image/pdf.png'),
    const StudentContainer(
        status: 'No status',
        statusColor: Colors.grey,
        title: 'EgSA.pdf',
        image: 'assets/project_image/pdf.png'),
  ];

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
            minHeight: MediaQuery.of(context).size.height, // Prevents shrinking
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
                percent: 0.25,
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
                    Text('15 of 60', style: TextStyle(fontSize: 32)),
                  ],
                ),
              ),
              SizedBox(
                height: 400,
                child: ListContainer(
                  title: 'Your Training',
                  listOfWidgets: uplodedfiles,
                  emptyMessage: 'Nothing',
                ),
              ),
              const Divider(
                  color: kLightGrey, indent: 10, endIndent: 10, height: 10),
              ServiceItem(
                title: 'Announcement',
                imageUrl: 'assets/project_image/loudspeaker.png',
                backgroundColor: const Color.fromRGBO(41, 128, 185, 1),
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
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
                            KButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/departmentTraining');
                              },
                              text: 'CE',
                              fontSize: 34,
                              textColor: Colors.black,
                              borderWidth: 1,
                              borderColor: Colors.black,
                              backgroundImage: const DecorationImage(
                                  image: AssetImage(
                                      'assets/project_image/CE.jpeg'),
                                  fit: BoxFit.cover),
                            ),
                            KButton(
                              onPressed: () {},
                              text: 'EME',
                              fontSize: 34,
                              textColor: Colors.white,
                              borderWidth: 1,
                              borderColor: Colors.black,
                              backgroundImage: const DecorationImage(
                                  image: AssetImage(
                                      'assets/project_image/EME.png'),
                                  fit: BoxFit.cover),
                            ),
                            KButton(
                              onPressed: () {},
                              text: 'ECE',
                              fontSize: 34,
                              textColor: Colors.black,
                              borderWidth: 1,
                              borderColor: Colors.black,
                              backgroundImage: const DecorationImage(
                                  image: AssetImage(
                                      'assets/project_image/ECE.jpeg'),
                                  fit: BoxFit.cover,
                                  opacity: 0.5),
                            ),
                            KButton(
                              onPressed: () {},
                              text: 'IE',
                              fontSize: 34,
                              textColor: Colors.white,
                              borderWidth: 1,
                              borderColor: Colors.black,
                              backgroundImage: const DecorationImage(
                                  image: AssetImage(
                                      'assets/project_image/IE.jpeg'),
                                  fit: BoxFit.cover,
                                  opacity: 0.8),
                            )
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
        ),
      ),
    );
  }
}
