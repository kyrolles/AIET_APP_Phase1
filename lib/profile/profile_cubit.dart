import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/models/student_model.dart';
import 'package:graduation_project/profile/firebase_profile_web_services.dart';
import 'package:url_launcher/url_launcher.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseProfileWebServices _firebaseProfileWebServices;

  ProfileCubit(this._firebaseProfileWebServices) : super(ProfileInitial());

Future<Student> getUserProfileData() async {
    emit(ProfileLoading());
    try {
      final Student user = Student.fromFirestore(
          (await _firebaseProfileWebServices
              .getCurrentUserProfileData()) as DocumentSnapshot<Object?>);
      if (user != null) {
        emit(UserLoaded(user));
        return user;
      } else {
        emit(ProfileError('User not found'));
        return Student(id: '',
            name: [''],
            email: '',
            password: '',
            academicYear: '',
            enrolledDate: DateTime.now(),
            birthDate: DateTime.now(),
            department: '',
            feesStatus: false,
            passStatus: false,
            address: '',
            imageUrl: '',
            tuitionFeesURL: '',
            nationality: '');
      }
    }
    catch (e) {
      emit(ProfileError(e.toString()));
      return Student(id: '',
          name: [''],
          email: '',
          password: '',
          academicYear: '',
          enrolledDate: DateTime.now(),
          birthDate: DateTime.now(),
          department: '',
          feesStatus: false,
          passStatus: false,
          address: '',
          imageUrl: '',
          tuitionFeesURL: '',
          nationality: '');
    }
  }



  Future<void> pickImage() async {
    emit(ProfileLoading());
    try {
      final image = await _firebaseProfileWebServices.pickImage();
      if (image != null) {
        final success =
        await _firebaseProfileWebServices.uploadImageAndUpdateUser(image);
        if (success == true) {
          final user = await _firebaseProfileWebServices
              .getCurrentUserProfileData();
          if (user != null) {
            emit(UserLoaded(user as Student));
          }
          else {
            emit(ProfileError('User not found'));
          }
        } else {
          emit(ProfileError('Failed to upload image'));
          await Future.delayed(Duration(seconds: 5));
          final user = await _firebaseProfileWebServices
              .getCurrentUserProfileData();
          if (user != null) {
            emit(UserLoaded(user as Student));
          }
        }
      }
      else {
        emit(ProfileError('No image selected'));
        await Future.delayed(Duration(seconds: 5));
        final user = await _firebaseProfileWebServices
            .getCurrentUserProfileData();
        if (user != null) {
          emit(UserLoaded(user as Student));
        }
      }
    }
    catch (e) {
      emit(ProfileError(e.toString()));
    }

      }


  Future<void> uploadfeesAndUpdateUser(FilePickerResult fees) async {
    emit(ProfileLoading());
    try {
      final success = await _firebaseProfileWebServices.uploadFileAndUpdateUser(fees);
    if (success == null) {
      final user = await _firebaseProfileWebServices.getCurrentUserProfileData();
      if (user != null) {
        emit(UserLoaded(user as Student));
      } else {
        emit(ProfileError('User not found'));
      }
    }
    else {
      emit(ProfileError('Failed to upload fees'));

      }
    }
     catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
  Future<void> openFeesURL(String url) async {
    emit(ProfileLoading());

      if (await canLaunchUrl(url as Uri)) {
        await launchUrl(url as Uri);
        final user = await _firebaseProfileWebServices
            .getCurrentUserProfileData();
        if (user != null) {
          emit(UserLoaded(user as Student));
        }
      }
      else {
        emit(ProfileError('Failed to open URL'));
      }
  }

}
