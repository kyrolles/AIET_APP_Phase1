import 'dart:io'; // Add for Platform check
import 'dart:async'; // Add for StreamController and StreamSubscription
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/language_clases/language_constants.dart';
import 'package:graduation_project/simple_bloc_observer.dart';
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
import 'screens/invoice/student_invoice/invoice_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_user_screen.dart';
import 'package:graduation_project/screens/attendance/attendance_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/services/training_notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:graduation_project/services/notification_service.dart';
import 'package:graduation_project/services/auth_service.dart';

// Initialize FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Channel ID for Android notifications
const String channelId = 'high_importance_channel';
const String channelName = 'High Importance Notifications';
const String channelDescription =
    'This channel is used for important notifications.';

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
  Map<String, dynamic>? data,
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

  // Use the data map to construct a more specific payload if present
  String notificationPayload = payload ?? '';
  if (data != null && data['type'] != null) {
    notificationPayload = data['type'];
  }

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    title,
    body,
    platformDetails,
    payload: notificationPayload,
  );

  if (kDebugMode) {
    print('Local notification displayed: $title - $body');
    print('Notification payload: $notificationPayload');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //adding bloc observer to observe cubits
  Bloc.observer = SimpleBlocObserver();

  // Initialize flutter_local_notifications
  await _initializeLocalNotifications();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize the notification service for robust FCM token management
  final notificationService = NotificationService();
  await notificationService.initialize();

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
      print(
          'User notification permission status: ${settings.authorizationStatus}');
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
        print(
            '  • Notification Android Channel ID: ${message.notification!.android?.channelId}');
      }
    }

    // Process training notifications with dedicated handler
    if (message.data['type'] == 'training') {
      TrainingNotificationService().processNotification(message.data);
    }

    // Display the notification using flutter_local_notifications
    if (message.notification != null) {
      showLocalNotification(
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? 'You have a new notification',
        data: message.data,
        payload: message.data['type'] ?? 'notification',
      );
    }
  });

  // --- Handling notification tap ---
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped! Message data: ${message.data}');
    }

    // Process training notifications with dedicated handler for tap events
    if (message.data['type'] == 'training') {
      TrainingNotificationService().handleNotificationTap(message.data);
      // Navigate to the student training screen
      NotificationNavigationService.navigateTo('/studentTraining');
    } else if (message.data['type'] == 'invoice') {
      // Navigate to the invoice screen to see approved requests
      NotificationNavigationService.navigateTo('/invoice');
    } else if (message.data['type'] == 'announcement') {
      NotificationNavigationService.navigateTo('/all_announcement');
    }
  });

  // Handle initial notification if app was terminated
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    if (kDebugMode) {
      print(
          'App opened from terminated state by notification: ${initialMessage.data}');
    }
    // We'll handle this in the MyApp widget to ensure navigation is possible
  }

  // Check if the user is already logged in using AuthService
  final authService = AuthService();
  bool isLoggedIn = await authService.isLoggedIn();

  runApp(
    ProviderScope(
      child: MyApp(
        isLoggedIn: isLoggedIn,
        initialMessage: initialMessage,
      ),
    ),
  );
}

// Singleton service to handle notification navigation
class NotificationNavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final StreamController<String> _navigationStreamController =
      StreamController<String>.broadcast();

  static Stream<String> get navigationStream =>
      _navigationStreamController.stream;

  static void navigateTo(String route) {
    _navigationStreamController.add(route);
  }

  static void dispose() {
    _navigationStreamController.close();
  }
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

      // Extract payload to determine navigation
      final String payload = response.payload ?? '';
      if (payload.contains('training')) {
        // Use dedicated handler for training notifications
        if (response.payload != null) {
          try {
            final Map<String, dynamic> data =
                jsonDecode(response.payload!) as Map<String, dynamic>;
            TrainingNotificationService().handleNotificationTap(data);
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing notification payload: $e');
            }
          }
        }
        NotificationNavigationService.navigateTo('/studentTraining');
      } else if (payload.contains('invoice')) {
        NotificationNavigationService.navigateTo('/invoice');
      } else if (payload.contains('announcement')) {
        NotificationNavigationService.navigateTo('/all_announcement');
      }
    },
  );

  // Create the notification channel for Android
  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
            channelId, channelName,
            description: channelDescription,
            importance: Importance.max,
            enableLights: true));
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

    // Save FCM token to user document if logged in
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && fcmToken != null) {
      try {
        // First, find user by email
        final userRef = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (userRef.docs.isNotEmpty) {
          final userData = userRef.docs.first.data();
          // Save token directly to the user document
          await userRef.docs.first.reference.update({
            'fcm_token': fcmToken,
          });

          if (kDebugMode) {
            print(
                'FCM token saved to user document with ID: ${userRef.docs.first.id}');
            print('User data: $userData');
          }

          // For debugging - verify this is the correct user
          if (userData.containsKey('id')) {
            if (kDebugMode) {
              print('User ID in Firestore: ${userData['id']}');
            }
          } else {
            if (kDebugMode) {
              print('Warning: User document does not have an id field');
            }
            // Add id field if missing
            await userRef.docs.first.reference
                .update({'id': userRef.docs.first.id});
            if (kDebugMode) {
              print('Added id field to user document');
            }
          }

          // Also save to a separate collection for easier debugging
          await FirebaseFirestore.instance
              .collection('user_tokens')
              .doc(userRef.docs.first.id)
              .set({
            'token': fcmToken,
            'email': currentUser.email,
            'user_id': userData['id'] ?? userRef.docs.first.id,
            'updated_at': FieldValue.serverTimestamp()
          });

          if (kDebugMode) {
            print('FCM token also saved to user_tokens collection');
          }

          // Subscribe user to specific topics based on department and year
          await _subscribeToAnnouncementTopics(userData);
        } else {
          if (kDebugMode) {
            print('No user document found for email: ${currentUser.email}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error saving FCM token to user document: $e');
        }
      }
    }

    // Listen for token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print('FCM Token refreshed: $newToken');
      }

      // Update the token in the user's document
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && newToken != null) {
        try {
          FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: currentUser.email)
              .limit(1)
              .get()
              .then((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              final userData = snapshot.docs.first.data();
              // Update FCM token in user document
              snapshot.docs.first.reference.update({
                'fcm_token': newToken,
              });

              // Also update in user_tokens collection
              FirebaseFirestore.instance
                  .collection('user_tokens')
                  .doc(snapshot.docs.first.id)
                  .set({
                'token': newToken,
                'email': currentUser.email,
                'user_id': userData['id'] ?? snapshot.docs.first.id,
                'updated_at': FieldValue.serverTimestamp()
              });

              if (kDebugMode) {
                print(
                    'FCM token updated in user document and user_tokens collection');
              }

              // Resubscribe user to topics on token refresh
              _subscribeToAnnouncementTopics(userData);
            }
          });
        } catch (e) {
          if (kDebugMode) {
            print('Error updating FCM token in user document: $e');
          }
        }
      }
    });

    // Subscribe to announcements topic
    await FirebaseMessaging.instance.subscribeToTopic('announcements');
    if (kDebugMode) {
      print('Successfully subscribed to announcements topic');
    }

    // Request notification permissions on iOS (redundant but kept for backward compatibility)
    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
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

