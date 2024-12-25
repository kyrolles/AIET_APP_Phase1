import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/screens/invoice_screen.dart';
import 'package:graduation_project/screens/calculator_screen.dart';
import 'package:graduation_project/screens/it_invoice_screen.dart';
import 'package:graduation_project/screens/login_screen.dart';
import 'package:graduation_project/screens/qrCode_screen.dart';
import 'package:graduation_project/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
      home: const QrcodeScreen(),
    );
  }
}
