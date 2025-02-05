import 'package:flutter/material.dart';

class SubjectsData {
  static List<List<Map<String, dynamic>>> getSubjectsForSemester() {
    return [
      // Semester 1
      _getSemester1Subjects(),
      // Semester 2
      _getSemester2Subjects(),
      // Semester 3
      _getSemester3Subjects(),
      // Semester 4
      _getSemester4Subjects(),
      // Semester 5
      _getSemester5Subjects(),
      // Semester 6
      _getSemester6Subjects(),
      // Semester 7
      _getSemester7Subjects(),
      // Semester 8
      _getSemester8Subjects(),
      // Semester 9
      _getSemester9Subjects(),
      // Semester 10
      _getSemester10Subjects(),
    ];
  }

  static List<Map<String, dynamic>> _getSemester1Subjects() {
    return List.generate(7, (index) {
      return {
        "label": _semester1Names[index],
        "smallTitle": _semester1Codes[index],
        "grade": "F", // Default grade
        "scores": _defaultScores,
      };
    });
  }

  static List<Map<String, dynamic>> _getSemester2Subjects() {
    return List.generate(6, (index) {
      return {
        "label": _semester2Names[index],
        "smallTitle": _semester2Codes[index],
        "grade": "F",
        "scores": _defaultScores,
      };
    });
  }

  // ...similar methods for semesters 3-10...

  static const Map<String, dynamic> _defaultScores = {
    "week5": 0.0,
    "week10": 0.0,
    "coursework": 0.0,
    "lab": 0.0,
  };

  // Semester 1 data
  static const List<String> _semester1Names = [
    "Mathematics 1",
    "Physics 1",
    "Mechanics 1",
    "Engineering Graphics and Projection",
    "Chemistry",
    "Introduction to Computer Systems",
    "English Language 1"
  ];

  static const List<String> _semester1Codes = [
    "MAT 001",
    "PHY 001",
    "ME 001",
    "ME 011",
    "CHE 001",
    "CE 001",
    "LAN 001"
  ];

  // Semester 2 data
  static const List<String> _semester2Names = [
    "Mathematics 2",
    "Physics 2",
    "Mechanics 2",
    "Production Technology",
    "Computer Programming",
    "English Language 2"
  ];

  static const List<String> _semester2Codes = [
    "MAT 012",
    "PHY 012",
    "ME 002",
    "ME 022",
    "CE 002",
    "LAN 002"
  ];

  // Semester 3 data
  static const List<String> _semester3Names = [
    "Mathematics 3",
    "Modern Physics",
    "Electric Circuits 1",
    "Measuring Instruments and Electronic Transducers",
    "Structured Programming and Data Structures",
    "Technical Report Writing"
  ];

  static const List<String> _semester3Codes = [
    "MAT 121",
    "PHY 121",
    "ECE 131",
    "ECE 133",
    "CE 101",
    "GNS 101"
  ];

  // Semester 4 data
  static const List<String> _semester4Names = [
    "Mathematics 4",
    "Electric Circuits 2",
    "Basic Electronics",
    "Electric Energy Sources and Applications",
    "Fundamentals of Logic Design",
    "Word Processing"
  ];

  static const List<String> _semester4Codes = [
    "MAT 132",
    "ECE 132",
    "ECE 142",
    "EME 132",
    "CE 112",
    "GNS 102"
  ];

  // Semester 5 data
  static const List<String> _semester5Names = [
    "Special Functions and Integral Transforms",
    "Introduction to Discrete Mathematics",
    "Advanced Algorithms",
    "Electronics Circuits",
    "Digital Electronics",
    "Engineering Problems of the Environment 1"
  ];

  static const List<String> _semester5Codes = [
    "MAT 241",
    "MAT 271",
    "CE 201",
    "ECE 241",
    "ECE 243",
    "EN 211"
  ];

  // Semester 6 data
  static const List<String> _semester6Names = [
    "Introduction to Probability and Statistics",
    "Database Systems",
    "Digital Systems Design",
    "Mechanical Engineering",
    "Civil Engineering",
    "Engineering Problems of the Environment 2"
  ];

