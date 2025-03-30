import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/screens/announcement/all_announcement_appear_on_one_screen.dart';
import 'package:graduation_project/screens/attendance/professor_attendance/attendance_archive.dart';
import 'package:graduation_project/screens/clinic/student_clinic/clinic_screen.dart';
import 'package:graduation_project/screens/clinic/student_clinic/new_appointment_screen.dart';
import 'package:graduation_project/screens/drawer/qr_code_screen.dart';
import 'package:graduation_project/screens/invoice/it_incoive/it_archive.dart';
import 'package:graduation_project/screens/splash_screen.dart';
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
import 'package:graduation_project/services/firebase_storage_service.dart';
import 'package:graduation_project/utils/firebase_diagnostics.dart';
import 'package:graduation_project/utils/pdf_migration_utils.dart';
import 'screens/invoice/student_invoice/invoice_archive_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_user_screen.dart';
import 'package:graduation_project/screens/attendance/attendance_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Check if the user is already logged in
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'token');
  
  // Run comprehensive Firebase diagnostics 
  debugPrint('Running Firebase diagnostics...');
  final diagnosticResults = await FirebaseDiagnostics.runDiagnostics();
  debugPrint('Diagnostic results: $diagnosticResults');
  
  // Test Firebase Storage access
  await testFirebaseStorage();
  
  // Repair missing file_url fields in Firestore documents
  await FirebaseDiagnostics.repairMissingFileUrlFields();
  
  // Log document statistics
  await FirebaseDiagnostics.countDocumentsByFieldStatus();
  
  // Check if migration has been run before
  final migrationRun = await storage.read(key: 'pdf_migration_complete');
  
  if (migrationRun != 'true' && token != null) {
    // Run migration in the background
    _runPdfMigration(storage);
  }

  runApp(MyApp(
    isLoggedIn: token != null,
  ));
}

/// Test Firebase Storage setup
Future<void> testFirebaseStorage() async {
  try {
    final storageService = FirebaseStorageService();
    final isAccessible = await storageService.testStorageAccess();
    
    debugPrint(isAccessible 
        ? '✅ Firebase Storage setup successful!' 
        : '❌ Firebase Storage test failed. Please check your configuration.');
  } catch (e) {
    debugPrint('❌ Error testing Firebase Storage: $e');
  }
}

/// Run PDF migration in background
Future<void> _runPdfMigration(FlutterSecureStorage storage) async {
  try {
    // Run migration
    await PdfMigrationUtils.migrateAllRequestPdfs();
    
    // Mark migration as complete
    await storage.write(key: 'pdf_migration_complete', value: 'true');
    
    debugPrint('PDF migration completed successfully');
  } catch (e) {
    debugPrint('Error during PDF migration: $e');
    // We don't mark migration as complete if it fails, 
    // so it will try again on next app start
  }
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
      home: SplashScreen(isUserLoggedIn: isLoggedIn),
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
        '/doctorClinicScreen/completedAppointmentsScreen': (context) => const CompletedAppointmentsScreen(),
        '/doctorClinicScreen/pendingAppointmentsScreen': (context) => const PendingAppointmentsScreen(),
      },
    );
  }
}
