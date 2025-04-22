import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:graduation_project/services/excel_service.dart';

class ResultsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ExcelService _excelService = ExcelService();

  // Initialize student results profile
  Future<void> initializeStudentResults(String studentId, String department) async {
    try {
      // Check if current user has admin or IT role
      if (!await _hasPermission(['Admin', 'IT'])) {
        throw Exception('Permission denied: Only Admin and IT can initialize student profiles');
      }
      
      // Create basic results profile
      await _firestore.collection('results').doc(studentId).set({
        'studentId': studentId,
        'department': department,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
      });
    } catch (e) {
      debugPrint('Error initializing student results: $e');
      rethrow;
    }
  }
  
  // Update student department
  Future<void> updateStudentDepartment(String studentId, String department) async {
    try {
      // Check if current user has admin or IT role
      if (!await _hasPermission(['Admin', 'IT'])) {
        throw Exception('Permission denied: Only Admin and IT can update student department');
      }
      
      await _firestore.collection('results').doc(studentId).update({
        'department': department,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser?.uid,
      });
    } catch (e) {
      debugPrint('Error updating student department: $e');
      rethrow;
    }
  }
  
  // Check if student has results profile
  Future<bool> hasResultsProfile(String studentId) async {
    try {
      final doc = await _firestore.collection('results').doc(studentId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking if student has results profile: $e');
      return false;
    }
  }
  
  // Get student results for a specific semester
  Future<Map<String, dynamic>?> getStudentSemesterResults(String studentId, int semester) async {
    try {
      // Students can only view their own results
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Authentication required');
      }
      
      // Allow access if user is viewing their own results or has admin/IT role
      if (currentUser.uid != studentId && !await _hasPermission(['Admin', 'IT', 'Teacher'])) {
        throw Exception('Permission denied: Cannot view results for this student');
      }
      
      final resultsDoc = await _firestore
          .collection('results')
          .doc(studentId)
          .collection('semesters')
          .doc(semester.toString())
          .get();
      
      if (!resultsDoc.exists) {
        return null;
      }
      
      return resultsDoc.data();
    } catch (e) {
      debugPrint('Error getting student semester results: $e');
      rethrow;
    }
  }
  
  // Get student results for all semesters
  Future<List<Map<String, dynamic>>> getStudentAllResults(String studentId) async {
    try {
      // Students can only view their own results
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Authentication required');
      }
      
      // Allow access if user is viewing their own results or has admin/IT role
      if (currentUser.uid != studentId && !await _hasPermission(['Admin', 'IT', 'Teacher'])) {
        throw Exception('Permission denied: Cannot view results for this student');
      }
      
      final resultsSnapshot = await _firestore
          .collection('results')
          .doc(studentId)
          .collection('semesters')
          .orderBy('semesterNumber')
          .get();
      
      return resultsSnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      debugPrint('Error getting student all results: $e');
      return [];
    }
  }
  
  // Calculate GPA for a specific semester
  double calculateSemesterGPA(List<Map<String, dynamic>> subjects) {
    if (subjects.isEmpty) return 0.0;
    
    double totalPoints = 0.0;
    int totalCredits = 0;
    
    for (final subject in subjects) {
      final double points = subject['points'] ?? 0.0;
      final int credits = subject['credits'] ?? 3; // Default to 3 credits if not specified
      
      totalPoints += points * credits;
      totalCredits += credits;
    }
    
    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }
  
  // Calculate CGPA across all semesters
  double calculateCGPA(List<Map<String, dynamic>> allSemesters) {
    if (allSemesters.isEmpty) return 0.0;
    
    double totalPoints = 0.0;
    int totalCredits = 0;
    
    for (final semester in allSemesters) {
      final List<dynamic> subjects = semester['subjects'] ?? [];
      
      for (final subject in subjects) {
        final double points = subject['points'] ?? 0.0;
        final int credits = subject['credits'] ?? 3; // Default to 3 credits if not specified
        
        totalPoints += points * credits;
        totalCredits += credits;
      }
    }
    
    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }
  
  // Update a specific subject result for a student
  Future<void> updateSubjectResults(
    String studentId,
    int semester,
    String courseCode,
    Map<String, dynamic> scores, {
    String? grade,
    double? totalPoints,
  }) async {
    try {
      // Check if current user has permission to modify results
      if (!await _hasPermission(['Admin', 'IT', 'Teacher'])) {
        throw Exception('Permission denied: Cannot modify student results');
      }
      
      // Get current semester results
      final resultRef = _firestore
          .collection('results')
          .doc(studentId)
          .collection('semesters')
          .doc(semester.toString());
      
      final resultsDoc = await resultRef.get();
      
      if (!resultsDoc.exists) {
        // Create new semester document if it doesn't exist
        final studentDoc = await _firestore.collection('users').doc(studentId).get();
        final department = studentDoc.data()?['department'] ?? 'General';
        
        await resultRef.set({
          'semesterNumber': semester,
          'department': department,
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastUpdatedBy': _auth.currentUser?.uid,
          'lastUpdatedByRole': await _getCurrentUserRole(),
          'subjects': [],
        });
      }
      
      // Calculate total points if not provided
      if (totalPoints == null) {
        totalPoints = 0.0;
        
        // Add up all score components with their maximums
        double week5 = _getSafeDouble(scores, 'week5', 8.0);
        double week10 = _getSafeDouble(scores, 'week10', 12.0);
        double coursework = _getSafeDouble(scores, 'coursework', 10.0);
        double lab = _getSafeDouble(scores, 'lab', 10.0);
        double finalExam = _getSafeDouble(scores, 'finalExam', 60.0);
        
        totalPoints = week5 + week10 + coursework + lab + finalExam;
        
        // Ensure total points don't exceed 100
        if (totalPoints > 100.0) {
          totalPoints = 100.0;
        }
      }
      
      // Calculate grade if not provided
      if (grade == null) {
        grade = _calculateGradeFromPoints(totalPoints);
      }
      
      // Get GPA points from grade
      final double points = _calculatePoints(grade);
      
      // Update the subject in the list
      final transaction = await _firestore.runTransaction((transaction) async {
        final currentDoc = await transaction.get(resultRef);
        
        if (!currentDoc.exists) {
          throw Exception('Results document not found');
        }
        
        List<dynamic> subjects = List.from(currentDoc.data()?['subjects'] ?? []);
        
        // Find if the subject already exists
        int subjectIndex = subjects.indexWhere(
            (s) => s['code'] == courseCode
        );
        
        final updatedSubject = {
          'code': courseCode,
          'name': await _getCourseNameFromCode(courseCode),
          'grade': grade,
          'points': points,
          'totalPoints': totalPoints,
          'scores': scores,
        };
        
        if (subjectIndex != -1) {
          // Update existing subject
          subjects[subjectIndex] = updatedSubject;
        } else {
          // Add new subject
          subjects.add(updatedSubject);
        }
        
        // Update the document
        transaction.update(resultRef, {
          'subjects': subjects,
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastUpdatedBy': _auth.currentUser?.uid,
          'lastUpdatedByRole': await _getCurrentUserRole(),
        });
        
        return subjects;
      });
      
      debugPrint('Updated subject results for student $studentId');
    } catch (e) {
      debugPrint('Error updating subject results: $e');
      rethrow;
    }
  }
  
  // Batch assign results to multiple students from Excel file
  Future<Map<String, dynamic>> batchAssignResults(PlatformFile file, int semester) async {
    try {
      if (!await _hasPermission(['Admin', 'IT'])) {
        throw Exception('Permission denied: Only Admin and IT can batch assign results');
      }
      
      // Process the Excel file
      final excelData = await _excelService.processExcelFile(file);
      
      // Assign results to students
      final int successCount = await _excelService.assignResultsFromExcel(excelData, semester);
      
      return {
        'success': true,
        'studentsProcessed': successCount,
        'totalStudents': excelData.length,
      };
    } catch (e) {
      debugPrint('Error batch assigning results: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Export student results as CSV
  Future<String> exportResultsAsCSV(String studentId, int? semester) async {
    try {
      // Check permissions
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Authentication required');
      }
      
      if (currentUser.uid != studentId && !await _hasPermission(['Admin', 'IT', 'Teacher'])) {
        throw Exception('Permission denied: Cannot export results for this student');
      }
      
      List<Map<String, dynamic>> resultsData = [];
      
      if (semester != null) {
        // Export single semester
        final semesterResults = await getStudentSemesterResults(studentId, semester);
        if (semesterResults != null) {
          resultsData = [semesterResults];
        }
      } else {
        // Export all semesters
        resultsData = await getStudentAllResults(studentId);
      }
      
      if (resultsData.isEmpty) {
        throw Exception('No results found for this student');
      }
      
      // Build CSV content
      final StringBuffer csv = StringBuffer();
      
      // Add header
      csv.writeln('Student ID,Semester,Course Code,Course Name,Week 5(8),Week 10(12),Classwork(10),Lab Exam(10),Final Exam(60),Total Points,Grade,GPA');
      
      // Get student information
      final studentDoc = await _firestore.collection('users').doc(studentId).get();
      final studentIdNumber = studentDoc.data()?['id'] ?? 'Unknown';
      
      // Add rows
      for (final semesterData in resultsData) {
        final int semesterNumber = semesterData['semesterNumber'] ?? 0;
        final List<dynamic> subjects = semesterData['subjects'] ?? [];
        
        for (final subject in subjects) {
          final String courseCode = subject['code'] ?? 'Unknown';
          final String courseName = subject['name'] ?? 'Unknown';
          final String grade = subject['grade'] ?? 'N/A';
          final double points = subject['points'] ?? 0.0;
          final double totalPoints = subject['totalPoints'] ?? 0.0;
          
          // Get individual scores
          final Map<String, dynamic> scores = subject['scores'] ?? {};
          final double week5 = scores['week5'] ?? 0.0;
          final double week10 = scores['week10'] ?? 0.0;
          final double classwork = scores['classwork'] ?? 0.0;
          final double labExam = scores['labExam'] ?? 0.0;
          final double finalExam = scores['finalExam'] ?? 0.0;
          
          // Add row to CSV
          csv.writeln(
              '$studentIdNumber,$semesterNumber,$courseCode,$courseName,$week5,$week10,$classwork,$labExam,$finalExam,$totalPoints,$grade,$points'
          );
        }
      }
      
      return csv.toString();
    } catch (e) {
      debugPrint('Error exporting results as CSV: $e');
      rethrow;
    }
  }
  
  // Import results from CSV
  Future<Map<String, dynamic>> importResultsFromCSV(String csvData, int semester) async {
    try {
      if (!await _hasPermission(['Admin', 'IT'])) {
        throw Exception('Permission denied: Only Admin and IT can import results');
      }
      
      final lines = csvData.split('\n');
      if (lines.isEmpty) {
        throw Exception('CSV file is empty');
      }
      
      // Skip header
      final dataLines = lines.sublist(1);
      
      int successCount = 0;
      final Map<String, List<Map<String, dynamic>>> studentSubjects = {};
      
      // Parse CSV rows
      for (final line in dataLines) {
        if (line.trim().isEmpty) continue;
        
        final parts = line.split(',');
        if (parts.length < 12) continue; // Skip incomplete lines
        
        final String studentIdNumber = parts[0].trim();
        final String courseCode = parts[2].trim();
        final String courseName = parts[3].trim();
        final double week5 = double.tryParse(parts[4]) ?? 0.0;
        final double week10 = double.tryParse(parts[5]) ?? 0.0;
        final double classwork = double.tryParse(parts[6]) ?? 0.0;
        final double labExam = double.tryParse(parts[7]) ?? 0.0;
        final double finalExam = double.tryParse(parts[8]) ?? 0.0;
        final double totalPoints = double.tryParse(parts[9]) ?? 0.0;
        final String grade = parts[10].trim();
        
        // Get Firestore ID for the student
        final String? firestoreId = await _getFirestoreIdFromStudentId(studentIdNumber);
        if (firestoreId == null) continue;
        
        // Group by student
        if (!studentSubjects.containsKey(firestoreId)) {
          studentSubjects[firestoreId] = [];
        }
        
        studentSubjects[firestoreId]!.add({
          'code': courseCode,
          'name': courseName,
          'grade': grade,
          'points': _calculatePoints(grade),
          'totalPoints': totalPoints,
          'scores': {
            'week5': week5,
            'maxWeek5': 8.0,
            'week10': week10,
            'maxWeek10': 12.0,
            'classwork': classwork,
            'maxClasswork': 10.0,
            'labExam': labExam,
            'maxLabExam': 10.0,
            'finalExam': finalExam,
            'maxFinalExam': 60.0,
          },
        });
      }
      
      // Batch update
      final batch = _firestore.batch();
      
      for (final studentId in studentSubjects.keys) {
        final subjects = studentSubjects[studentId]!;
        final resultRef = _firestore
            .collection('results')
            .doc(studentId)
            .collection('semesters')
            .doc(semester.toString());
        
        // Get student department
        final studentDoc = await _firestore.collection('users').doc(studentId).get();
        final department = studentDoc.data()?['department'] ?? 'General';
        
        batch.set(resultRef, {
          'semesterNumber': semester,
          'department': department,
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastUpdatedBy': _auth.currentUser?.uid,
          'lastUpdatedByRole': await _getCurrentUserRole(),
          'subjects': subjects,
        });
        
        successCount++;
      }
      
      await batch.commit();
      
      return {
        'success': true,
        'studentsProcessed': successCount,
        'totalEntries': dataLines.length,
      };
    } catch (e) {
      debugPrint('Error importing results from CSV: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Helper method to get current user role
  Future<String> _getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return 'Unknown';
    
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.data()?['role'] ?? 'Unknown';
  }
  
  // Helper method to check if current user has required permission
  Future<bool> _hasPermission(List<String> allowedRoles) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final String? role = userDoc.data()?['role'];
    
    return role != null && allowedRoles.contains(role);
  }
  
  // Helper method to get Firestore ID from student ID
  Future<String?> _getFirestoreIdFromStudentId(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('id', isEqualTo: studentId)
          .where('role', isEqualTo: 'Student')
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      
      return querySnapshot.docs.first.id;
    } catch (e) {
      debugPrint('Error getting Firestore ID for student: $e');
      return null;
    }
  }
  
  // Helper method to get course name from course code
  Future<String> _getCourseNameFromCode(String courseCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('courses')
          .where('code', isEqualTo: courseCode)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return courseCode; // Return code as name if not found
      }
      
      return querySnapshot.docs.first.data()['name'] ?? courseCode;
    } catch (e) {
      debugPrint('Error getting course name: $e');
      return courseCode;
    }
  }
  
  // Helper method to calculate grade from points
  String _calculateGradeFromPoints(double points) {
    // Total points are typically out of 100
    if (points >= 95) return 'A+';
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
  
  // Helper method to calculate GPA points from grade
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
  
  // Check if current user can modify results
  Future<bool> canModifyResults() async {
    return _hasPermission(['Admin', 'IT', 'Teacher']);
  }
  
  // Get department subjects
  Future<List<Map<String, dynamic>>> getDepartmentSubjects(String department) async {
    try {
      final querySnapshot = await _firestore
          .collection('departments')
          .doc(department)
          .collection('subjects')
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      debugPrint('Error getting department subjects: $e');
      return [];
    }
  }
  
  // Update subject results with named parameters
  Future<void> updateStudentSubjectResults({
    required String userId,
    required String semesterId,
    required int subjectIndex,
    required Map<String, dynamic> updatedSubject,
  }) async {
    try {
      // Check if current user has permission to modify results
      if (!await _hasPermission(['Admin', 'IT', 'Teacher'])) {
        throw Exception('Permission denied: Cannot modify student results');
      }
      
      final resultRef = _firestore
          .collection('results')
          .doc(userId)
          .collection('semesters')
          .doc(semesterId);
      
      final resultsDoc = await resultRef.get();
      
      if (!resultsDoc.exists) {
        throw Exception('Semester results not found');
      }
      
      List<dynamic> subjects = List.from(resultsDoc.data()?['subjects'] ?? []);
      
      if (subjectIndex < 0 || subjectIndex >= subjects.length) {
        throw Exception('Subject index out of bounds');
      }
      
      // Update the subject
      subjects[subjectIndex] = updatedSubject;
      
      // Update the document
      await resultRef.update({
        'subjects': subjects,
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastUpdatedBy': _auth.currentUser?.uid,
        'lastUpdatedByRole': await _getCurrentUserRole(),
      });
    } catch (e) {
      debugPrint('Error updating subject results: $e');
      rethrow;
    }
  }
  
  // Get student subjects for a specific semester
  Future<List<Map<String, dynamic>>> getStudentSubjects(
    String userId,
    String semesterId,
  ) async {
    try {
      final resultsDoc = await _firestore
          .collection('results')
          .doc(userId)
          .collection('semesters')
          .doc(semesterId)
          .get();
      
      if (!resultsDoc.exists) {
        return [];
      }
      
      final List<dynamic> subjects = resultsDoc.data()?['subjects'] ?? [];
      return subjects.map((subject) => Map<String, dynamic>.from(subject)).toList();
    } catch (e) {
      debugPrint('Error getting student subjects: $e');
      return [];
    }
  }
  
  // Get semester results
  Future<Map<String, dynamic>?> getSemesterResults(
    String userId,
    String semesterId,
  ) async {
    try {
      final resultsDoc = await _firestore
          .collection('results')
          .doc(userId)
          .collection('semesters')
          .doc(semesterId)
          .get(GetOptions(source: Source.server)); // Force server request, skip cache
      
      if (!resultsDoc.exists) {
        return null;
      }
      
      return resultsDoc.data();
    } catch (e) {
      debugPrint('Error getting semester results: $e');
      return null;
    }
  }
  
  // Process and assign results from Excel file
  Future<int> processAndAssignResultsFromExcel(
    PlatformFile file,
    int semester,
  ) async {
    try {
      if (!await _hasPermission(['Admin', 'IT'])) {
        throw Exception('Permission denied: Only Admin and IT can batch assign results');
      }
      
      // Process the Excel file
      final excelData = await _excelService.processExcelFile(file);
      
      // Assign results to students
      final int successCount = await _excelService.assignResultsFromExcel(excelData, semester);
      
      return successCount;
    } catch (e) {
      debugPrint('Error processing and assigning results from Excel: $e');
      rethrow;
    }
  }
  
  // Update student subjects
  Future<void> updateStudentSubjects({
    required String userId,
    required String semesterId,
    required List<String> selectedSubjectCodes,
  }) async {
    try {
      // Check if current user has permission to modify results
      if (!await _hasPermission(['Admin', 'IT', 'Teacher'])) {
        throw Exception('Permission denied: Cannot modify student subjects');
      }
      
      // Get all available subjects for the department
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final department = userDoc.data()?['department'] ?? 'General';
      
      final allSubjects = await getDepartmentSubjects(department);
      
      // Filter subjects based on selected codes
      final selectedSubjects = allSubjects
          .where((subject) => selectedSubjectCodes.contains(subject['code']))
          .map((subject) => {
            "code": subject["code"],
            "name": subject["name"],
            "credits": subject["credits"] ?? 4,
            "grade": "F",
            "points": 0.0,
            "scores": {
              "week5": 0.0,
              "week10": 0.0,
              "classwork": subject["hasCoursework"] ? 0.0 : null,
              "labExam": subject["hasLab"] ? 0.0 : null,
              "finalExam": 0.0,
            },
          })
          .toList();
      
      // Update the semester document
      final resultRef = _firestore
          .collection('results')
          .doc(userId)
          .collection('semesters')
          .doc(semesterId);
      
      final resultsDoc = await resultRef.get();
      
      if (resultsDoc.exists) {
        // Update existing document
        await resultRef.update({
          'subjects': selectedSubjects,
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastUpdatedBy': _auth.currentUser?.uid,
          'lastUpdatedByRole': await _getCurrentUserRole(),
        });
      } else {
        // Create new document
        await resultRef.set({
          'semesterNumber': int.parse(semesterId),
          'department': department,
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastUpdatedBy': _auth.currentUser?.uid,
          'lastUpdatedByRole': await _getCurrentUserRole(),
          'subjects': selectedSubjects,
        });
      }
    } catch (e) {
      debugPrint('Error updating student subjects: $e');
      rethrow;
    }
  }
  
  // Add a new subject to a department
  Future<void> addDepartmentSubject(
    String department,
    Map<String, dynamic> subjectData,
  ) async {
    try {
      // Check if current user has permission
      if (!await _hasPermission(['Admin', 'IT'])) {
        throw Exception('Permission denied: Only Admin and IT can add department subjects');
      }
      
      // Add subject to department collection
      await _firestore
          .collection('departments')
          .doc(department)
          .collection('subjects')
          .doc(subjectData['code'])
          .set({
            ...subjectData,
            'createdAt': FieldValue.serverTimestamp(),
            'createdBy': _auth.currentUser?.uid,
          });
    } catch (e) {
      debugPrint('Error adding department subject: $e');
      rethrow;
    }
  }
  
  // Delete a subject from a department
  Future<void> deleteDepartmentSubject(
    String department,
    String subjectCode,
  ) async {
    try {
      // Check if current user has permission
      if (!await _hasPermission(['Admin', 'IT'])) {
        throw Exception('Permission denied: Only Admin and IT can delete department subjects');
      }
      
      // Delete subject from department collection
      await _firestore
          .collection('departments')
          .doc(department)
          .collection('subjects')
          .doc(subjectCode)
          .delete();
    } catch (e) {
      debugPrint('Error deleting department subject: $e');
      rethrow;
    }
  }
  
  // Get semester template
  Future<List<Map<String, dynamic>>> getSemesterTemplate(
    String department,
    int semester,
  ) async {
    try {
      final templateDoc = await _firestore
          .collection('departments')
          .doc(department)
          .collection('templates')
          .doc(semester.toString())
          .get();
      
      if (!templateDoc.exists) {
        return [];
      }
      
      final List<dynamic> subjects = templateDoc.data()?['subjects'] ?? [];
      return subjects.map((subject) => Map<String, dynamic>.from(subject)).toList();
    } catch (e) {
      debugPrint('Error getting semester template: $e');
      return [];
    }
  }
  
  // Save semester template
  Future<void> saveSemesterTemplate(
    String department,
    int semester,
    List<Map<String, dynamic>> subjects,
  ) async {
    try {
      // Check if current user has permission
      if (!await _hasPermission(['Admin', 'IT'])) {
        throw Exception('Permission denied: Only Admin and IT can save semester templates');
      }
      
      // Save template to department collection
      await _firestore
          .collection('departments')
          .doc(department)
          .collection('templates')
          .doc(semester.toString())
          .set({
            'semester': semester,
            'department': department,
            'subjects': subjects,
            'updatedAt': FieldValue.serverTimestamp(),
            'updatedBy': _auth.currentUser?.uid,
          });
    } catch (e) {
      debugPrint('Error saving semester template: $e');
      rethrow;
    }
  }
  
  // Helper method to safely get a double value with a maximum
  double _getSafeDouble(Map<String, dynamic> map, String key, double maxValue) {
    final dynamic value = map[key];
    if (value == null) return 0.0;
    
    double doubleValue;
    if (value is int) {
      doubleValue = value.toDouble();
    } else if (value is double) {
      doubleValue = value;
    } else {
      return 0.0;
    }
    
    return doubleValue > maxValue ? maxValue : doubleValue;
  }

  Future<List<Map<String, dynamic>>> _getDepartmentSubjects(String department) async {
    final subjects = await getDepartmentSubjects(department);
    return subjects.map((subject) {
      return {
        "code": subject["code"],
        "name": subject["name"],
        "credits": subject["credits"] ?? 4,
        "grade": "F",
        "points": 0.0,
        "scores": {
          "week5": 0.0,
          "week10": 0.0,
          "classwork": subject["hasCoursework"] ? 0.0 : null,
          "labExam": subject["hasLab"] ? 0.0 : null,
          "finalExam": 0.0,
        },
      };
    }).toList();
  }
}