// Function to subscribe user to appropriate announcement topics based on their department and year
Future<void> _subscribeToAnnouncementTopics(
    Map<String, dynamic> userData) async {
  try {
    // Extract department and year from user data
    final String? department = userData['department'];
    final String? year = userData['year'];
    final List<String> topicsToSubscribe = [];

    // Subscribe to global announcements (already done in _setupFCM)
    // topicsToSubscribe.add('announcements');

    // Subscribe to department-specific topic if available
    if (department != null && department.isNotEmpty) {
      final String deptTopic =
          'announcement_${department.replaceAll(' ', '_')}';
      topicsToSubscribe.add(deptTopic);

      // If year is available, also subscribe to department+year combination
      if (year != null && year.isNotEmpty) {
        final String deptYearTopic =
            'announcement_${department.replaceAll(' ', '_')}_${year.replaceAll(' ', '_')}';
        topicsToSubscribe.add(deptYearTopic);
      }
    }

    // Subscribe to year-specific topic if available
    if (year != null && year.isNotEmpty) {
      final String yearTopic = 'announcement_${year.replaceAll(' ', '_')}';
      topicsToSubscribe.add(yearTopic);
    }

    // Subscribe to all relevant topics
    for (final topic in topicsToSubscribe) {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    }

    if (kDebugMode) {
      print(
          'User subscribed to ${topicsToSubscribe.length} announcement topics');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error subscribing to announcement topics: $e');
    }
  }
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final RemoteMessage? initialMessage;

  const MyApp({super.key, required this.isLoggedIn, this.initialMessage});

  @override
  State<MyApp> createState() => _MyAppState();
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }

  late StreamSubscription<String> _navigationSubscription;

  @override
  void initState() {
    super.initState();

    // Listen to notification navigation events
    _navigationSubscription =
        NotificationNavigationService.navigationStream.listen((route) {
      if (mounted) {
        Navigator.of(context).pushNamed(route);
      }
    });
  }

  @override
  void dispose() {
    _navigationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationNavigationService.navigatorKey,
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

      // Set the localization delegates
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Set the locale based on the user's preference
      locale: _locale,

      debugShowCheckedModeBanner: false,
      // home: SplashScreen(isUserLoggedIn: isLoggedIn),
      home: Builder(
        builder: (context) {
          // Handle initial message after MaterialApp is built
          if (widget.initialMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (widget.initialMessage!.data['type'] == 'invoice') {
                Navigator.pushNamed(context, '/invoice');
              } else if (widget.initialMessage!.data['type'] ==
                  'announcement') {
                Navigator.pushNamed(context, '/all_announcement');
              } else if (widget.initialMessage!.data['type'] == 'training') {
                Navigator.pushNamed(context, '/studentTraining');
              }
            });
          }
          return widget.isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),
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
        // '/all_announcement': (context) =>
        //     const AllAnnouncementAppearOnOneScreen(),
        '/clinicStudentScreen': (context) => const ClinicScreen(),
        '/clinicStudentScreen/newAppointmentScreen': (context) =>
            const NewAppointmentScreen(),
        // Add these routes to your routes map
        '/doctorClinicScreen': (context) => const DoctorClinicScreen(),
        '/doctorClinicScreen/completedAppointmentsScreen': (context) =>
            const CompletedAppointmentsScreen(),
        '/doctorClinicScreen/pendingAppointmentsScreen': (context) =>
            const PendingAppointmentsScreen(),
        '/invoice': (context) => const InvoiceScreen(),
      },
    );
  }
}
