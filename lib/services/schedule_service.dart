import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        return _getDefaultSemester();
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
      return _getDefaultSemester();
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
  Semester _getDefaultSemester() {
    return Semester(
      name: '2nd Semester(2024-2025)',
      sessions: _getMockSessions(),
    );
  }

  // Mock schedule data for testing
  List<ClassSession> _getMockSessions() {
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
      ClassSession(
        id: 's2',
        courseName: 'Expert System Application',
        courseCode: 'L-CE406',
        instructor: 'Dr. Hatem Mohamed Abdel Kader',
        location: 'LR2( B-4-05)',
        day: DayOfWeek.SATURDAY,
        periodNumber: 3,
        weekType: WeekType.EVEN,
        classIdentifier: classId4C2,
      ),
      ClassSession(
        id: 's3',
        courseName: 'Expert System Application',
        courseCode: 'L-CE406',
        instructor: 'Dr. Hatem Mohamed Abdel Kader',
        location: 'LR2( B-4-05)',
        day: DayOfWeek.SATURDAY,
        periodNumber: 4,
        weekType: WeekType.EVEN,
        classIdentifier: classId4C2,
      ),
      
      // Sunday sessions
      ClassSession(
        id: 's4',
        courseName: 'Computer Graphics',
        courseCode: 'L-CE402',
        instructor: 'Dr. Somaya Ahmed Mohamed',
        location: 'M5',
        day: DayOfWeek.SUNDAY,
        periodNumber: 1,
        weekType: WeekType.ODD,
        classIdentifier: classId4C2,
      ),
      ClassSession(
        id: 's5',
        courseName: 'Computer Graphics',
        courseCode: 'L-CE402',
        instructor: 'Dr. Somaya Ahmed Mohamed',
        location: 'M5',
        day: DayOfWeek.SUNDAY,
        periodNumber: 1,
        weekType: WeekType.EVEN,
        classIdentifier: classId4C2,
      ),
      ClassSession(
        id: 's6',
        courseName: 'Computer Graphics',
        courseCode: 'L-CE402',
        instructor: 'Dr. Somaya Ahmed Mohamed',
        location: 'M5',
        day: DayOfWeek.SUNDAY,
        periodNumber: 2,
        weekType: WeekType.ODD,
        classIdentifier: classId4C2,
      ),
      ClassSession(
        id: 's7',
        courseName: 'Image Processing Lab',
        courseCode: '',
        instructor: 'Eng Mazen',
        location: 'B3 (A-0-20)',
        day: DayOfWeek.SUNDAY,
        periodNumber: 2,
        weekType: WeekType.EVEN,
        classIdentifier: classId4C2,
        isLab: true,
      ),
      ClassSession(
        id: 's8',
        courseName: 'Image Processing',
        courseCode: 'L-ECE454',
        instructor: 'Dr. Amr Hassan Yassein',
        location: 'M9',
        day: DayOfWeek.SUNDAY,
        periodNumber: 3,
        weekType: WeekType.ODD,
        classIdentifier: classId4C2,
      ),
      
      // Monday - Day off
      ClassSession(
        id: 's9',
        courseName: 'DAY OFF',
        courseCode: '',
        instructor: '',
        location: '',
        day: DayOfWeek.MONDAY,
        periodNumber: 1,
        weekType: WeekType.ODD,
        classIdentifier: classId4C2,
      ),
      
      // Tuesday sessions
      ClassSession(
        id: 's10',
        courseName: 'Computer Network Tut',
        courseCode: '',
        instructor: 'Eng Menna Allah Ibraheem',
        location: 'CR6',
        day: DayOfWeek.TUESDAY,
        periodNumber: 1,
        weekType: WeekType.EVEN,
        classIdentifier: classId4C2,
        isTutorial: true,
      ),
      ClassSession(
        id: 's11',
        courseName: 'Image Processing',
        courseCode: 'L-ECE454',
        instructor: 'Dr. Amr Hassan Yassein',
        location: 'M9',
        day: DayOfWeek.TUESDAY,
        periodNumber: 2,
        weekType: WeekType.ODD,
        classIdentifier: classId4C2,
      ),
      ClassSession(
        id: 's12',
        courseName: 'Computer Graphics Tut',
        courseCode: '',
        instructor: 'Eng Ayman M Kamal',
        location: 'CR3',
        day: DayOfWeek.TUESDAY,
        periodNumber: 3,
        weekType: WeekType.ODD,
        classIdentifier: classId4C2,
        isTutorial: true,
      ),
      ClassSession(
        id: 's13',
        courseName: 'Image Processing Tut',
        courseCode: '',
        instructor: 'Eng Mazen',
        location: 'CR9',
        day: DayOfWeek.TUESDAY,
        periodNumber: 3,
        weekType: WeekType.EVEN,
        classIdentifier: classId4C2,
        isTutorial: true,
      ),
      
      // Wednesday sessions
      ClassSession(
        id: 's14',
        courseName: 'Engineering Management',
        courseCode: 'L-EM442',
        instructor: 'Dr Hadeer Ragab abdelMonem',
        location: 'M3',
        day: DayOfWeek.WEDNESDAY,
        periodNumber: 1,
        weekType: WeekType.ODD,
        classIdentifier: classId4C2,
      ),
      ClassSession(
        id: 's15',
        courseName: 'Expert System Application Lab',
        courseCode: '',
        instructor: 'Eng Menna Allah Ibraheem',
        location: 'B2 (A-0-19)',
        day: DayOfWeek.WEDNESDAY,
        periodNumber: 3,
        weekType: WeekType.ODD,
        classIdentifier: classId4C2,
        isLab: true,
      ),
      ClassSession(
        id: 's16',
        courseName: 'Expert System Application Tut',
        courseCode: '',
        instructor: 'Eng Menna Allah Ibraheem',
        location: 'CR2',
        day: DayOfWeek.WEDNESDAY,
        periodNumber: 3,
        weekType: WeekType.EVEN,
        classIdentifier: classId4C2,
        isTutorial: true,
      ),
      
      // Thursday sessions
      ClassSession(
        id: 's17',
        courseName: 'Computer Network',
        courseCode: 'L-CE414',
        instructor: 'Dr. Amira Salah Eldin EL Batouty',
        location: 'M4',
        day: DayOfWeek.THURSDAY,
        periodNumber: 1,
        weekType: WeekType.ODD,
        classIdentifier: classId4C2,
      ),
      ClassSession(
        id: 's18',
        courseName: 'Computer Network',
        courseCode: 'L-CE414',
        instructor: 'Dr. Amira Salah Eldin EL Batouty',
        location: 'M4',
        day: DayOfWeek.THURSDAY,
        periodNumber: 2,
        weekType: WeekType.ODD,
        classIdentifier: classId4C2,
      ),
      ClassSession(
        id: 's19',
        courseName: 'Computer Network Lab',
        courseCode: '',
        instructor: 'Eng Menna Allah Ibraheem',
        location: 'B2 (A-0-19)',
        day: DayOfWeek.THURSDAY,
        periodNumber: 3,
        weekType: WeekType.ODD,
        classIdentifier: classId4C2,
        isLab: true,
      ),
      ClassSession(
        id: 's20',
        courseName: 'Computer Graphics Lab',
        courseCode: '',
        instructor: 'Eng Ayman M Kamal',
        location: 'B2 (A-0-19)',
        day: DayOfWeek.THURSDAY,
        periodNumber: 3,
        weekType: WeekType.EVEN,
        classIdentifier: classId4C2,
        isLab: true,
      ),
    ];
  }
} 