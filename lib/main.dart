import 'package:flutter/material.dart';
import 'package:graduation_project/screens/home_screen.dart';
import 'package:graduation_project/screens/login_screen.dart';
// import 'package:graduation_project/screens/map_screen.dart';
// import 'package:graduation_project/screens/services_screen.dart';
// import 'package:graduation_project/screens/splash_screen.dart';

void main() {
  runApp(const AIET());
}

class AIET extends StatelessWidget {
  const AIET({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, //screen color
        //////////// AppBarTheme() //////////////////////////////////////////////////////
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, //appbar color
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
