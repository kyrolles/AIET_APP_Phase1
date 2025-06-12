import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AnnouncementButtomSheet extends StatelessWidget {
  const AnnouncementButtomSheet({super.key});
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              localizations?.programs ?? 'Programs',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0XFF6C7072),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          KButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/departmentTraining',
                arguments: 'Computer',
              );
            },
            text: localizations?.ce ?? 'CE',
            fontSize: 36,
            height: 70,
            textColor: Colors.black,
            borderWidth: 1,
            borderColor: Colors.black,
            backgroundImage: const DecorationImage(
              image: AssetImage('assets/project_image/CE.jpeg'),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
          KButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/departmentTraining',
                arguments: 'Mechatronics',
              );
            },
            text: localizations?.eme ?? 'EME',
            fontSize: 36,
            height: 70,
            textColor: Colors.white,
            borderWidth: 1,
            borderColor: Colors.black,
            backgroundImage: const DecorationImage(
              image: AssetImage('assets/project_image/EME.png'),
              fit: BoxFit.cover,
              opacity: 0.8,
            ),
          ),
          KButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/departmentTraining',
                arguments: 'Communication & Electronics',
              );
            },
            text: localizations?.ece ?? 'ECE',
            fontSize: 36,
            height: 70,
            textColor: Colors.black,
            borderWidth: 1,
            borderColor: Colors.black,
            backgroundImage: const DecorationImage(
              image: AssetImage('assets/project_image/ECE.jpeg'),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
          KButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/departmentTraining',
                arguments: 'Industrial',
              );
            },
            text: localizations?.ie ?? 'IE',
            fontSize: 36,
            height: 70,
            textColor: Colors.white,
            borderWidth: 1,
            borderColor: Colors.black,
            backgroundImage: const DecorationImage(
              image: AssetImage('assets/project_image/IE.jpeg'),
              fit: BoxFit.cover,
              opacity: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
