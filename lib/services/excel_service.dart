import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class ExcelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if current user has permission to modify results
  Future<bool> hasResultsModificationPermission() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final String? role = userDoc.data()?['role'];
    
    // Only Admin and IT can modify results
    return role == 'Admin' || role == 'IT';
  }

  // Pick Excel file from device
  Future<PlatformFile?> pickExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return result.files.single;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking Excel file: $e');
      return null;
    }
  }

  // Upload Excel file to Firebase Storage
  Future<String?> uploadExcelFile(PlatformFile file) async {
    try {
      if (!await hasResultsModificationPermission()) {
        throw Exception('Permission denied: Only Admin and IT can upload results files');
      }

      final path = file.path;
      if (path == null) return null;

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final ref = _storage.ref().child('results_uploads/$fileName');
      
      final uploadTask = ref.putFile(File(path));
      final snapshot = await uploadTask.whenComplete(() => null);
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading Excel file: $e');
      rethrow;
    }
  }

  // Process Excel file and extract student results
  Future<Map<String, dynamic>> processExcelFile(PlatformFile file) async {
    try {
      if (!await hasResultsModificationPermission()) {
        throw Exception('Permission denied: Only Admin and IT can process results files');
      }

      final path = file.path;
      if (path == null) {
        throw Exception('Invalid file path');
      }

      final bytes = File(path).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      
      final sheet = excel.tables.keys.first;
      final results = <String, dynamic>{};
      
      // Expected columns in the Excel sheet based on the format
      const int studentIdColumn = 0;       // Student ID
      const int studentNameColumn = 1;     // Student Name
      const int courseCodeColumn = 2;      // Course Code
      const int week5Column = 3;           // 5th-week (out of 8)
      const int week10Column = 4;          // 10th-week (out of 12)
      const int classworkColumn = 5;       // Classwork (out of 10)
      const int labExamColumn = 6;         // Lab Exam (out of 10)
      const int finalExamColumn = 7;       // Final Exam (out of 60)
      const int totalPointsColumn = 8;     // Total Points
      
      // Maximum points for each assessment component
      const double maxWeek5Points = 8.0;
      const double maxWeek10Points = 12.0;
      const double maxClassworkPoints = 10.0;
      const double maxLabExamPoints = 10.0;
      const double maxFinalExamPoints = 60.0;
      const double maxTotalPoints = 100.0; // Total should be 100
      
      // Skip header row, start from row 1
      bool hasHeaderRow = true;
      int startRowIndex = hasHeaderRow ? 1 : 0;
      
      // Process each row of the Excel sheet
      for (int i = startRowIndex; i < excel.tables[sheet]!.maxRows; i++) {
        final List<Data?> row = excel.tables[sheet]!.rows[i];
        if (row.isEmpty || row[studentIdColumn] == null) continue;
        
        final String studentId = row[studentIdColumn]!.value.toString().trim();
        if (studentId.isEmpty) continue;
        
        final String? studentName = row[studentNameColumn]?.value?.toString();
        final String? courseCode = row[courseCodeColumn]?.value?.toString();
        
        // Skip if course information is missing
        if (courseCode == null || courseCode.isEmpty) continue;
        
        // Get scores
        final double week5Score = _parseDoubleValue(row[week5Column]);
        final double week10Score = _parseDoubleValue(row[week10Column]);
        final double classworkScore = _parseDoubleValue(row[classworkColumn]);
        final double labExamScore = _parseDoubleValue(row[labExamColumn]);
        final double finalExamScore = _parseDoubleValue(row[finalExamColumn]);
        
        // Calculate total points or use provided total if available
        double totalPoints;
        if (row.length > totalPointsColumn && row[totalPointsColumn] != null) {
          totalPoints = _parseDoubleValue(row[totalPointsColumn]);
        } else {
          totalPoints = week5Score + week10Score + classworkScore + labExamScore + finalExamScore;
        }
        
        // Calculate grade based on total points
        final String grade = _calculateGradeFromPoints(totalPoints);
        
        // Store data by student ID
        if (!results.containsKey(studentId)) {
          results[studentId] = {
            'studentName': studentName,
            'subjects': <Map<String, dynamic>>[],
          };
        }
        
        // Add subject result for this student
        (results[studentId]['subjects'] as List).add({
          'code': courseCode,
          'name': courseCode, // Use code as name if actual name not available
          'grade': grade,
          'points': _calculatePoints(grade),
          'totalPoints': totalPoints,
          'scores': {
            'week5': week5Score,
            'maxWeek5': maxWeek5Points,
            'week10': week10Score,
            'maxWeek10': maxWeek10Points,
            'classwork': classworkScore,
            'maxClasswork': maxClassworkPoints,
            'labExam': labExamScore,
            'maxLabExam': maxLabExamPoints,
            'finalExam': finalExamScore,
            'maxFinalExam': maxFinalExamPoints,
          },
        });
      }
      
      return results;
    } catch (e) {
      debugPrint('Error processing Excel file: $e');
      rethrow;
    }
  }
  
  // Helper method to parse double values from Excel
  double _parseDoubleValue(Data? data) {
    if (data == null || data.value == null) return 0.0;
    
    if (data.value is double) {
      return data.value as double;
    } else if (data.value is int) {
      return (data.value as int).toDouble();
    } else {
      try {
        return double.parse(data.value.toString());
      } catch (e) {
        return 0.0;
      }
    }
  }
  
  // Calculate GPA points from grade
  double _calculatePoints(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+': return 4.0;
      case 'A': return 4.0;
      case 'A-': return 3.7;
      case 'B+': return 3.3;
      case 'B': return 3.0;
      case 'B-': return 2.7;
      case 'C+': return 2.3;
      case 'C': return 2.0;
      case 'C-': return 1.7;
      case 'D+': return 1.3;
      case 'D': return 1.0;
      default: return 0.0;
    }
  }
  
  // Helper method to calculate grade from points
  String _calculateGradeFromPoints(double points) {
    if (points >= 90) return 'A';
    if (points >= 85) return 'A-';
    if (points >= 80) return 'B+';
    if (points >= 75) return 'B';
    if (points >= 70) return 'B-';
    if (points >= 65) return 'C+';
    if (points >= 60) return 'C';
    if (points >= 55) return 'C-';
    if (points >= 50) return 'D+';
    if (points >= 45) return 'D';
    return 'F';
  }
  
  // Assign results from processed Excel data to students
  Future<int> assignResultsFromExcel(Map<String, dynamic> excelData, int semester) async {
    if (!await hasResultsModificationPermission()) {
      throw Exception('Permission denied: Only Admin and IT can assign results');
    }
    
    int successCount = 0;
    final batch = _firestore.batch();
    
    // Get the mapping of student IDs to Firestore IDs
    final studentIdMap = await _getStudentIdFirestoreMapping();
    
    for (final studentId in excelData.keys) {
      final firestoreId = studentIdMap[studentId];
      
      // Skip if we can't find matching Firestore ID
      if (firestoreId == null) continue;
      
      // Reference to student's semester results document
      final resultRef = _firestore
          .collection('results')
          .doc(firestoreId)
          .collection('semesters')
          .doc(semester.toString());
      
      // Get student information
      final studentDoc = await _firestore.collection('users').doc(firestoreId).get();
      final department = studentDoc.data()?['department'] ?? 'General';
      
      // Process subjects to ensure points and grades are correctly set
      final subjectList = List<Map<String, dynamic>>.from(excelData[studentId]['subjects']);
      
      // Ensure each subject has the correct grade based on totalPoints and proper field names
      for (var subject in subjectList) {
        // Get individual score components
        final scores = subject['scores'] as Map<String, dynamic>;
        
        // Rename any legacy field names to match the current schema
        if (scores.containsKey('coursework')) {
          scores['classwork'] = scores['coursework'];
          scores.remove('coursework');
        }
        
        if (scores.containsKey('lab')) {
          scores['labExam'] = scores['lab'];
          scores.remove('lab');
        }
        
        // Calculate the total points from individual score components
        double totalPoints = 0.0;
        totalPoints += scores['week5'] ?? 0.0;
        totalPoints += scores['week10'] ?? 0.0;
        totalPoints += scores['classwork'] ?? 0.0;
        totalPoints += scores['labExam'] ?? 0.0;
        totalPoints += scores['finalExam'] ?? 0.0;
        
        // If Excel provided a total, use that instead (if it's reasonable)
        if (subject['totalPoints'] != null && subject['totalPoints'] > 0.0) {
          totalPoints = subject['totalPoints'];
        }
        
        // Ensure totalPoints is a valid value
        totalPoints = totalPoints.clamp(0.0, 100.0);
        
        // Calculate grade from total points
        final String grade = _calculateGradeFromPoints(totalPoints);
        
        // Calculate points (GPA value) from grade
        final double points = _calculatePoints(grade);
        
        // Update the subject data with correctly calculated values
        subject['grade'] = grade;
        subject['points'] = points;
        subject['totalPoints'] = totalPoints;
        subject['credits'] = subject['credits'] ?? 4; // Default credits if not specified
      }
      
      // Set the document with the processed subjects
      batch.set(resultRef, {
        'semesterNumber': semester,
        'department': department,
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastUpdatedBy': _auth.currentUser?.uid,
        'subjects': subjectList,
      });
      
      successCount++;
    }
    
    await batch.commit();
    return successCount;
  }
  
  // Helper method to get mapping between student IDs and Firestore IDs
  Future<Map<String, String>> _getStudentIdFirestoreMapping() async {
    final Map<String, String> mapping = {};
    
    final usersSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'Student')
        .get();
    
    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      final id = data['id'];
      if (id != null && id.toString().isNotEmpty) {
        mapping[id.toString()] = doc.id;
      }
    }
    
    return mapping;
  }
  
  // Helper method to get current user role
  Future<String?> _getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.data()?['role'];
  }
} 