  static const List<String> _semester6Codes = [
    "MAT 252",
    "CE 232",
    "CE 212",
    "ME 252",
    "CIE 202",
    "EN 212"
  ];

  // Semester 7 data
  static const List<String> _semester7Names = [
    "Numerical Methods",
    "System Programming",
    "Introduction to Microprocessors",
    "Digital Signal Processing",
    "Communication Theory and Systems",
    "Operations Research and Industrial Planning"
  ];

  static const List<String> _semester7Codes = [
    "MAT 361",
    "CE 321",
    "CE 311",
    "ECE 355",
    "ECE 357",
    "EM 311"
  ];

  // Semester 8 data
  static const List<String> _semester8Names = [
    "Information Technology",
    "Computer Architecture",
    "Operating Systems",
    "Microprocessor Interfacing",
    "Control Systems Theory and Design / Formal Languages",
    "Introduction to Marketing"
  ];

  static const List<String> _semester8Codes = [
    "CE 304",
    "CE 314",
    "CE 322",
    "CE 312",
    "ECE 382 / CE 302",
    "EM 322"
  ];

  // Semester 9 data
  static const List<String> _semester9Names = [
    "Introduction to Artificial Intelligence",
    "Software Engineering",
    "Application of Real Time Computer Systems",
    "Introduction to Computer Vision / Distributed Systems",
    "Engineering Economy",
    "Project 1"
  ];

  static const List<String> _semester9Codes = [
    "CE 433",
    "CE 401",
    "CE 411",
    "CE 435 / CE 413",
    "EM 431",
    "CE 491"
  ];

  // Semester 10 data
  static const List<String> _semester10Names = [
    "Computer Network",
    "Image Processing",
    "Computer Graphics",
    "Computing System Evaluation / Expert System Applications",
    "Engineering Management",
    "Project 2"
  ];

  static const List<String> _semester10Codes = [
    "CE 414",
    "ECE 454",
    "CE 402",
    "CE 404 / CE 406",
    "EM 442",
    "CE 492"
  ];

  // Add helper methods for remaining semesters (3-10)
  static List<Map<String, dynamic>> _getSemester3Subjects() {
    return List.generate(_semester3Names.length, (index) {
      return {
        "label": _semester3Names[index],
        "smallTitle": _semester3Codes[index],
        "grade": "F",
        "scores": _defaultScores,
      };
    });
  }

  // ... similar methods for semesters 4-10 ...
  static List<Map<String, dynamic>> _getSemester4Subjects() {
    return _generateSubjects(_semester4Names, _semester4Codes);
  }

  static List<Map<String, dynamic>> _getSemester5Subjects() {
    return _generateSubjects(_semester5Names, _semester5Codes);
  }

  static List<Map<String, dynamic>> _getSemester6Subjects() {
    return _generateSubjects(_semester6Names, _semester6Codes);
  }

  static List<Map<String, dynamic>> _getSemester7Subjects() {
    return _generateSubjects(_semester7Names, _semester7Codes);
  }

  static List<Map<String, dynamic>> _getSemester8Subjects() {
    return _generateSubjects(_semester8Names, _semester8Codes);
  }

  static List<Map<String, dynamic>> _getSemester9Subjects() {
    return _generateSubjects(_semester9Names, _semester9Codes);
  }

  static List<Map<String, dynamic>> _getSemester10Subjects() {
    return _generateSubjects(_semester10Names, _semester10Codes);
  }

  // Helper method to generate subjects
  static List<Map<String, dynamic>> _generateSubjects(List<String> names, List<String> codes) {
    return List.generate(names.length, (index) {
      return {
        "label": names[index],
        "smallTitle": codes[index],
        "grade": "F",
        "scores": _defaultScores,
      };
    });
  }

  static Color getGradeColor(String grade) {
    switch (grade) {
      case 'A': return const Color(0xFFFF7D7D);
      case 'B': return const Color(0xFFFFDD29);
      case 'C': return const Color(0xFF978ECB);
      case 'D': return const Color(0xFF0ED290);
      case 'F': return const Color(0xFFED1C24);
      default: return Colors.grey;
    }
  }
}
