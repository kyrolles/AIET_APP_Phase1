import 'dart:io'; // Add for Platform check
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Initialize FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();

// Channel ID for Android notifications
const String channelId = 'high_importance_channel';
const String channelName = 'High Importance Notifications';
const String channelDescription = 'This channel is used for important notifications.';

// Define the background message handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, like Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  }
}

// Show local notification
Future<void> showLocalNotification({
  required String title,
  required String body,
  String? payload,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );
  
  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );
  
  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    title,
    body,
    platformDetails,
    payload: payload,
  );
  
  if (kDebugMode) {
    print('Local notification displayed: $title - $body');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize flutter_local_notifications
  await _initializeLocalNotifications();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permission with more detailed settings and logging
  try {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: true,
      carPlay: false,
      criticalAlert: false,
    );
    
    if (kDebugMode) {
      print('User notification permission status: ${settings.authorizationStatus}');
      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          print('User granted permission: AUTHORIZED');
          break;
        case AuthorizationStatus.provisional:
          print('User granted provisional permission');
          break;
        case AuthorizationStatus.denied:
          print('User denied permission - notifications will not work');
          break;
        case AuthorizationStatus.notDetermined:
          print('Permission not determined yet');
          break;
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error requesting notification permission: $e');
    }
  }

  // Get FCM token and subscribe to announcements topic
  await _setupFCM();

  // --- Foreground message handling with improved debugging ---
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('📩 FOREGROUND MESSAGE RECEIVED:');
      print('  • Message ID: ${message.messageId}');
      print('  • Data: ${message.data}');
      
      if (message.notification != null) {
        print('  • Notification Title: ${message.notification!.title}');
        print('  • Notification Body: ${message.notification!.body}');
        print('  • Notification Android Channel ID: ${message.notification!.android?.channelId}');
      }
    }

    // Display the notification using flutter_local_notifications
    if (message.notification != null) {
      showLocalNotification(
        title: message.notification!.title ?? 'New Announcement',
        body: message.notification!.body ?? 'Check out the new announcement!',
        payload: 'announcement',
      );
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

// Initialize local notifications
Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');
      
  final DarwinInitializationSettings initializationSettingsIOS = 
      DarwinInitializationSettings(
    requestAlertPermission: false, // We'll handle permissions with FCM
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap
      if (kDebugMode) {
        print('Notification tapped: ${response.payload}');
      }
      // TODO: Navigate to relevant screen based on payload
    },
  );

  // Create the notification channel for Android
  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.max,
        ));
  }
}

// Enhanced FCM setup function for better debugging
Future<void> _setupFCM() async {
  try {
    // Get FCM token
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (kDebugMode) {
      print('FCM Token: $fcmToken');
    }
    
    // Listen for token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print('FCM Token refreshed: $newToken');
      }
    });
    
    // Subscribe to announcements topic
    await FirebaseMessaging.instance.subscribeToTopic('announcements');
    if (kDebugMode) {
      print('Successfully subscribed to announcements topic');
    }
    
    // Request notification permissions on iOS (redundant but kept for backward compatibility)
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (kDebugMode) {
        print('iOS foreground notification options set');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error setting up FCM: $e');
    }
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
