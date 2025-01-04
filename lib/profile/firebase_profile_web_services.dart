import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../firebase_auth.dart';


class FirebaseProfileWebServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authenticationWebServices;

  FirebaseProfileWebServices(this._authenticationWebServices);

  // Get the current user's ID from FirebaseAuth
  String? getCurrentUserId() {
    return _authenticationWebServices.getCurrentUser()?.uid;
  }

  // Get the current user's profile data from Firestore
  Future<Map<String, dynamic>> getCurrentUserProfileData() async {
    String? userId = getCurrentUserId();
    if (userId == null) {
      return {};
    }
    DocumentSnapshot doc = await _firestore.collection('students').doc(userId).get();
    return doc.data() as Map<String, dynamic>;
  }

  // Update the current user's profile data in Firestore
  Future<void> updateCurrentUserProfileData(Map<String, dynamic> data) async {
    String? userId = getCurrentUserId();
    if (userId == null) {
      return;
    }
    await _firestore.collection('students').doc(userId).update(data);
  }

  // pick an image from the gallery
  Future<File?> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
          source:
          ImageSource.camera); // Changed to gallery for broader use case
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

// New method to upload image and update user's imageUrl
  Future<bool> uploadImageAndUpdateUser(File imageFile) async {
    String? userId = getCurrentUserId();
    if (userId == null) return false;
    try {
      // Upload image to Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
      FirebaseStorage.instance.ref().child('user_images/$userId/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      // Update user's imageUrl in Firestore
      await _firestore.collection('users').doc(userId).update({
        'imageUrl': imageUrl,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
  Future<bool?> uploadFileAndUpdateUser(FilePickerResult cvPdf) async {
    String? userId = getCurrentUserId();
    if (userId == null) return false;
    try {
      // Ensure the file name retains the .pdf extension
      String fileName =
          "${DateTime.now().millisecondsSinceEpoch.toString()}.pdf";
      Reference ref = FirebaseStorage.instance.ref().child('CVs/$fileName');
      UploadTask uploadTask;
      // Check if running on web
      if (kIsWeb) {
        // Use bytes for uploading if on web
        final bytes = cvPdf.files.first.bytes;
        if (bytes == null) throw Exception("File bytes are null");
        uploadTask = ref.putData(
            bytes, SettableMetadata(contentType: 'application/pdf'));
      } else {
        // Use the file path for uploading if not on web
        File file = File(cvPdf.files.single.path!);
        uploadTask =
            ref.putFile(file, SettableMetadata(contentType: 'application/pdf'));
      }
      final snapshot = await uploadTask.whenComplete(() {
        // Perform any actions after the file is uploaded
      });
      final cvUrl = await snapshot.ref.getDownloadURL();
      await _firestore.collection('users').doc(userId).update({
        'cvUrl': cvUrl,
      });
      // Update the user's document with the CV URL
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> openPdf(String url) async {
    if (await canLaunchUrl(url as Uri)) {
      await launchUrl(url as Uri);
    } else {
      print('Could not launch $url');
    }
  }


  // Delete the current user's profile data from Firestore
  Future<void> deleteCurrentUserProfileData() async {
    String? userId = getCurrentUserId();
    if (userId == null) {
      return;
    }
    await _firestore.collection('students').doc(userId).delete();
  }

  // Delete the current user's profile image from Firebase Storage
  Future<void> deleteCurrentUserProfileImage() async {
    String? userId = getCurrentUserId();
    if (userId == null) {
      return;
    }
    String fileName = 'profile_image_$userId';
    Reference ref = FirebaseStorage.instance.ref().child('profile_images/$fileName');
    await ref.delete();
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _authenticationWebServices.signOut();
  }
}