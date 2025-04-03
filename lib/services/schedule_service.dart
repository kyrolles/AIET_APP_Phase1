import 'package:cloud_firestore/cloud_firestore.dart' 
    show 
      FirebaseFirestore, 
      QuerySnapshot, 
      DocumentSnapshot, 
      FieldValue, 
      WriteBatch, 
      SetOptions, 
      GetOptions, 
      Source;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Cache keys
  static const String _cacheKeySemester = 'cached_semester';
  static const String _cacheKeyLastRefresh = 'last_refresh_time';
  static const String _cacheKeyRefreshCount = 'refresh_count_today';
  static const String _cacheKeyRefreshDay = 'refresh_count_day';
  static const String _cacheKeySelectedSemesterId = 'selected_semester_id';
  
  // Refresh limits
  static const int _maxRefreshCount = 3;
  static const Duration _refreshCooldown = Duration(minutes: 15);

  // Get the current semester
  Future<Semester> getCurrentSemester({bool forceRefresh = false}) async {
    try {
      // Check refresh limits if force refresh is requested
      if (forceRefresh) {
        final canRefresh = await _checkRefreshLimits();
        if (!canRefresh) {
          // If we hit refresh limits, use cached data instead
          final cachedSemester = await _getCachedSemester();
          if (cachedSemester != null) {
            return cachedSemester;
          }
          // If no cache, proceed with fetch but don't count it as a refresh
          forceRefresh = false;
        }
      }
      
      // Try to get cached data first if not forcing refresh
      if (!forceRefresh) {
        final cachedSemester = await _getCachedSemester();
        if (cachedSemester != null) {
          return cachedSemester;
        }
      }

      // Check if user has a selected semester ID in preferences
      final String? selectedSemesterId = await _getSelectedSemesterId();
      String semesterId;
      
      if (selectedSemesterId != null && selectedSemesterId.isNotEmpty) {
        // Use the selected semester ID
        semesterId = selectedSemesterId;
        
        // Verify the semester exists
        final semesterExists = await _checkSemesterExists(semesterId);
        if (!semesterExists) {
          // If not, fall back to active semester
          semesterId = await _getOrCreateActiveSemester(forceRefresh: forceRefresh);
        }
      } else {
        // Get or create active semester
        semesterId = await _getOrCreateActiveSemester(forceRefresh: forceRefresh);
      }
      
      if (semesterId.isEmpty) {
        return await _getDefaultSemester();
      }

      // Get semester data with optional cache control
      final semesterDoc = await _firestore
          .collection('semesters')
          .doc(semesterId)
          .get(forceRefresh 
              ? GetOptions(source: Source.server) 
              : GetOptions(source: Source.serverAndCache));
          
      if (!semesterDoc.exists) {
        return await _getDefaultSemester();
      }
      
      final semesterData = semesterDoc.data() as Map<String, dynamic>;
      semesterData['id'] = semesterDoc.id; // Include the document ID
      
      // Get all sessions for this semester with optional cache control
      final QuerySnapshot sessionsSnapshot = await _firestore
          .collection('semesters')
          .doc(semesterId)
          .collection('sessions')
          .get(forceRefresh 
              ? GetOptions(source: Source.server) 
              : GetOptions(source: Source.serverAndCache));
      
      final sessions = sessionsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ClassSession.fromJson(data);
      }).toList();
      
      final semester = Semester.fromJson({
        ...semesterData,
        'sessions': sessions.map((s) => s.toJson()).toList(),
      });
      
      // Cache the semester data
      if (forceRefresh) {
        await _incrementRefreshCount();
      }
      await _cacheSemester(semester);
      
      return semester;
    } catch (e) {
      print('Error getting current semester: $e');
      
      // Try to get cached data on error
      final cachedSemester = await _getCachedSemester();
      if (cachedSemester != null) {
        return cachedSemester;
      }
      
      return await _getDefaultSemester();
    }
  }

  // Cache the semester data locally
  Future<void> _cacheSemester(Semester semester) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert semester to JSON
      final Map<String, dynamic> semesterMap = {
        'name': semester.name,
        'sessions': semester.sessions.map((session) => session.toJson()).toList(),
      };
      
      // Save to SharedPreferences
      await prefs.setString(_cacheKeySemester, jsonEncode(semesterMap));
      await prefs.setInt(_cacheKeyLastRefresh, DateTime.now().millisecondsSinceEpoch);
      
      print('Semester data cached successfully');
    } catch (e) {
      print('Error caching semester data: $e');
    }
  }
  
  // Get cached semester data
  Future<Semester?> _getCachedSemester() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_cacheKeySemester);
      
      if (cachedData == null || cachedData.isEmpty) {
        return null;
      }
      
      final Map<String, dynamic> semesterMap = jsonDecode(cachedData);
      final List<dynamic> sessionsJson = semesterMap['sessions'] as List<dynamic>;
      
      final List<ClassSession> sessions = sessionsJson.map((sessionJson) {
        return ClassSession.fromJson(sessionJson);
      }).toList();
      
      return Semester(
        name: semesterMap['name'],
        sessions: sessions,
      );
    } catch (e) {
      print('Error reading cached semester data: $e');
      return null;
    }
  }
  
  // Check if we can refresh based on limits
  Future<bool> _checkRefreshLimits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get the current day
      final today = DateTime.now().day;
      final storedDay = prefs.getInt(_cacheKeyRefreshDay) ?? -1;
      
      // If it's a new day, reset the counter
      if (today != storedDay) {
        await prefs.setInt(_cacheKeyRefreshCount, 0);
        await prefs.setInt(_cacheKeyRefreshDay, today);
        return true;
      }
      
      // Check refresh count
      final refreshCount = prefs.getInt(_cacheKeyRefreshCount) ?? 0;
      if (refreshCount < _maxRefreshCount) {
        return true;
      }
      
      // If we've hit the max, check cooldown period
      final lastRefresh = prefs.getInt(_cacheKeyLastRefresh) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (now - lastRefresh > _refreshCooldown.inMilliseconds) {
        return true;
      }
      
      // Still in cooldown
      print('Refresh limit reached. Please try again later.');
      return false;
    } catch (e) {
      print('Error checking refresh limits: $e');
      return true; // On error, allow refresh
    }
  }
  
  // Increment the refresh counter
  Future<void> _incrementRefreshCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get the current day
      final today = DateTime.now().day;
      final storedDay = prefs.getInt(_cacheKeyRefreshDay) ?? -1;
      
      // If it's a new day, reset the counter
      if (today != storedDay) {
        await prefs.setInt(_cacheKeyRefreshCount, 1);
        await prefs.setInt(_cacheKeyRefreshDay, today);
        return;
      }
      
      // Increment counter
      final refreshCount = prefs.getInt(_cacheKeyRefreshCount) ?? 0;
      await prefs.setInt(_cacheKeyRefreshCount, refreshCount + 1);
      await prefs.setInt(_cacheKeyLastRefresh, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error incrementing refresh count: $e');
    }
  }

  // Get the refresh status for UI feedback
  Future<Map<String, dynamic>> getRefreshStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final refreshCount = prefs.getInt(_cacheKeyRefreshCount) ?? 0;
      final lastRefresh = prefs.getInt(_cacheKeyLastRefresh) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Calculate time remaining in cooldown
      int cooldownRemaining = 0;
      if (refreshCount >= _maxRefreshCount) {
        cooldownRemaining = _refreshCooldown.inMilliseconds - (now - lastRefresh);
        cooldownRemaining = cooldownRemaining > 0 ? cooldownRemaining : 0;
      }
      
      return {
        'refreshCount': refreshCount,
        'maxRefreshCount': _maxRefreshCount,
        'inCooldown': cooldownRemaining > 0,
        'cooldownRemainingMs': cooldownRemaining,
        'cooldownRemainingMin': (cooldownRemaining / 60000).ceil(),
      };
    } catch (e) {
      print('Error getting refresh status: $e');
      return {
        'refreshCount': 0,
        'maxRefreshCount': _maxRefreshCount,
        'inCooldown': false,
        'cooldownRemainingMs': 0,
        'cooldownRemainingMin': 0,
      };
    }
  }

  // Get the student's class schedule based on their profile
  Future<ClassIdentifier?> getStudentClassIdentifier() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Get the user document with improved error logging
      print('Fetching class identifier for user: ${user.email}');
      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get(GetOptions(source: Source.server)); // Force server fetch to get latest data

      if (userDoc.docs.isEmpty) {
        print('No user document found for email: ${user.email}');
        return null;
      }

      final userData = userDoc.docs.first.data();
      print('User data fetched: ${userData.toString()}');
      
      // Check if user has class information with appropriate type conversion
      if (!userData.containsKey('academicYear') && !userData.containsKey('year')) {
        print('User missing academic year field');
        return null;
      }
      
      if (!userData.containsKey('department')) {
        print('User missing department field');
        return null;
      }
      
      if (!userData.containsKey('section')) {
        print('User missing section field');
        return null;
      }

      // Try to get academic year from multiple possible field names
      final String yearString = (userData['academicYear'] ?? userData['year'] ?? 'GN').toString();
      
      // Convert string year format to integer
      int academicYear = _convertAcademicYearStringToInt(yearString);
      
      // Get department, ensuring it's a valid string
      final String deptString = userData['department']?.toString() ?? 'GN';
      
      // Convert department code (CE, EME, etc.) to Department enum
      final Department department = _convertDepartmentCodeToEnum(deptString);
      
      // Get section, ensuring it's an integer
      final section = userData['section'] ?? 1;
      final int sectionNumber = section is int ? section : int.tryParse(section.toString()) ?? 1;
      
      print('Creating ClassIdentifier with year: $academicYear, department: ${department.name}, section: $sectionNumber');
      
      // Create class identifier with proper data conversion
      return ClassIdentifier(
        year: academicYear,
        department: department,
        section: sectionNumber,
      );
    } catch (e) {
      print('Error getting student class identifier: $e');
      return null;
    }
  }

  // Helper method to convert department codes from Firestore to Department enum
  Department _convertDepartmentCodeToEnum(String deptCode) {
    switch (deptCode.trim().toUpperCase()) {
      case 'CE':
        return Department.C;
      case 'EME':
        return Department.M;
      case 'IE':
        return Department.I;
      case 'ECE':
        return Department.E;
      case 'GN':
        return Department.G;
      default:
        // Check if it's already a single letter that matches our enum
        if (deptCode.length == 1) {
          try {
            return Department.values.firstWhere(
              (d) => d.name == deptCode,
              orElse: () => Department.G,
            );
          } catch (_) {
            return Department.G;
          }
        }
        // Default to General if unrecognized
        return Department.G;
    }
  }

  // Helper method to convert Department enum to Firestore department code
  String _convertDepartmentEnumToCode(Department department) {
    switch (department) {
      case Department.C:
        return 'CE';
      case Department.M:
        return 'EME';
      case Department.I:
        return 'IE';
      case Department.E:
        return 'ECE';
      case Department.G:
        return 'GN';
    }
  }

  // Helper method to convert academic year strings to integers
  int _convertAcademicYearStringToInt(String yearString) {
    switch (yearString.trim().toLowerCase()) {
      case 'gn':
        return 0;
      case '1st':
        return 1;
      case '2nd':
        return 2;
      case '3rd':
        return 3;
      case '4th':
        return 4;
      default:
        // Try to parse as int if it's just a number
        final intValue = int.tryParse(yearString);
        if (intValue != null && intValue >= 0 && intValue <= 4) {
          return intValue;
        }
        // Default to general (0) if unrecognized
        return 0;
    }
  }

  // Default semester for testing or when no data is available
  Future<Semester> _getDefaultSemester() async {
    try {
      // First check if there's a cached semester
      final cachedSemester = await _getCachedSemester();
      if (cachedSemester != null && cachedSemester.sessions.isNotEmpty) {
        print('Using cached semester as fallback');
        return cachedSemester;
      }
      
      // Try to create a semester in Firestore if none exists
      final String semesterId = await _createDefaultSemester();
      if (semesterId.isNotEmpty) {
        // Successfully created, now fetch it
        print('Created default semester in Firestore');
        return await getCurrentSemester(forceRefresh: true);
      }
      
      // If creation failed, fall back to empty semester
      print('Failed to create default semester, returning empty semester');
      return Semester(
        name: '2nd Semester(2024-2025)',
        sessions: [],
      );
    } catch (e) {
      print('Error loading default semester data: $e');
      // Last resort - empty semester
      return Semester(
        name: '2nd Semester(2024-2025)',
        sessions: [],
      );
    }
  }
  
  // Create a default semester with sessions from JSON
  Future<String> _createDefaultSemester() async {
    try {
      // Create the semester document
      final semesterData = {
        'name': '2nd Semester(2024-2025)',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      final semesterRef = await _firestore
          .collection('semesters')
          .add(semesterData);
      
      return semesterRef.id;
    } catch (e) {
      print('Error creating default semester: $e');
      return '';
    }
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
  
  // Admin methods for schedule management
  
  /// Adds or updates a class session in the current semester
  /// Returns true if successful, false otherwise
  Future<bool> addOrUpdateClassSession(ClassSession session, {String? targetSemesterId}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // Check if user is admin with batch query
      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .where('role', isEqualTo: 'Admin')
          .limit(1)
          .get();
      
      if (userDoc.docs.isEmpty) return false;
      
      // Use the provided semesterId if available, otherwise get the active semester
      String semesterId = '';
      if (targetSemesterId != null && targetSemesterId.isNotEmpty) {
        // Verify the semester exists
        final semesterExists = await _checkSemesterExists(targetSemesterId);
        if (semesterExists) {
          semesterId = targetSemesterId;
        } else {
          print('Specified semester does not exist: $targetSemesterId');
          return false;
        }
      } else {
        // Get or create active semester - use cache for performance
        semesterId = await _getOrCreateActiveSemester();
      }
      
      if (semesterId.isEmpty) return false;
      
      // Get year string representation for Firestore storage
      final String yearString = _convertYearIntToString(session.classIdentifier.year);
      
      // Get department code for Firestore storage
      final String deptCode = _convertDepartmentEnumToCode(session.classIdentifier.department);
      
      // Prepare session data
      final sessionData = {
        'courseName': session.courseName,
        'courseCode': session.courseCode,
        'instructor': session.instructor,
        'location': session.location,
        'day': session.day.name,
        'periodNumber': session.periodNumber,
        'weekType': session.weekType.name,
        'classIdentifier': {
          'year': yearString, // Store as string format in Firestore
          'department': deptCode, // Store as full department code in Firestore
          'section': session.classIdentifier.section,
        },
        'isLab': session.isLab,
        'isTutorial': session.isTutorial,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': user.email,
      };
      
      // Add or update the session
      if (session.id.isEmpty || session.id == 'new') {
        await _firestore
            .collection('semesters')
            .doc(semesterId)
            .collection('sessions')
            .add(sessionData);
      } else {
        await _firestore
            .collection('semesters')
            .doc(semesterId)
            .collection('sessions')
            .doc(session.id)
            .set(sessionData, SetOptions(merge: true));
      }
      
      return true;
    } catch (e) {
      print('Error adding/updating class session: $e');
      return false;
    }
  }

  // Helper method to convert year integer to string format for Firestore
  String _convertYearIntToString(int year) {
    switch (year) {
      case 0:
        return 'GN';
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      case 4:
        return '4th';
      default:
        return 'GN';
    }
  }

  /// Deletes a class session from the current semester
  /// Returns true if successful, false otherwise
  Future<bool> deleteClassSession(String sessionId, {String? targetSemesterId}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // Check if user is admin
      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .where('role', isEqualTo: 'Admin')
          .limit(1)
          .get();
      
      if (userDoc.docs.isEmpty) return false;
      
      // Use the provided semesterId if available, otherwise get the active semester
      String semesterId = '';
      if (targetSemesterId != null && targetSemesterId.isNotEmpty) {
        // Verify the semester exists
        final semesterExists = await _checkSemesterExists(targetSemesterId);
        if (semesterExists) {
          semesterId = targetSemesterId;
        } else {
          print('Specified semester does not exist: $targetSemesterId');
          return false;
        }
      } else {
        // Get active semester
        semesterId = await _getOrCreateActiveSemester();
      }
      
      if (semesterId.isEmpty) return false;
      
      // Delete the session
      await _firestore
          .collection('semesters')
          .doc(semesterId)
          .collection('sessions')
          .doc(sessionId)
          .delete();
      
      return true;
    } catch (e) {
      print('Error deleting class session: $e');
      return false;
    }
  }

  /// Adds a day off session for a specific class, day and week type
  /// Returns true if successful, false otherwise
  Future<bool> addDayOff(DayOfWeek day, WeekType weekType, ClassIdentifier classIdentifier, {String? targetSemesterId}) async {
    final session = ClassSession(
      id: 'new',
      courseName: 'DAY OFF',
      courseCode: '',
      instructor: '',
      location: '',
      day: day,
      periodNumber: 1, // Can be any period, we use 1 as default
      weekType: weekType,
      classIdentifier: classIdentifier,
      isLab: false,
      isTutorial: false,
    );
    
    return await addOrUpdateClassSession(session, targetSemesterId: targetSemesterId);
  }

  /// Gets all available class identifiers (year, department, section combinations)
  /// Returns empty list if failed or user is not admin
  Future<List<ClassIdentifier>> getAllClassIdentifiers() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];
      
      // Check if user is admin
      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .where('role', isEqualTo: 'Admin')
          .limit(1)
          .get();
      
      if (userDoc.docs.isEmpty) return [];
      
      // Use a more efficient approach - get all sections directly from academic year collection
      final QuerySnapshot yearsSnapshot = await _firestore
          .collection('academicYears')
          .get(GetOptions(source: Source.serverAndCache));
      
      final List<ClassIdentifier> classIdentifiers = [];
      
      for (final yearDoc in yearsSnapshot.docs) {
        final yearData = yearDoc.data() as Map<String, dynamic>;
        
        // Convert the year string (like '1st', '2nd', etc.) to int
        final String yearString = yearDoc.id;
        final int academicYear = _convertAcademicYearStringToInt(yearString);
        
        if (yearData.containsKey('departments')) {
          final departments = yearData['departments'] as List<dynamic>;
          
          for (final deptData in departments) {
            final String deptCode = deptData['code'] ?? '';
            final int sectionCount = deptData['sectionCount'] ?? 1;
            
            // Convert department code to enum using our helper method
            final department = _convertDepartmentCodeToEnum(deptCode);
            
            // Add each section for this department and year
            for (int sectionNumber = 1; sectionNumber <= sectionCount; sectionNumber++) {
              classIdentifiers.add(ClassIdentifier(
                year: academicYear,
                department: department,
                section: sectionNumber,
              ));
            }
          }
        }
      }
      
      // If no class identifiers found using academicYears collection,
      // fall back to getting them from users collection
      if (classIdentifiers.isEmpty) {
        final Map<String, Set<int>> sectionsMap = {};
        
        final usersSnapshot = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'Student')
            .get();
        
        for (final doc in usersSnapshot.docs) {
          final userData = doc.data();
          
          if (userData.containsKey('academicYear') && 
              userData.containsKey('department') && 
              userData.containsKey('section')) {
            
            // Convert year string to int
            final String yearString = userData['academicYear'].toString();
            final int year = _convertAcademicYearStringToInt(yearString);
            
            // Convert department code to enum
            final String deptCode = userData['department'] ?? 'GN';
            final Department department = _convertDepartmentCodeToEnum(deptCode);
            
            final int section = userData['section'] ?? 1;
            
            final key = '$year-${department.name}';
            if (!sectionsMap.containsKey(key)) {
              sectionsMap[key] = {};
            }
            sectionsMap[key]!.add(section);
          }
        }
        
        // Convert the map to class identifiers
        for (final key in sectionsMap.keys) {
          final parts = key.split('-');
          final int year = int.tryParse(parts[0]) ?? 0;
          final department = Department.values.firstWhere(
            (d) => d.name == parts[1],
            orElse: () => Department.G,
          );
          
          for (final section in sectionsMap[key]!) {
            classIdentifiers.add(ClassIdentifier(
              year: year,
              department: department,
              section: section,
            ));
          }
        }
      }
      
      // If still no class identifiers found, provide default ones for key years/departments
      if (classIdentifiers.isEmpty) {
        print('No class identifiers found in database, using default values');
        
        // Add default classes for common year-department combinations
        classIdentifiers.add(ClassIdentifier(
          year: 4,
          department: Department.C,
          section: 1,
        ));
        classIdentifiers.add(ClassIdentifier(
          year: 4,
          department: Department.E,
          section: 1,
        ));
      }
      
      return classIdentifiers;
    } catch (e) {
      print('Error getting class identifiers: $e');
      // Return default class identifiers on error
      final List<ClassIdentifier> defaultIdentifiers = [];
      defaultIdentifiers.add(ClassIdentifier(
        year: 4,
        department: Department.C,
        section: 1,
      ));
      defaultIdentifiers.add(ClassIdentifier(
        year: 4,
        department: Department.E,
        section: 1,
      ));
      
      return defaultIdentifiers;
    }
  }
  
  /// Adds multiple sessions for a class at once
  /// This is more efficient than adding sessions one by one
  Future<bool> addMultipleSessions(List<ClassSession> sessions, {String? targetSemesterId}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // Check if user is admin
      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .where('role', isEqualTo: 'Admin')
          .limit(1)
          .get();
      
      if (userDoc.docs.isEmpty) return false;
      
      // Use the provided semesterId if available, otherwise get the active semester
      String semesterId = '';
      if (targetSemesterId != null && targetSemesterId.isNotEmpty) {
        // Verify the semester exists
        final semesterExists = await _checkSemesterExists(targetSemesterId);
        if (semesterExists) {
          semesterId = targetSemesterId;
        } else {
          print('Specified semester does not exist: $targetSemesterId');
          return false;
        }
      } else {
        // Get active semester
        semesterId = await _getOrCreateActiveSemester();
      }
      
      if (semesterId.isEmpty) return false;
      
      // Use batch write for better performance
      final WriteBatch batch = _firestore.batch();
      
      for (final session in sessions) {
        // Convert year to string format for Firestore
        final String yearString = _convertYearIntToString(session.classIdentifier.year);
        
        // Convert department to full code for Firestore
        final String deptCode = _convertDepartmentEnumToCode(session.classIdentifier.department);
        
        final sessionData = {
          'courseName': session.courseName,
          'courseCode': session.courseCode,
          'instructor': session.instructor,
          'location': session.location,
          'day': session.day.name,
          'periodNumber': session.periodNumber,
          'weekType': session.weekType.name,
          'classIdentifier': {
            'year': yearString, // Store as string format in Firestore
            'department': deptCode, // Store as full department code in Firestore
            'section': session.classIdentifier.section,
          },
          'isLab': session.isLab,
          'isTutorial': session.isTutorial,
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': user.email,
        };
        
        final docRef = _firestore
            .collection('semesters')
            .doc(semesterId)
            .collection('sessions')
            .doc(); // Auto-generate ID
            
        batch.set(docRef, sessionData);
      }
      
      // Commit the batch
      await batch.commit();
      
      return true;
    } catch (e) {
      print('Error adding multiple sessions: $e');
      return false;
    }
  }

  /// Gets or creates an active semester document
  /// Returns the semester ID, or empty string if failed
  Future<String> _getOrCreateActiveSemester({bool forceRefresh = false}) async {
    try {
      // Try to get existing active semester
      final QuerySnapshot semesterDoc = await _firestore
          .collection('semesters')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get(forceRefresh 
              ? GetOptions(source: Source.server) 
              : GetOptions(source: Source.serverAndCache));
      
      // If exists, return its ID
      if (semesterDoc.docs.isNotEmpty) {
        return semesterDoc.docs.first.id;
      }
      
      print('No active semester found, creating one');
      
      // Create default semesters
      await _createDefaultSemesters();
      
      // Try again to get active semester
      final retrySnapshot = await _firestore
          .collection('semesters')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get(GetOptions(source: Source.server));
      
      if (retrySnapshot.docs.isNotEmpty) {
        return retrySnapshot.docs.first.id;
      }
      
      // If still no active semester, return empty
      return '';
    } catch (e) {
      print('Error getting or creating active semester: $e');
      return '';
    }
  }

  // Get a specific semester by ID
  Future<Semester> getSemesterById(String semesterId, {bool forceRefresh = false}) async {
    try {
      // Check refresh limits if force refresh is requested
      if (forceRefresh) {
        final canRefresh = await _checkRefreshLimits();
        if (!canRefresh) {
          forceRefresh = false;
        }
      }
      
      // Verify the semester exists
      final semesterExists = await _checkSemesterExists(semesterId);
      if (!semesterExists) {
        throw Exception("Semester with ID $semesterId not found");
      }
      
      // Get semester data
      final semesterDoc = await _firestore
          .collection('semesters')
          .doc(semesterId)
          .get(forceRefresh 
              ? GetOptions(source: Source.server) 
              : GetOptions(source: Source.serverAndCache));
      
      final semesterData = semesterDoc.data() as Map<String, dynamic>;
      semesterData['id'] = semesterDoc.id; // Include the document ID
      
      // Get all sessions for this semester
      final QuerySnapshot sessionsSnapshot = await _firestore
          .collection('semesters')
          .doc(semesterId)
          .collection('sessions')
          .get(forceRefresh 
              ? GetOptions(source: Source.server) 
              : GetOptions(source: Source.serverAndCache));
      
      final sessions = sessionsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ClassSession.fromJson(data);
      }).toList();
      
      final semester = Semester.fromJson({
        ...semesterData,
        'sessions': sessions.map((s) => s.toJson()).toList(),
      });
      
      return semester;
    } catch (e) {
      print('Error getting semester by ID: $e');
      throw e;
    }
  }
  
  // Get all available semesters
  Future<List<Semester>> getAllSemesters({bool forceRefresh = false}) async {
    try {
      // Query all semesters
      final QuerySnapshot semestersSnapshot = await _firestore
          .collection('semesters')
          .orderBy('createdAt', descending: true)
          .get(forceRefresh 
              ? GetOptions(source: Source.server) 
              : GetOptions(source: Source.serverAndCache));
      
      if (semestersSnapshot.docs.isEmpty) {
        // If no semesters found, create default ones
        await _createDefaultSemesters();
        
        // Query again
        return await getAllSemesters(forceRefresh: true);
      }
      
      final List<Semester> semesters = [];
      
      // For each semester, create a Semester object with basic info (without sessions)
      for (final doc in semestersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        
        semesters.add(Semester.fromJson({
          ...data,
          'sessions': [], // Empty sessions list for performance - load full data only when needed
        }));
      }
      
      return semesters;
    } catch (e) {
      print('Error getting all semesters: $e');
      return [];
    }
  }
  
  // Check if a semester exists
  Future<bool> _checkSemesterExists(String semesterId) async {
    try {
      final docSnapshot = await _firestore
          .collection('semesters')
          .doc(semesterId)
          .get(GetOptions(source: Source.cache));
      
      return docSnapshot.exists;
    } catch (e) {
      // If error, try server
      try {
        final docSnapshot = await _firestore
            .collection('semesters')
            .doc(semesterId)
            .get(GetOptions(source: Source.server));
        
        return docSnapshot.exists;
      } catch (_) {
        return false;
      }
    }
  }
  
  // Save the selected semester ID to preferences
  Future<void> setSelectedSemesterId(String semesterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKeySelectedSemesterId, semesterId);
    } catch (e) {
      print('Error saving selected semester ID: $e');
    }
  }
  
  // Get the selected semester ID from preferences
  Future<String?> _getSelectedSemesterId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_cacheKeySelectedSemesterId);
    } catch (e) {
      print('Error getting selected semester ID: $e');
      return null;
    }
  }
  
  // Create default semesters if none exist
  Future<void> _createDefaultSemesters() async {
    try {
      final currentYear = DateTime.now().year;
      final nextYear = currentYear + 1;
      final prevYear = currentYear - 1;
      
      // Create 1st semester of current academic year
      await _createSemester(
        name: '1st Semester($currentYear-$nextYear)',
        semesterNumber: 1,
        academicYear: '$currentYear-$nextYear',
        isActive: false
      );
      
      // Create 2nd semester of current academic year (active by default)
      await _createSemester(
        name: '2nd Semester($currentYear-$nextYear)',
        semesterNumber: 2,
        academicYear: '$currentYear-$nextYear',
        isActive: true
      );
      
      // Create previous semesters for history
      await _createSemester(
        name: '1st Semester($prevYear-$currentYear)',
        semesterNumber: 1,
        academicYear: '$prevYear-$currentYear',
        isActive: false
      );
      
      await _createSemester(
        name: '2nd Semester($prevYear-$currentYear)',
        semesterNumber: 2,
        academicYear: '$prevYear-$currentYear',
        isActive: false
      );
      
    } catch (e) {
      print('Error creating default semesters: $e');
    }
  }
  
  // Create a single semester document
  Future<String> _createSemester({
    required String name,
    required int semesterNumber,
    required String academicYear,
    required bool isActive,
  }) async {
    final semesterData = {
      'name': name,
      'semesterNumber': semesterNumber,
      'academicYear': academicYear,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    final docRef = await _firestore
        .collection('semesters')
        .add(semesterData);
    
    return docRef.id;
  }
  
  // Set a semester as active (and deactivate others)
  Future<bool> setSemesterActive(String semesterId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // Check if user is admin
      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .where('role', isEqualTo: 'Admin')
          .limit(1)
          .get();
      
      if (userDoc.docs.isEmpty) return false;
      
      // Check if semester exists
      final semesterExists = await _checkSemesterExists(semesterId);
      if (!semesterExists) return false;
      
      // Use a batch to update all semesters atomically
      final WriteBatch batch = _firestore.batch();
      
      // First, get all active semesters
      final activeSemesters = await _firestore
          .collection('semesters')
          .where('isActive', isEqualTo: true)
          .get();
      
      // Deactivate all currently active semesters
      for (final doc in activeSemesters.docs) {
        batch.update(doc.reference, {
          'isActive': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      // Activate the selected semester
      batch.update(_firestore.collection('semesters').doc(semesterId), {
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Commit the batch
      await batch.commit();
      
      // Also set this as the user's selected semester
      await setSelectedSemesterId(semesterId);
      
      return true;
    } catch (e) {
      print('Error setting semester active: $e');
      return false;
    }
  }
} 