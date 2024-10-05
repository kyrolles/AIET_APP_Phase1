import 'package:flutter/material.dart';
import 'package:graduation_project/screens/splash_screen.dart';

void main() {
  runApp(const AIET());
}

class AIET extends StatelessWidget {
  const AIET({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
