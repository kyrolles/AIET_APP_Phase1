import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResultsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize results profile for a new student
  Future<void> initializeStudentResults(String userId, String department) async {
    // Fetch department subjects and filter mandatory ones (isElective == false)
    final allSubjects = await getDepartmentSubjects(department);
    final mandatorySubjects = allSubjects.where((s) => s['isElective'] == false).map((subject) {
      return {
        "code": subject["code"],
        "name": subject["name"],
        "credits": subject["credits"] ?? 4,
        "grade": "F", // Default grade for new result
        "points": 0.0,
        "scores": {
          "week5": 0.0,
          "week10": 0.0,
          "coursework": subject["hasCoursework"] ? 0.0 : null,
          "lab": subject["hasLab"] ? 0.0 : null,
        },
      };
    }).toList();

    WriteBatch batch = _firestore.batch();
    // Create results for all 10 semesters with mandatory subjects pre-assigned
    for (int semester = 1; semester <= 10; semester++) {
      DocumentReference semesterRef = _firestore
          .collection('results')
          .doc(userId)
          .collection('semesters')
          .doc(semester.toString());
      batch.set(semesterRef, {
        'semesterNumber': semester,
        'department': department,
        'lastUpdated': FieldValue.serverTimestamp(),
        'subjects': mandatorySubjects,
      });
    }
    await batch.commit();
  }

  // Update department across all semesters for a student
  Future<void> updateStudentDepartment(String userId, String newDepartment) async {
    // Get all semester documents for the student
    final semestersQuery = _firestore
        .collection('results')
        .doc(userId)
        .collection('semesters');
    
    // Use a batch write to update all documents
    WriteBatch batch = _firestore.batch();
    
    QuerySnapshot semesters = await semestersQuery.get();
    for (var doc in semesters.docs) {
      batch.update(doc.reference, {'department': newDepartment});
    }

    await batch.commit();
  }

  // Check if results profile exists
  Future<bool> hasResultsProfile(String userId) async {
    final doc = await _firestore.collection('results').doc(userId).get();
    return doc.exists;
  }

  // Add new method to check if user is admin
  Future<bool> isUserAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.data()?['role'] == 'Admin';
  }

  // Update a specific subject's results
  Future<void> updateSubjectResults({
    required String userId,
    required String semesterId,
    required int subjectIndex,
    required Map<String, dynamic> updatedSubject,
  }) async {
    final isAdmin = await isUserAdmin();
    if (!isAdmin) {
      throw Exception('Permission denied: Only admins can modify results');
    }

    final semesterRef = _firestore
        .collection('results')
        .doc(userId)
        .collection('semesters')
        .doc(semesterId);

    // Get current subjects array
    final semesterDoc = await semesterRef.get();
    if (!semesterDoc.exists) {
      throw Exception('Semester document not found');
    }

    List<dynamic> subjects = List.from(semesterDoc.data()?['subjects'] ?? []);
    if (subjectIndex >= subjects.length) {
      throw Exception('Subject index out of bounds');
    }

    // Update the specific subject
    subjects[subjectIndex] = updatedSubject;

    // Update the document with admin timestamp
    await semesterRef.update({
      'subjects': subjects,
      'lastUpdated': FieldValue.serverTimestamp(),
      'lastUpdatedBy': FirebaseAuth.instance.currentUser?.uid,
      'lastUpdatedByRole': 'Admin',
    });
  }

  // Get semester results
  Future<Map<String, dynamic>?> getSemesterResults(String userId, String semesterId) async {
    final doc = await _firestore
        .collection('results')
        .doc(userId)
        .collection('semesters')
        .doc(semesterId)
        .get();
    
    return doc.data();
  }

  // Get semester template
  Future<List<Map<String, dynamic>>> getSemesterTemplate(String department, int semester) async {
    final doc = await _firestore
        .collection('templates')
        .doc(department)
        .collection('semesters')
        .doc(semester.toString())
        .get();

    if (!doc.exists) {
      return [];
    }

    return List<Map<String, dynamic>>.from(doc.data()?['subjects'] ?? []);
  }

  // Save semester template
  Future<void> saveSemesterTemplate(
    String department,
    int semester,
    List<Map<String, dynamic>> subjects,
  ) async {
    await _firestore
        .collection('templates')
        .doc(department)
        .collection('semesters')
        .doc(semester.toString())
        .set({
      'subjects': subjects,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Batch assign results to multiple students
  Future<void> batchAssignResults({
    required List<String> studentIds,
    required String department,
    required int semester,
    required List<Map<String, dynamic>> subjects,
  }) async {
    final batch = _firestore.batch();
    
    for (final studentId in studentIds) {
      final docRef = _firestore
          .collection('results')
          .doc(studentId)
          .collection('semesters')
          .doc(semester.toString());
          
      batch.set(docRef, {
        'semesterNumber': semester,
        'department': department,
        'lastUpdated': FieldValue.serverTimestamp(),
        'subjects': subjects,
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  // Export results data
  Future<Map<String, dynamic>> exportResults(String department, int semester) async {
    final students = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'Student')
        .where('department', isEqualTo: department)
        .get();

    final results = <String, dynamic>{};
    
    for (final student in students.docs) {
      final semesterDoc = await _firestore
          .collection('results')
          .doc(student.id)
          .collection('semesters')
          .doc(semester.toString())
          .get();

      if (semesterDoc.exists) {
        results[student.id] = {
          'studentData': student.data(),
          'results': semesterDoc.data(),
        };
      }
    }

    return results;
  }

  // Import results data
  Future<void> importResults(Map<String, dynamic> data) async {
    final batch = _firestore.batch();

    data.forEach((studentId, studentData) {
      final resultData = studentData['results'] as Map<String, dynamic>;
      final docRef = _firestore
          .collection('results')
          .doc(studentId)
          .collection('semesters')
          .doc(resultData['semesterNumber'].toString());

      batch.set(docRef, resultData);
    });

    await batch.commit();
  }

  // Get department subjects
  Future<List<Map<String, dynamic>>> getDepartmentSubjects(String department) async {
    final doc = await _firestore
        .collection('departments')
        .doc(department)
        .collection('subjects')
        .get();

    return doc.docs.map((d) => d.data()).toList();
  }

  // Add department subject
  Future<void> addDepartmentSubject(String department, Map<String, dynamic> subject) async {
    await _firestore
        .collection('departments')
        .doc(department)
        .collection('subjects')
        .doc(subject['code'])
        .set({
      ...subject,
      'isElective': subject['isElective'] ?? false,
      'availableForSemesters': subject['availableForSemesters'] ?? [1,2,3,4,5,6,7,8,9,10],
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Delete department subject
  Future<void> deleteDepartmentSubject(String department, String subjectCode) async {
    await _firestore
        .collection('departments')
        .doc(department)
        .collection('subjects')
        .doc(subjectCode)
        .delete();
  }

  // Get available subjects for semester template
  Future<List<Map<String, dynamic>>> getAvailableSubjects(String department) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('departments')
        .doc(department)
        .collection('subjects')
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Get student's registered subjects
  Future<List<String>> getStudentSubjects(String userId, String semesterId) async {
    final doc = await _firestore
        .collection('results')
        .doc(userId)
        .collection('semesters')
        .doc(semesterId)
        .get();
    
    if (!doc.exists) return [];
    
    final subjects = doc.data()?['subjects'] as List?;
    return subjects?.map((s) => s['code'] as String).toList() ?? [];
  }

  // Update student's subject registration
  Future<void> updateStudentSubjects({
    required String userId,
    required String semesterId,
    required List<String> selectedSubjectCodes,
  }) async {
    final availableSubjects = await getDepartmentSubjects(
      (await _firestore.collection('users').doc(userId).get()).data()?['department'] ?? '',
    );

    final selectedSubjects = availableSubjects
        .where((s) => selectedSubjectCodes.contains(s['code']))
        .toList();

    await _firestore
        .collection('results')
        .doc(userId)
        .collection('semesters')
        .doc(semesterId)
        .set({
      'subjects': selectedSubjects,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // New method: update elective subject for a group of students
  Future<void> groupUpdateElectiveSubjects({
    required List<String> studentIds,
    required int semester,
    required String electiveSubjectCode,
    required Map<String, dynamic> updatedData,
  }) async {
    WriteBatch batch = _firestore.batch();
    for (final studentId in studentIds) {
      final semesterRef = _firestore
          .collection('results')
          .doc(studentId)
          .collection('semesters')
          .doc(semester.toString());
      final doc = await semesterRef.get();
      if (!doc.exists) continue;
      List<dynamic> subjects = List.from(doc.data()?['subjects'] ?? []);
      // Update elective subject if exists
      for (int i = 0; i < subjects.length; i++) {
        if (subjects[i]['code'] == electiveSubjectCode &&
            subjects[i]['isElective'] == true) {
          subjects[i] = {
            ...subjects[i],
            ...updatedData,
          };
        }
      }
      batch.update(semesterRef, {
        'subjects': subjects,
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastUpdatedBy': FirebaseAuth.instance.currentUser?.uid,
        'lastUpdatedByRole': 'Admin',
      });
    }
    await batch.commit();
  }

  // New helper: get students by group (assuming students docs include a 'group' field)
  Future<List<Map<String, dynamic>>> getStudentsByGroup(String group) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'Student')
        .where('group', isEqualTo: group)
        .get();

    return snapshot.docs.map((d) => d.data() as Map<String, dynamic>).toList();
  }
}
