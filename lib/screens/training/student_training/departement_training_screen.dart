import 'package:flutter/material.dart';
import 'package:graduation_project/components/announcement_card_training.dart';
import 'package:graduation_project/components/my_app_bar.dart';

class DepartementTrainingScreen extends StatelessWidget {
  const DepartementTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Training Announcement',
        onpressed: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            spacing: 20,
            children: [
              AnnouncementCard(
                imageUrl: 'assets/project_image/We_logo.svg.png',
                title: 'Telecom Egypt',
                onPressed: () {
                  Navigator.pushNamed(context, '/trainingDetails');
                },
              ),
              AnnouncementCard(
                imageUrl: 'assets/project_image/EES.png',
                title: 'Egypt Experts for Software',
                onPressed: () {
                  Navigator.pushNamed(context, '/trainingDetails');
                },
              ),
              AnnouncementCard(
                imageUrl: 'assets/project_image/Alextrainingcenter.jpeg',
                title: 'Alexandria Training Center',
                onPressed: () {
                  Navigator.pushNamed(context, '/trainingDetails');
                },
              ),
              AnnouncementCard(
                imageUrl: 'assets/project_image/EPC.png',
                title: 'Egyption Petrochemicals Company',
                onPressed: () {
                  Navigator.pushNamed(context, '/trainingDetails');
                },
              ),
              AnnouncementCard(
                imageUrl: 'assets/project_image/EgsaLogo.png',
                title: 'Egyption Space Agency',
                onPressed: () {
                  Navigator.pushNamed(context, '/trainingDetails');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
