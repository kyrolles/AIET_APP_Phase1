import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    // First check Firebase Auth
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // If no current user, clear any stored token and return false
      await _storage.delete(key: 'token');
      return false;
    }
    
    // User is logged in with Firebase Auth
    return true;
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save user token in secure storage
      await _storage.write(key: 'token', value: userCredential.user?.uid);
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.delete(key: 'token');
  }
} 