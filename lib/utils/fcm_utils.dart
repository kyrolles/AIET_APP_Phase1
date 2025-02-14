import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FCMUtils {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static const _storage = FlutterSecureStorage();

  static Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        // Store token for later use
        await _storage.write(key: 'fcm_token', value: token);
      }
      return token;
    } catch (e) {
      print('Failed to get FCM token: $e');
      return null;
    }
  }
}
