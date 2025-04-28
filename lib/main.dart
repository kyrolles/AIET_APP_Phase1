import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:graduation_project/screens/announcement/all_announcement_appear_on_one_screen.dart';
import 'package:graduation_project/screens/attendance/professor_attendance/attendance_archive.dart';
import 'package:graduation_project/screens/clinic/student_clinic/clinic_screen.dart';
import 'package:graduation_project/screens/clinic/student_clinic/new_appointment_screen.dart';
import 'package:graduation_project/screens/drawer/qr_code_screen.dart';
import 'package:graduation_project/screens/invoice/it_incoive/it_archive.dart';
import 'package:graduation_project/screens/training/staff_training/create_announcement.dart';
import 'package:graduation_project/screens/training/staff_training/archive_validate_screen.dart';
import 'package:graduation_project/screens/training/staff_training/staff_student_training_screen.dart';
import 'package:graduation_project/screens/training/staff_training/validate_screen.dart';
import 'package:graduation_project/screens/training/student_training/departement_training_screen.dart';
import 'package:graduation_project/screens/training/student_training/student_training_screen.dart';
import 'package:graduation_project/screens/training/student_training/trianing_details_screen.dart';
import 'package:graduation_project/screens/clinic/doctor_clinic/doctor_clinic_screen.dart';
import 'package:graduation_project/screens/clinic/doctor_clinic/completed_appointments_screen.dart';
import 'package:graduation_project/screens/clinic/doctor_clinic/pending_appointments_screen.dart';
import 'screens/invoice/student_invoice/invoice_archive_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_user_screen.dart';
import 'package:graduation_project/screens/attendance/attendance_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Define the background message handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, like Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp(); // Uncomment if needed

  print("Handling a background message: ${message.messageId}");
  print('Message data: ${message.data}');
  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }
  // TODO: Handle the background message (e.g., show a local notification)
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permission
  final PermissionStatus status = await Permission.notification.request();
  if (kDebugMode) {
    print('Notification permission status: $status');
  }

  // --- Foreground message handling ---
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
    }

    if (message.notification != null) {
      if (kDebugMode) {
        print('Message also contained a notification: ${message.notification}');
      }
      // TODO: Display the foreground notification using flutter_local_notifications
    }
  });

  // --- Handling notification tap ---
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped! Message data: ${message.data}');
    }
    // TODO: Navigate to relevant screen based on message data
  });

  // Check if the user is already logged in
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'token');

  runApp(
    ProviderScope(
      child: MyApp(
        isLoggedIn: token != null,
      ),
    ),
  );
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
      // home: SplashScreen(isUserLoggedIn: isLoggedIn),
      home: const HomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/createUser': (context) =>
            const CreateUserScreen(), // Add route for CreateUserScreen
        '/studentTraining': (context) => const StudentTrainingScreen(),
        '/staffStudentTraining': (context) =>
            const StaffstudentTrainingScreen(),
        '/staffStudentTraining/validate': (context) => const ValidateScreen(),
        '/staffStudentTraining/validate/archive': (context) =>
            const ArchiveValidateScreen(),
        '/departmentTraining': (context) => const DepartementTrainingScreen(),
        '/trainingDetails': (context) => const TrianingDetailsScreen(),
        '/attendance': (context) => const AttendanceRouter(),
        '/attendance/archive': (context) => const AttendanceArchive(),
        '/invoice/archive': (context) => const InvoiceArchiveScreen(),
        '/staffStudentTraining/createAnnouncement': (context) =>
            const CreateAnnouncement(),
        '/it_invoice/archive': (context) => const ItArchiveScreen(),
        '/id': (context) => const QrcodeScreen(),
        '/all_announcement': (context) =>
            const AllAnnouncementAppearOnOneScreen(),
        '/clinicStudentScreen': (context) => const ClinicScreen(),

        '/clinicStudentScreen/newAppointmentScreen': (context) =>
            const NewAppointmentScreen(),
        // Add these routes to your routes map
        '/doctorClinicScreen': (context) => const DoctorClinicScreen(),
        '/doctorClinicScreen/completedAppointmentsScreen': (context) =>
            const CompletedAppointmentsScreen(),
        '/doctorClinicScreen/pendingAppointmentsScreen': (context) =>
            const PendingAppointmentsScreen(),
      },
    );
  }
}
