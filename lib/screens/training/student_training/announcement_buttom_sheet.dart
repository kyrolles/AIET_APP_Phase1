import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';

class AnnouncementButtomSheet extends StatelessWidget {
  const AnnouncementButtomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Programs',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0XFF6C7072),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          _buildDepartmentButton(
            context: context,
            text: 'CE',
            department: 'Computer',
            imagePath: 'assets/project_image/CE.jpeg',
            textColor: Colors.black,
          ),
          const SizedBox(height: 12),
          _buildDepartmentButton(
            context: context,
            text: 'EME',
            department: 'Mechatronics',
            imagePath: 'assets/project_image/EME.png',
            textColor: Colors.white,
          ),
          const SizedBox(height: 12),
          _buildDepartmentButton(
            context: context,
            text: 'ECE',
            department: 'Communication & Electronics',
            imagePath: 'assets/project_image/ECE.jpeg',
            textColor: Colors.black,
            opacity: 0.5,
          ),
          const SizedBox(height: 12),
          _buildDepartmentButton(
            context: context,
            text: 'IE',
            department: 'Industrial',
            imagePath: 'assets/project_image/IE.jpeg',
            textColor: Colors.white,
            opacity: 0.8,
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentButton({
    required BuildContext context,
    required String text,
    required String department,
    required String imagePath,
    required Color textColor,
    double opacity = 1.0,
  }) {
    return KButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          '/departmentTraining',
          arguments: department,
        );
      },
      text: text,
      fontSize: 36,
      height: 70,
      textColor: textColor,
      borderWidth: 1,
      borderColor: Colors.black,
      backgroundImage: DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
        opacity: opacity,
      ),
    );
  }
}
