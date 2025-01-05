import 'package:flutter/material.dart';

import '../../../components/my_app_bar.dart';

class TrianingDetailsScreen extends StatelessWidget {
  const TrianingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Training',
        onpressed: () => Navigator.pop(context),
      ),
      body: const Center(
        child: Text('Training Details Screen'),
      ),
    );
  }
}
