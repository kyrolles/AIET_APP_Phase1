import 'package:flutter/material.dart';
import 'package:graduation_project/components/my_app_bar.dart';

class DepartementTrainingScreen extends StatelessWidget {
  const DepartementTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Training',
        onpressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/trainingDetails');
            },
            child: const Text('Telecom Egypt'),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Alexandria Training Center'),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Egyption Petrochemicals Company'),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Egypt Experts for Software'),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Egyption Space Agency'),
          ),
        ],
      ),
    );
  }
}
