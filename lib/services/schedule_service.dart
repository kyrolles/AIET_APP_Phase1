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

      // Get or create active semester
      final String semesterId = await _getOrCreateActiveSemester(forceRefresh: forceRefresh);
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
      
      final semester = Semester(
        name: semesterData['name'] ?? '2nd Semester(2024-2025)',
        sessions: sessions,
      );
      
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
      final year = userData['academicYear'] ?? userData['year'] ?? 0;
      // Ensure year is an integer
      final int academicYear = year is int ? year : int.tryParse(year.toString()) ?? 0;
      
      // Get department, ensuring it's a valid string
      final String deptString = userData['department']?.toString() ?? 'G';
      
      // Get section, ensuring it's an integer
      final section = userData['section'] ?? 1;
      final int sectionNumber = section is int ? section : int.tryParse(section.toString()) ?? 1;
      
      print('Creating ClassIdentifier with year: $academicYear, department: $deptString, section: $sectionNumber');
      
      // Create class identifier with proper data conversion
      return ClassIdentifier(
        year: academicYear,
        department: Department.values.firstWhere(
          (d) => d.name == deptString,
          orElse: () => Department.G,
        ),
        section: sectionNumber,
      );
    } catch (e) {
      print('Error getting student class identifier: $e');
      return null;
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
      
      // If creation failed, fall back to hardcoded data
      print('Falling back to hardcoded data for semester');
      
      // Try using mock data directly
      try {
        final mockSessions = _getMockSessionsHardcoded();
        // Add more mock sessions for testing to cover multiple classes
        final mockSessions2 = _getAdditionalMockSessions();
        
        return Semester(
          name: '2nd Semester(2024-2025)',
          sessions: [...mockSessions, ...mockSessions2],
        );
      } catch (innerError) {
        print('Error creating hardcoded semester data: $innerError');
        // Last resort - empty semester with just a few sessions
        return Semester(
          name: '2nd Semester(2024-2025)',
          sessions: _getMinimalMockSessions(),
        );
      }
    } catch (e) {
      print('Error loading default semester data: $e');
      // Last resort - empty semester with just a few sessions
      return Semester(
        name: '2nd Semester(2024-2025)',
        sessions: _getMinimalMockSessions(),
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
          
      // Read sessions from JSON
      final String jsonData = await rootBundle.loadString('lib/data/schedule_data.json');
      final Map<String, dynamic> data = json.decode(jsonData);
      final Map<String, dynamic> semesterJson = data['currentSemester'];
      final List<dynamic> sessionsJson = semesterJson['sessions'] as List<dynamic>;
      
      // Batch write all sessions
      final WriteBatch batch = _firestore.batch();
      
      for (final sessionJson in sessionsJson) {
        // Prepare Firestore-compatible data
        final Map<String, dynamic> sessionData = {
          'courseName': sessionJson['courseName'],
          'courseCode': sessionJson['courseCode'] ?? '',
          'instructor': sessionJson['instructor'] ?? '',
          'location': sessionJson['location'] ?? '',
          'day': sessionJson['day'],
          'periodNumber': sessionJson['periodNumber'],
          'weekType': sessionJson['weekType'],
          'classIdentifier': {
            'year': sessionJson['classIdentifier']['year'],
            'department': sessionJson['classIdentifier']['department'],
            'section': sessionJson['classIdentifier']['section'],
          },
          'isLab': sessionJson['isLab'] ?? false,
          'isTutorial': sessionJson['isTutorial'] ?? false,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        // Create a new session document reference
        final sessionRef = _firestore
            .collection('semesters')
            .doc(semesterRef.id)
            .collection('sessions')
            .doc();
            
        // Add to batch
        batch.set(sessionRef, sessionData);
      }
      
      // Commit the batch
      await batch.commit();
      
      return semesterRef.id;
    } catch (e) {
      print('Error creating default semester: $e');
      return '';
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

  // Additional mock sessions to ensure every department has at least one
  List<ClassSession> _getAdditionalMockSessions() {
    final List<ClassSession> sessions = [];
    
    // Create sessions for each department and year
    for (int year = 1; year <= 4; year++) {
      for (final dept in Department.values) {
        for (int section = 1; section <= 2; section++) {
          final classId = ClassIdentifier(
            year: year,
            department: dept,
            section: section,
          );
          
          sessions.add(ClassSession(
            id: 'mock_${year}${dept.name}${section}_1',
            courseName: 'Course for ${year}${dept.name}${section}',
            courseCode: 'CC${year}${dept.name}${section}',
            instructor: 'Dr. Instructor',
            location: 'Room ${year}${dept.name}${section}',
            day: DayOfWeek.MONDAY,
            periodNumber: 1,
            weekType: WeekType.ODD,
            classIdentifier: classId,
          ));
          
          sessions.add(ClassSession(
            id: 'mock_${year}${dept.name}${section}_2',
            courseName: 'Another Course',
            courseCode: 'AC${year}${dept.name}${section}',
            instructor: 'Dr. Professor',
            location: 'Lab ${year}${dept.name}${section}',
            day: DayOfWeek.WEDNESDAY,
            periodNumber: 3,
            weekType: WeekType.EVEN,
            classIdentifier: classId,
          ));
        }
      }
    }
    
    return sessions;
  }
  
  // Absolute minimal mock sessions as last resort
  List<ClassSession> _getMinimalMockSessions() {
    // Just create one session for each common department
    return [
      ClassSession(
        id: 'min_4C2',
        courseName: 'Computer Engineering',
        courseCode: 'CE400',
        instructor: 'Dr. Smith',
        location: 'Room 101',
        day: DayOfWeek.MONDAY,
        periodNumber: 1,
        weekType: WeekType.ODD,
        classIdentifier: ClassIdentifier(
          year: 4,
          department: Department.C,
          section: 2,
        ),
      ),
      ClassSession(
        id: 'min_4E1',
        courseName: 'Communication Systems',
        courseCode: 'CE401',
        instructor: 'Dr. Jones',
        location: 'Room 102',
        day: DayOfWeek.TUESDAY,
        periodNumber: 2,
        weekType: WeekType.ODD,
        classIdentifier: ClassIdentifier(
          year: 4,
          department: Department.E,
          section: 1,
        ),
      ),
      ClassSession(
        id: 'min_3C1',
        courseName: 'Data Structures',
        courseCode: 'CE301',
        instructor: 'Dr. Brown',
        location: 'Room 103',
        day: DayOfWeek.WEDNESDAY,
        periodNumber: 3,
        weekType: WeekType.EVEN,
        classIdentifier: ClassIdentifier(
          year: 3,
          department: Department.C,
          section: 1,
        ),
      ),
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
  
  // Admin methods for schedule management
  
  /// Adds or updates a class session in the current semester
  /// Returns true if successful, false otherwise
  Future<bool> addOrUpdateClassSession(ClassSession session) async {
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
      
      // Get or create active semester - use cache for performance
      final String semesterId = await _getOrCreateActiveSemester();
      if (semesterId.isEmpty) return false;
      
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
          'year': session.classIdentifier.year,
          'department': session.classIdentifier.department.name,
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

  /// Deletes a class session from the current semester
  /// Returns true if successful, false otherwise
  Future<bool> deleteClassSession(String sessionId) async {
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
      
      // Get active semester
      final String semesterId = await _getOrCreateActiveSemester();
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
  Future<bool> addDayOff(DayOfWeek day, WeekType weekType, ClassIdentifier classIdentifier) async {
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
    
    return await addOrUpdateClassSession(session);
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
        final int academicYear = int.tryParse(yearDoc.id) ?? 0;
        
        if (yearData.containsKey('departments')) {
          final departments = yearData['departments'] as List<dynamic>;
          
          for (final deptData in departments) {
            final String deptCode = deptData['code'] ?? '';
            final int sectionCount = deptData['sectionCount'] ?? 1;
            
            final department = Department.values.firstWhere(
              (d) => d.name == deptCode,
              orElse: () => Department.G,
            );
            
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
            
            final int year = userData['academicYear'] ?? 0;
            final String deptCode = userData['department'] ?? 'G';
            final int section = userData['section'] ?? 1;
            
            final key = '$year-$deptCode';
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
      
      // If still no class identifiers found, provide default ones
      if (classIdentifiers.isEmpty) {
        print('No class identifiers found in database, using default values');
        
        // Add default classes for each department and year
        for (int year = 1; year <= 4; year++) {
          for (final dept in Department.values) {
            // Add 2 sections for each year-department combination
            for (int section = 1; section <= 2; section++) {
              classIdentifiers.add(ClassIdentifier(
                year: year,
                department: dept,
                section: section,
              ));
            }
          }
        }
      }
      
      return classIdentifiers;
    } catch (e) {
      print('Error getting class identifiers: $e');
      // Return default class identifiers on error
      final List<ClassIdentifier> defaultIdentifiers = [];
      defaultIdentifiers.add(ClassIdentifier(
        year: 4,
        department: Department.C,
        section: 2,
      ));
      defaultIdentifiers.add(ClassIdentifier(
        year: 4,
        department: Department.E,
        section: 1,
      ));
      defaultIdentifiers.add(ClassIdentifier(
        year: 3,
        department: Department.C,
        section: 1,
      ));
      
      return defaultIdentifiers;
    }
  }
  
  /// Adds multiple sessions for a class at once
  /// This is more efficient than adding sessions one by one
  Future<bool> addMultipleSessions(List<ClassSession> sessions) async {
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
      
      // Get active semester
      final String semesterId = await _getOrCreateActiveSemester();
      if (semesterId.isEmpty) return false;
      
      // Use batch write for better performance
      final WriteBatch batch = _firestore.batch();
      
      for (final session in sessions) {
        final sessionData = {
          'courseName': session.courseName,
          'courseCode': session.courseCode,
          'instructor': session.instructor,
          'location': session.location,
          'day': session.day.name,
          'periodNumber': session.periodNumber,
          'weekType': session.weekType.name,
          'classIdentifier': {
            'year': session.classIdentifier.year,
            'department': session.classIdentifier.department.name,
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
      
      // Create a new semester document
      final semesterData = {
        'name': '2nd Semester(2024-2025)',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      final docRef = await _firestore
          .collection('semesters')
          .add(semesterData);
      
      return docRef.id;
    } catch (e) {
      print('Error getting or creating active semester: $e');
      return '';
    }
  }
} 