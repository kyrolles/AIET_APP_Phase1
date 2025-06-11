import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../utils/gpa_calculator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int selectedSemester = 1;
  List<List<Map<String, dynamic>>> semesterResults = [];
  double overallGPA = 0.0;
  double totalCredits = 0.0;
  double semesterGPA = 0.0;
  double semesterCredits = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeSemesterData();
    _loadGPAData();
  }

  // Step 1: Create Firestore docs if missing for semesters 1-10
  Future<void> _initializeSemesterData() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unauthenticated',
          message: 'User must be logged in to view results',
        );
      }

      // In production, fetch the user's department from the users document
      String department = "CE";

      // First verify if the user has any results
      DocumentSnapshot userResultCheck = await FirebaseFirestore.instance
          .collection('results')
          .doc(userId)
          .get();

      if (!userResultCheck.exists) {
        // Optional: You can throw an exception here or handle the case where user has no results
        print('No results found for this user');
        return;
      }

      for (int sem = 1; sem <= 10; sem++) {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('results')
            .doc(userId)
            .collection('semesters')
            .doc(sem.toString());
        DocumentSnapshot docSnap = await docRef.get();
        if (!docSnap.exists) {
          List<Map<String, dynamic>> defaultSubjects = _getDefaultSubjects(sem);
          // Map hardcoded fields to our document structure
          await docRef.set({
            "semesterNumber": sem,
            "department": department,
            "lastUpdated": FieldValue.serverTimestamp(),
            "subjects": defaultSubjects
                .map((subject) => {
                      "code": subject["smallTitle"],
                      "name": subject["label"],
                      "credits": 4, // default credit value; adjust as needed
                      "grade": subject["grade"],
                      "points": _gradeToPoints(subject["grade"]),
                      "totalPoints": _calculateTotalPoints(subject),
                      "scores": {
                        "week5": (subject["scores"] as List)[0]["score"],
                        "maxWeek5": 8.0,
                        "week10": (subject["scores"] as List)[1]["score"],
                        "maxWeek10": 12.0,
                        "classwork": (subject["scores"] as List).length > 2
                            ? (subject["scores"] as List)[2]["score"]
                            : 0.0,
                        "maxClasswork": 10.0,
                        "labExam": (subject["scores"] as List).length > 3
                            ? (subject["scores"] as List)[3]["score"]
                            : 0.0,
                        "maxLabExam": 10.0,
                        "finalExam":
                            0.0, // Default to 0 since this is new in the format
                        "maxFinalExam": 60.0,
                      }
                    })
                .toList(),
          });
        }
      }
    } catch (e) {
      print('Error initializing semester data: $e');
      // You might want to rethrow or handle the error appropriately
      rethrow;
    }
  }

  double _gradeToPoints(String grade) {
    // Map to standard GPA points
    switch (grade.toUpperCase()) {
      case 'A+':
        return 4.0;
      case 'A':
        return 4.0;
      case 'A-':
        return 3.7;
      case 'B+':
        return 3.3;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.7;
      case 'C+':
        return 2.3;
      case 'C':
        return 2.0;
      case 'C-':
        return 1.7;
      case 'D+':
        return 1.3;
      case 'D':
        return 1.0;
      default:
        return 0.0;
    }
  }

  // Helper: returns default subjects for a given semester using your pre-existing arrays.
  List<Map<String, dynamic>> _getDefaultSubjects(int semester) {
    List<List<Map<String, dynamic>>> allSemesters = _generateSemesterResults();
    return allSemesters.length >= semester ? allSemesters[semester - 1] : [];
  }

  // Existing hardcoded subject generator (contents elided)
  List<List<Map<String, dynamic>>> _generateSemesterResults() {
    final localizations = AppLocalizations.of(context);
    String week5Label = localizations?.week5 ?? "5th Week";
    String week10Label = localizations?.week10 ?? "10th Week";
    String courseWorkLabel = localizations?.courseWork ?? "Course Work";
    String labExamLabel = localizations?.labExam ?? "Lab Exam";

    return [
      // Semester 1
      List.generate(7, (cardIndex) {
        return {
          "label": [
            "Mathematics 1",
            "Physics 1",
            "Mechanics 1",
            "Engineering Graphics and Projection",
            "Chemistry",
            "Introduction to Computer Systems",
            "English Language 1"
          ][cardIndex],
          "smallTitle": [
            "MAT 001",
            "PHY 001",
            "ME 001",
            "ME 011",
            "CHE 001",
            "CE 001",
            "LAN 001"
          ][cardIndex],
          "grade": String.fromCharCode(65 + cardIndex),
          // A, B, C, D, E, F
          "color": getGradeColor(String.fromCharCode(65 + cardIndex)),
          // Use the method to get the color
          "scores": [
            {"label": week5Label, "score": 8 + cardIndex},
            {"label": week10Label, "score": 12 + cardIndex},
            {"label": courseWorkLabel, "score": 10 + cardIndex},
            {"label": labExamLabel, "score": 10 + cardIndex}
          ],
        };
      }),
      // Semester 2
      List.generate(6, (cardIndex) {
        return {
          "label": [
            "Mathematics 2",
            "Physics 2",
            "Mechanics 2",
            "Production Technology",
            "Computer Programming",
            "English Language 2"
          ][cardIndex],
          "smallTitle": [
            "MAT 012",
            "PHY 012",
            "ME 002",
            "ME 022",
            "CE 002",
            "LAN 002"
          ][cardIndex],
          "grade": String.fromCharCode(65 + cardIndex),
          // A, B, C, D, E, F
          "color": getGradeColor(String.fromCharCode(65 + cardIndex)),
          // Use the method to get the color
          "scores": [
            {"label": week5Label, "score": 8 + cardIndex},
            {"label": week10Label, "score": 12 + cardIndex},
            {"label": courseWorkLabel, "score": 10 + cardIndex},
            {"label": labExamLabel, "score": 10 + cardIndex}
          ],
        };
      }),
      // Other semesters would follow the same pattern...
      // For brevity, just including first 2 semesters in this example
    ];
  }

  // Step 2: Load semester documents and map them to UI structure.
  Future<List<List<Map<String, dynamic>>>> _loadSemesterData() async {
    final localizations = AppLocalizations.of(context);
    String week5Label = localizations?.week5 ?? "5th Week";
    String week10Label = localizations?.week10 ?? "10th Week";
    String courseWorkLabel = localizations?.courseWork ?? "Course Work";
    String labExamLabel = localizations?.labExam ?? "Lab Exam";
    String finalExamLabel = localizations?.finalExam ?? "Final Exam";

    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unauthenticated',
          message: 'User must be logged in to view results',
        );
      }

      List<List<Map<String, dynamic>>> semestersData = [];
      for (int sem = 1; sem <= 10; sem++) {
        try {
          DocumentSnapshot doc = await FirebaseFirestore.instance
              .collection('results')
              .doc(userId)
              .collection('semesters')
              .doc(sem.toString())
              .get();

          if (doc.exists) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            List subjects = data['subjects'] ?? [];
            // Map Firestore subject to UI format:
            List<Map<String, dynamic>> mappedSubjects =
                subjects.map<Map<String, dynamic>>((s) {
              return {
                "label": s["name"],
                "smallTitle": s["code"],
                "grade": s["grade"],
                "color": getGradeColor(s["grade"]),
                "scores": [
                  {
                    "label": week5Label,
                    "score": (s["scores"]["week5"] as num?)?.toDouble() ?? 0.0
                  },
                  {
                    "label": week10Label,
                    "score": (s["scores"]["week10"] as num?)?.toDouble() ?? 0.0
                  },
                  {
                    "label": courseWorkLabel,
                    "score": (s["scores"]["classwork"] as num?)?.toDouble() ??
                        (s["scores"]["coursework"] as num?)?.toDouble() ??
                        0.0
                  },
                  {
                    "label": labExamLabel,
                    "score": (s["scores"]["labExam"] as num?)?.toDouble() ??
                        (s["scores"]["lab"] as num?)?.toDouble() ??
                        0.0
                  },
                  {
                    "label": finalExamLabel,
                    "score":
                        (s["scores"]["finalExam"] as num?)?.toDouble() ?? 0.0
                  },
                ],
              };
            }).toList();
            semestersData.add(mappedSubjects);
          } else {
            semestersData.add([]);
          }
        } catch (e) {
          print('Error loading semester $sem: $e');
          semestersData.add([]); // Add empty semester on error
        }
      }
      return semestersData;
    } catch (e) {
      print('Error loading semester data: $e');
      rethrow;
    }
  }

  Future<void> _loadGPAData() async {
    var overall = await GPACalculator.calculateOverallGPA();
    var semester = await GPACalculator.calculateSemesterGPA(selectedSemester);

    setState(() {
      overallGPA = overall['gpa'] ?? 0.0;
      totalCredits = overall['totalCredits'] ?? 0.0;
      semesterGPA = semester['gpa'] ?? 0.0;
      semesterCredits = semester['totalCredits'] ?? 0.0;
    });
  }

  void onSemesterSelected(int semester) {
    setState(() {
      selectedSemester = semester;
    });
    _loadGPAData(); // Reload GPA data when semester changes
  }

  Color getGradeColor(String grade) {
    grade = grade.toUpperCase();
    if (grade.startsWith('A')) {
      return const Color(0xFFFF7D7D); // Red for A+, A, A-
    } else if (grade.startsWith('B')) {
      return const Color(0xFFFFDD29); // Yellow for B+, B, B-
    } else if (grade.startsWith('C')) {
      return const Color(0xFF978ECB); // Purple for C+, C, C-
    } else if (grade.startsWith('D')) {
      return const Color(0xFF0ED290); // Green for D+, D, D-
    } else if (grade == 'F') {
      return const Color(0xFFED1C24); // Bright Red for F
    } else {
      return Colors.grey; // Fallback color
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return FutureBuilder<List<List<Map<String, dynamic>>>>(
      future: _loadSemesterData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    localizations?.unableToLoadResults ??
                        "Unable to load results\n${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(localizations?.goBack ?? 'Go Back'),
                  ),
                ],
              ),
            ),
          );
        } else {
          semesterResults = snapshot.data ?? [];
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      top: 40, left: 16, right: 16, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 1,
                          offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 5))
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new),
                                onPressed: () => Navigator.pop(context),
                                splashColor: Colors.transparent,
                              ),
                            ),
                          ]),
                      Text(localizations?.results ?? "Results",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 5),
                      Center(
                        child: Container(
                          width: 270,
                          decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 80,
                                        child: Center(
                                            child: Text(
                                                totalCredits.toStringAsFixed(1),
                                                style: const TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)))),
                                    const SizedBox(height: 5),
                                    Text(
                                        localizations?.creditAchieved ??
                                            "Credit Achieved",
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                              SizedBox(
                                  width: 3,
                                  height: 55,
                                  child: Container(color: Colors.grey)),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 80,
                                        child: Center(
                                            child: Text(
                                                overallGPA.toStringAsFixed(2),
                                                style: const TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)))),
                                    const SizedBox(height: 5),
                                    Text(localizations?.gpa ?? "GPA",
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(localizations?.semester ?? "Semester",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black))),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: 360,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: List.generate(10, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    onSemesterSelected(index + 1);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: selectedSemester == index + 1
                                          ? Colors.orange
                                          : Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            spreadRadius: 1)
                                      ],
                                    ),
                                    child: Center(
                                      child: Text("${index + 1}",
                                          style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: semesterResults.isEmpty ||
                            selectedSemester > semesterResults.length ||
                            semesterResults[selectedSemester - 1].isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.school_outlined,
                                    size: 80, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  localizations == null
                                      ? 'No results available for Semester $selectedSemester'
                                      : localizations
                                          .noResultsAvailableForSemester(
                                              selectedSemester.toString()),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            children: semesterResults[selectedSemester - 1]
                                .map((result) {
                              return buildResultCard(
                                  result["label"],
                                  result["grade"],
                                  result["color"],
                                  result["scores"],
                                  result["smallTitle"] ?? "");
                            }).toList(),
                          ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildResultCard(String title, String grade, Color gradeColor,
      List<Map<String, dynamic>> scores, String smallTitle) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey[600]!, width: 0.85)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    smallTitle,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                ),
                Center(
                  child: Text(
                    title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),

                // Adjusted Divider with reduced length on the right side
                const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1.75,
                        color: kLightGrey,
                      ),
                    ),
                    SizedBox(width: 73),
                  ],
                ),

                const SizedBox(height: 5),

                // Scores Row with scrollable horizontal layout for all scores
                SizedBox(
                  height: 60, // Fixed height for the score row
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(scores.length, (index) {
                      return Row(
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  "${scores[index]['score'].toStringAsFixed(1)}",
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.03,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  scores[index]['label'],
                                  style: const TextStyle(
                                      color: Colors.lightBlue, fontSize: 8),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          if (index < scores.length - 1)
                            const SizedBox(
                              width: 13,
                              height: 30,
                              child: VerticalDivider(
                                color: kLightGrey,
                                thickness: 2.5,
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 7),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 0,
          child: Container(
            height: MediaQuery.of(context).size.width * 0.18,
            width: MediaQuery.of(context).size.width * 0.18,
            decoration: BoxDecoration(
              color: gradeColor,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                grade,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to calculate total points from scores
  double _calculateTotalPoints(Map<String, dynamic> subject) {
    double total = 0.0;
    List<dynamic> scores = subject["scores"] as List;

    // Add up all available scores
    for (var score in scores) {
      if (score != null && score["score"] != null) {
        total += (score["score"] as num).toDouble();
      }
    }

    return total;
  }
}
