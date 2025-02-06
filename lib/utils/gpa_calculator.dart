import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GPACalculator {
  static final Map<String, double> gradePoints = {
    'A': 4.0,
    'A-': 3.7,
    'B+': 3.3,
    'B': 3.0,
    'B-': 2.7,
    'C+': 2.3,
    'C': 2.0,
    'C-': 1.7,
    'D+': 1.3,
    'D': 1.0,
    'D-': 0.7,
    'F': 0.0,
  };

  static Future<Map<String, double>> calculateOverallGPA() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    double totalPoints = 0;
    double totalCredits = 0;

    try {
      // Get all semesters for the user
      QuerySnapshot semestersSnapshot = await FirebaseFirestore.instance
          .collection('results')
          .doc(userId)
          .collection('semesters')
          .get();

      for (var semDoc in semestersSnapshot.docs) {
        Map<String, dynamic> semData = semDoc.data() as Map<String, dynamic>;
        List<dynamic> subjects = semData['subjects'] ?? [];

        for (var subject in subjects) {
          double credits = (subject['credits'] ?? 4).toDouble();
          String grade = subject['grade'] ?? 'F';
          double points = gradePoints[grade] ?? 0.0;

          totalPoints += credits * points;
          totalCredits += credits;
        }
      }

      double gpa = totalCredits > 0 ? totalPoints / totalCredits : 0.0;

      return {
        'gpa': double.parse(gpa.toStringAsFixed(2)),
        'totalCredits': totalCredits,
      };
    } catch (e) {
      print('Error calculating GPA: $e');
      return {'gpa': 0.0, 'totalCredits': 0.0};
    }
  }

  static Future<Map<String, double>> calculateSemesterGPA(int semester) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    double totalPoints = 0;
    double totalCredits = 0;

    try {
      DocumentSnapshot semDoc = await FirebaseFirestore.instance
          .collection('results')
          .doc(userId)
          .collection('semesters')
          .doc(semester.toString())
          .get();

      if (semDoc.exists) {
        Map<String, dynamic> semData = semDoc.data() as Map<String, dynamic>;
        List<dynamic> subjects = semData['subjects'] ?? [];

        for (var subject in subjects) {
          double credits = (subject['credits'] ?? 4).toDouble();
          String grade = subject['grade'] ?? 'F';
          double points = gradePoints[grade] ?? 0.0;

          totalPoints += credits * points;
          totalCredits += credits;
        }
      }

      double gpa = totalCredits > 0 ? totalPoints / totalCredits : 0.0;

      return {
        'gpa': double.parse(gpa.toStringAsFixed(2)),
        'totalCredits': totalCredits,
      };
    } catch (e) {
      print('Error calculating semester GPA: $e');
      return {'gpa': 0.0, 'totalCredits': 0.0};
    }
  }
}
