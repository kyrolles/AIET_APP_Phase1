import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/schedule_model.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current semester
  Future<Semester> getCurrentSemester() async {
    try {
      final QuerySnapshot semesterDoc = await _firestore
          .collection('semesters')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (semesterDoc.docs.isEmpty) {
        return await _getDefaultSemester();
      }

      final semesterId = semesterDoc.docs.first.id;
      final semesterData = semesterDoc.docs.first.data() as Map<String, dynamic>;
      
      final QuerySnapshot sessionsSnapshot = await _firestore
          .collection('semesters')
          .doc(semesterId)
          .collection('sessions')
          .get();
      
      final sessions = sessionsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ClassSession.fromJson(data);
      }).toList();
      
      return Semester(
        name: semesterData['name'] ?? '2nd Semester(2024-2025)',
        sessions: sessions,
      );
    } catch (e) {
      print('Error getting current semester: $e');
      return await _getDefaultSemester();
    }
  }

  // Get the student's class schedule based on their profile
  Future<ClassIdentifier?> getStudentClassIdentifier() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (userDoc.docs.isEmpty) return null;

      final userData = userDoc.docs.first.data();
      
      // Check if user has class information
      if (!userData.containsKey('academicYear') || 
          !userData.containsKey('department') ||
          !userData.containsKey('section')) {
        return null;
      }

      return ClassIdentifier(
        year: userData['academicYear'] ?? 0,
        department: Department.values.firstWhere(
          (d) => d.name == userData['department'],
          orElse: () => Department.G,
        ),
        section: userData['section'] ?? 1,
      );
    } catch (e) {
      print('Error getting student class identifier: $e');
      return null;
    }
  }

  // Default semester for testing or when no data is available
  Future<Semester> _getDefaultSemester() async {
    try {
      final String jsonData = await rootBundle.loadString('lib/data/schedule_data.json');
      final Map<String, dynamic> data = json.decode(jsonData);
      final semesterData = data['currentSemester'];
      
      final List<dynamic> sessionsJson = semesterData['sessions'] as List<dynamic>;
      
      final List<ClassSession> sessions = sessionsJson.map((sessionJson) {
        return ClassSession.fromJson(sessionJson);
      }).toList();
      
      return Semester(
        name: semesterData['name'],
        sessions: sessions,
      );
    } catch (e) {
      print('Error loading schedule data from JSON: $e');
      // Fallback to hardcoded data if JSON loading fails
      return Semester(
        name: '2nd Semester(2024-2025)',
        sessions: _getMockSessionsHardcoded(),
      );
    }
  }

  // Hardcoded fallback data in case JSON loading fails
  List<ClassSession> _getMockSessionsHardcoded() {
    final classId4C2 = ClassIdentifier(
      year: 4,
      department: Department.C,
      section: 2,
    );
    
    return [
      // Saturday sessions
      ClassSession(
        id: 's1',
        courseName: 'Expert System Application',
        courseCode: 'L-CE406',
        instructor: 'Dr. Hatem Mohamed Abdel Kader',
        location: 'LR2( B-4-05)',
        day: DayOfWeek.SATURDAY,
        periodNumber: 3,
        weekType: WeekType.ODD,
        classIdentifier: classId4C2,
      ),
      // Adding just one sample session for fallback
      // For complete data, the app will use the JSON file
    ];
  }

  // Organize students into sections by department with a maximum of 30 students per section
  Future<void> organizeStudentsIntoSections() async {
    try {
      // 1. Fetch all users from the users collection
      final QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .get();
      
      if (usersSnapshot.docs.isEmpty) {
        print('No students found to organize into sections');
        return;
      }
      
      // 2. Group users by department
      final Map<String, List<DocumentSnapshot>> usersByDepartment = {};
      
      for (final doc in usersSnapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;
        if (!userData.containsKey('department')) continue;
        
        final String department = userData['department'] ?? 'General';
        if (!usersByDepartment.containsKey(department)) {
          usersByDepartment[department] = [];
        }
        usersByDepartment[department]!.add(doc);
      }
      
      // 3. Process each department and create sections
      for (final department in usersByDepartment.keys) {
        // Sort students alphabetically by name
        usersByDepartment[department]!.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          
          // Use name field if available, otherwise construct from firstName and lastName
          final String aName = aData['name'] ?? 
              '${aData['firstName'] ?? ''} ${aData['lastName'] ?? ''}';
          final String bName = bData['name'] ?? 
              '${bData['firstName'] ?? ''} ${bData['lastName'] ?? ''}';
              
          return aName.compareTo(bName);
        });
        
        // Calculate how many sections we need
        final int studentCount = usersByDepartment[department]!.length;
        final int sectionCount = (studentCount / 30).ceil();
        
        // Create section batches for this department
        for (int sectionNumber = 1; sectionNumber <= sectionCount; sectionNumber++) {
          final int startIndex = (sectionNumber - 1) * 30;
          final int endIndex = startIndex + 30 > studentCount ? studentCount : startIndex + 30;
          
          // Get students for this section
          final sectionStudents = usersByDepartment[department]!.sublist(startIndex, endIndex);
          
          // Create a section document
          final sectionRef = _firestore
              .collection('sections')
              .doc(department)
              .collection('sectionsList')
              .doc('section_$sectionNumber');
          
          // Create a map of student data to store in the section
          final List<Map<String, dynamic>> studentsData = sectionStudents.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'name': data['name'] ?? '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}',
              'email': data['email'] ?? '',
              'academicYear': data['academicYear'] ?? 0,
              'department': data['department'] ?? '',
              'section': sectionNumber,
            };
          }).toList();
          
          // Save the section data
          await sectionRef.set({
            'sectionNumber': sectionNumber,
            'department': department,
            'studentCount': sectionStudents.length,
            'students': studentsData,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
          // Update each student's document with their assigned section
          for (final studentDoc in sectionStudents) {
            await _firestore.collection('users').doc(studentDoc.id).update({
              'section': sectionNumber
            });
          }
        }
      }
      
      print('Successfully organized students into sections');
    } catch (e) {
      print('Error organizing students into sections: $e');
      throw e; // Rethrow to handle in the UI
    }
  }
} 