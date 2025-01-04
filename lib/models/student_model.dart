import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Student {
  final String id;
  final List <String> name;
  final String email;
  final String password;
  final String academicYear;
  final DateTime enrolledDate;
  final DateTime birthDate;
  final String? phone;
  final String department;
  final bool feesStatus;
  final bool passStatus;
  final String address;
  final String nationality;
  final String? imageUrl ;
  final String? tuitionFeesURL ;
  final String gender = 'Male';


  Student({
    this.imageUrl,
    this.tuitionFeesURL,
    this.phone,
    required this.academicYear,
    required this.enrolledDate,
    required this.birthDate,
    required this.department,
    required this.feesStatus,
    required this.passStatus,
    required this.nationality,
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.address,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: List<String>.from(data['name'])??['',''],
      email: data['email']??'',
      password: data['password']??'',
      academicYear: data['academicYear']??'',
      enrolledDate: data['enrolledDate'].toDate()??DateTime.now(),
      birthDate: data['birthDate'].toDate()??DateTime.now(),
      phone: data['phone']??'',
      department: data['department']??'',
      feesStatus: data['feesStatus']??'',
      passStatus: data['passStatus']??'',
      address: data['address']??'',
      nationality: data['national']??'',
      imageUrl: data['imageUrl']??'',
      tuitionFeesURL: data['tuitionFeesURL']??'',
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'academicYear': academicYear,
      'enrolledDate': enrolledDate,
      'birthDate': birthDate,
      'phone': phone??'',
      'department': department,
      'feesStatus': feesStatus,
      'passStatus': passStatus,
      'address': address,
      'national': nationality,
      'imageUrl': imageUrl??'',
      'tuitionFeesURL': tuitionFeesURL??'',
    };
  }
}