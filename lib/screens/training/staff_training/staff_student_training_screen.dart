import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/service_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StaffstudentTrainingScreen extends StatelessWidget {
  const StaffstudentTrainingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: MyAppBar(
        title: localizations?.staffStudentTraining ?? 'Staff-Student Training',
        onpressed: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.only(top: 15),
        children: [
          ServiceItem(
            title: localizations?.createAnnouncement ?? 'Create\nAnnouncement',
            imageUrl: 'assets/project_image/loudspeaker.png',
            backgroundColor: const Color.fromRGBO(41, 128, 185, 1),
            onPressed: () {
              Navigator.pushNamed(
                  context, '/staffStudentTraining/createAnnouncement');
            },
          ),
          ServiceItem(
            title: localizations?.validate ?? 'Validate',
            imageUrl: 'assets/project_image/validation.png',
            backgroundColor: const Color.fromRGBO(41, 128, 185, 1),
            onPressed: () {
              Navigator.pushNamed(context, '/staffStudentTraining/validate');
            },
          ),
        ],
      ),
    );
  }
}
