import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/models/app_user.dart'; // Assuming AppUser model exists here

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<AppUser?> getCurrentAppUser() async {
    final User? firebaseUser = getCurrentUser();
    if (firebaseUser == null || firebaseUser.email == null) {
      return null;
    }

    try {
      final QuerySnapshot userDocs = await _firestore
          .collection('users')
          .where('email', isEqualTo: firebaseUser.email)
          .limit(1) // Optimization: only need one document
          .get();

      if (userDocs.docs.isNotEmpty) {
        final userData = userDocs.docs.first.data() as Map<String, dynamic>; 
        // Assuming AppUser has a factory constructor fromMap
        return AppUser.fromMap(userData, userDocs.docs.first.id); 
      } else {
        // Handle case where user exists in Auth but not in Firestore users collection
        print('Warning: User ${firebaseUser.email} found in Auth but not in Firestore users collection.');
        return null;
      }
    } catch (e) {
      print('Error fetching user data from Firestore: $e');
      // Consider throwing a custom exception or returning null based on error handling strategy
      return null;
    }
  }

  // Add other auth-related methods if needed (login, logout, register)
} 