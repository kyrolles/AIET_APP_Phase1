import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/screens/attendance/professor_attendance/attendance_archive.dart';
import 'package:graduation_project/screens/attendance/professor_attendance/attendance_screen.dart';
// import 'package:graduation_project/screens/attendance/attendance_archive.dart';
import 'package:graduation_project/screens/training/idk_where_put_it/create_announcement.dart';
import 'package:graduation_project/screens/training/staff_training/archive_validate_screen.dart';
import 'package:graduation_project/screens/training/staff_training/staff_student_training_screen.dart';
import 'package:graduation_project/screens/training/staff_training/validate_screen.dart';
import 'package:graduation_project/screens/training/student_training/departement_training_screen.dart';
import 'package:graduation_project/screens/training/student_training/student_training_screen.dart';
import 'package:graduation_project/screens/training/student_training/trianing_details_screen.dart';
import 'screens/invoice/student_invoice/invoice_archive_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_user_screen.dart'; // Import the CreateUserScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Check if the user is already logged in
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'token');

  runApp(MyApp(
    isLoggedIn: token != null,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
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
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/createUser': (context) =>
            const CreateUserScreen(), // Add route for CreateUserScreen
        '/studentTraining': (context) => const StudentTrainingScreen(),
        '/staffStudentTraining': (context) =>
            const StaffstudentTrainingScreen(),
        '/staffStudentTraining/validate': (context) => ValidateScreen(),
        '/staffStudentTraining/validate/archive': (context) =>
            ArchiveValidateScreen(),
        '/departmentTraining': (context) => const DepartementTrainingScreen(),
        '/trainingDetails': (context) => const TrianingDetailsScreen(),
        '/attendance': (context) => AttendanceScreen(),
        '/attendance/archive': (context) => const AttendanceArchive(),
        '/invoice/archive': (context) => const InvoiceArchiveScreen(),
        '/staffStudentTraining/createAnnouncement': (context) =>
            const CreateAnnouncement(),
      },
    );
  }
}
