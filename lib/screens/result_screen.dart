import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int selectedSemester = 1;
  List<List<Map<String, dynamic>>> semesterResults = [];

  @override
  void initState() {
    super.initState();
    _initializeSemesterData();
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
            "subjects": defaultSubjects.map((subject) => {
                  "code": subject["smallTitle"],
                  "name": subject["label"],
                  "credits": 4,  // default credit value; adjust as needed
                  "grade": subject["grade"],
                  "points": _gradeToPoints(subject["grade"]),
                  "scores": {
                    "week5": (subject["scores"] as List)[0]["score"],
                    "week10": (subject["scores"] as List)[1]["score"],
                    "coursework": (subject["scores"] as List)[2]["score"],
                    "lab": (subject["scores"] as List)[3]["score"],
                  }
                }).toList(),
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
    // Simple A=4, B=3, etc.
    switch (grade) {
      case 'A': return 4.0;
      case 'B': return 3.0;
      case 'C': return 2.0;
      case 'D': return 1.0;
      default:  return 0.0;
    }
  }

  // Helper: returns default subjects for a given semester using your pre-existing arrays.
  List<Map<String, dynamic>> _getDefaultSubjects(int semester) {
    List<List<Map<String, dynamic>>> allSemesters = _generateSemesterResults();
    return allSemesters.length >= semester ? allSemesters[semester - 1] : [];
  }

  // Existing hardcoded subject generator (contents elided)
  List<List<Map<String, dynamic>>> _generateSemesterResults() {
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
            {"label": "5th Week", "score": 8 + cardIndex},
            {"label": "10th Week", "score": 12 + cardIndex},
            {"label": "Course Work", "score": 10 + cardIndex},
            {"label": "Lab", "score": 10 + cardIndex}
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
            {"label": "5th Week", "score": 8 + cardIndex},
            {"label": "10th Week", "score": 12 + cardIndex},
            {"label": "Course Work", "score": 10 + cardIndex},
            {"label": "Lab", "score": 10 + cardIndex}
          ],
        };
      }),
      // Semester 3
      List.generate(6, (cardIndex) {
        return {
          "label": [
            "Mathematics 3",
            "Modern Physics",
            "Electric Circuits 1",
            "Measuring Instruments and Electronic Transducers",
            "Structured Programming and Data Structures",
            "Technical Report Writing"
          ][cardIndex],
          "smallTitle": [
            "MAT 121",
            "PHY 121",
            "ECE 131",
            "ECE 133",
            "CE 101",
            "GNS 101"
          ][cardIndex],
          "grade": String.fromCharCode(65 + cardIndex),
          // A, B, C, D, E, F
          "color": getGradeColor(String.fromCharCode(65 + cardIndex)),
          // Use the method to get the color
          "scores": [
            {"label": "5th Week", "score": 8 + cardIndex},
            {"label": "10th Week", "score": 12 + cardIndex},
            {"label": "Course Work", "score": 10 + cardIndex},
            {"label": "Lab", "score": 10 + cardIndex}
          ],
        };
      }),
      // Semester 4
      List.generate(6, (cardIndex) {
        return {
          "label": [
            "Mathematics 4",
            "Electric Circuits 2",
            "Basic Electronics",
            "Electric Energy Sources and Applications",
            "Fundamentals of Logic Design",
            "Word Processing"
          ][cardIndex],
          "smallTitle": [
            "MAT 132",
            "ECE 132",
            "ECE 142",
            "EME 132",
            "CE 112",
            "GNS 102"
          ][cardIndex],
          "grade": String.fromCharCode(65 + cardIndex),
          // A, B, C, D, E, F
          "color": getGradeColor(String.fromCharCode(65 + cardIndex)),
          // Use the method to get the color
          "scores": [
            {"label": "5th Week", "score": 8 + cardIndex},
            {"label": "10th Week", "score": 12 + cardIndex},
            {"label": "Course Work", "score": 10 + cardIndex},
            {"label": "Lab", "score": 10 + cardIndex}
          ],
        };
      }),
      // Semester 5
      List.generate(6, (cardIndex) {
        return {
          "label": [
            "Special Functions and Integral Transforms",
            "Introduction to Discrete Mathematics",
            "Advanced Algorithms",
            "Electronics Circuits",
            "Digital Electronics",
            "Engineering Problems of the Environment 1"
          ][cardIndex],
          "smallTitle": [
            "MAT 241",
            "MAT 271",
            "CE 201",
            "ECE 241",
            "ECE 243",
            "EN 211"
          ][cardIndex],
          "grade": String.fromCharCode(65 + cardIndex),
          // A, B, C, D, E, F
          "color": getGradeColor(String.fromCharCode(65 + cardIndex)),
          // Use the method to get the color
          "scores": [
            {"label": "5th Week", "score": 8 + cardIndex},
            {"label": "10th Week", "score": 12 + cardIndex},
            {"label": "Course Work", "score": 10 + cardIndex},
            {"label": "Lab", "score": 10 + cardIndex}
          ],
        };
      }),
      // Semester 6
      List.generate(6, (cardIndex) {
        return {
          "label": [
            "Introduction to Probability and Statistics",
            "Database Systems",
            "Digital Systems Design",
            "Mechanical Engineering",
            "Civil Engineering",
            "Engineering Problems of the Environment 2"
          ][cardIndex],
          "smallTitle": [
            "MAT 252",
            "CE 232",
            "CE 212",
            "ME 252",
            "CIE 202",
            "EN 212"
          ][cardIndex],
          "grade": String.fromCharCode(65 + cardIndex),
          // A, B, C, D, E, F
          "color": getGradeColor(String.fromCharCode(65 + cardIndex)),
          // Use the method to get the color
          "scores": [
            {"label": "5th Week", "score": 8 + cardIndex},
            {"label": "10th Week", "score": 12 + cardIndex},
            {"label": "Course Work", "score": 10 + cardIndex},
            {"label": "Lab", "score": 10 + cardIndex}
          ],
        };
      }),
      // Semester 7
      List.generate(6, (cardIndex) {
        return {
          "label": [
            "Numerical Methods",
            "System Programming",
            "Introduction to Microprocessors",
            "Digital Signal Processing",
            "Communication Theory and Systems",
            "Operations Research and Industrial Planning"
          ][cardIndex],
          "smallTitle": [
            "MAT 361",
            "CE 321",
            "CE 311",
            "ECE 355",
            "ECE 357",
            "EM 311"
          ][cardIndex],
          "grade": String.fromCharCode(65 + cardIndex),
          // A, B, C, D, E, F
          "color": getGradeColor(String.fromCharCode(65 + cardIndex)),
          // Use the method to get the color
          "scores": [
            {"label": "5th Week", "score": 8 + cardIndex},
            {"label": "10th Week", "score": 12 + cardIndex},
            {"label": "Course Work", "score": 10 + cardIndex},
            {"label": "Lab", "score": 10 + cardIndex}
          ],
        };
      }),
      // Semester 8
      List.generate(6, (cardIndex) {
        return {
          "label": [
            "Information Technology",
            "Computer Architecture",
            "Operating Systems",
            "Microprocessor Interfacing",
            "Control Systems Theory and Design / Formal Languages",
            "Introduction to Marketing"
          ][cardIndex],
          "smallTitle": [
            "CE 304",
            "CE 314",
            "CE 322",
            "CE 312",
            "ECE 382 / CE 302",
            "EM 322"
          ][cardIndex],
          "grade": String.fromCharCode(65 + cardIndex),
          // A, B, C, D, E, F
          "color": getGradeColor(String.fromCharCode(65 + cardIndex)),
          // Use the method to get the color
          "scores": [
            {"label": "5th Week", "score": 8 + cardIndex},
            {"label": "10th Week", "score": 12 + cardIndex},
            {"label": "Course Work", "score": 10 + cardIndex},
            {"label": "Lab", "score": 10 + cardIndex}
          ],
        };
      }),
      // Semester 9
      List.generate(6, (cardIndex) {
        return {
          "label": [
            "Introduction to Artificial Intelligence",
            "Software Engineering",
            "Application of Real Time Computer Systems",
            "Introduction to Computer Vision / Distributed Systems",
            "Engineering Economy",
            "Project 1"
          ][cardIndex],
          "smallTitle": [
            "CE 433",
            "CE 401",
            "CE 411",
            "CE 435 / CE 413",
            "EM 431",
            "CE 491"
          ][cardIndex],
          "grade": String.fromCharCode(65 + cardIndex),
          // A, B, C, D, E, F
          "color": getGradeColor(String.fromCharCode(65 + cardIndex)),
          // Use the method to get the color
          "scores": [
            {"label": "5th Week", "score": 8 + cardIndex},
            {"label": "10th Week", "score": 12 + cardIndex},
            {"label": "Course Work", "score": 10 + cardIndex},
            {"label": "Lab", "score": 10 + cardIndex}
          ],
        };
      }),
      // Semester 10
      List.generate(6, (cardIndex) {
        return {
          "label": [
            "Computer Network",
            "Image Processing",
            "Computer Graphics",
            "Computing System Evaluation / Expert System Applications",
            "Engineering Management",
            "Project 2"
          ][cardIndex],
          "smallTitle": [
            "CE 414",
            "ECE 454",
            "CE 402",
            "CE 404 / CE 406",
            "EM 442",
            "CE 492"
          ][cardIndex],
          "grade": String.fromCharCode(65 + cardIndex),
          // A, B, C, D, E, F
          "color": getGradeColor(String.fromCharCode(65 + cardIndex)),
          // Use the method to get the color
          "scores": [
            {"label": "5th Week", "score": 8 + cardIndex},
            {"label": "10th Week", "score": 12 + cardIndex},
            {"label": "Course Work", "score": 10 + cardIndex},
            {"label": "Lab", "score": 10 + cardIndex}
          ],
        };
      }),
    ];
  }

  // Step 2: Load semester documents and map them to UI structure.
  Future<List<List<Map<String, dynamic>>>> _loadSemesterData() async {
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
            List<Map<String, dynamic>> mappedSubjects = subjects.map<Map<String, dynamic>>((s) {
              return {
                "label": s["name"],
                "smallTitle": s["code"],
                "grade": s["grade"],
                "color": getGradeColor(s["grade"]),
                "scores": [
                  {"label": "5th Week", "score": (s["scores"]["week5"] as num).toDouble()},
                  {"label": "10th Week", "score": (s["scores"]["week10"] as num).toDouble()},
                  {"label": "Course Work", "score": (s["scores"]["coursework"] as num).toDouble()},
                  {"label": "Lab", "score": (s["scores"]["lab"] as num).toDouble()},
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

  Color getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return const Color(0xFFFF7D7D);
      case 'B':
        return const Color(0xFFFFDD29);
      case 'C':
        return const Color(0xFF978ECB);
      case 'D':
        return const Color(0xFF0ED290);
      case 'F':
        return const Color(0xFFED1C24);
      default:
        return Colors.grey; // Fallback color if needed
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Unable to load results\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
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
                  padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
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
                      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
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
                      const Text("Results",
                          style: TextStyle(
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
                              const Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 80,
                                        child: Center(
                                            child: Text("126.0",
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)))),
                                    SizedBox(height: 5),
                                    Text("Credit Achieved",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                              SizedBox(
                                  width: 3,
                                  height: 55,
                                  child: Container(color: Colors.grey)),
                              const Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 80,
                                        child: Center(
                                            child: Text("3.99",
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)))),
                                    SizedBox(height: 5),
                                    Text("GPA",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Semester",
                              style: TextStyle(
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
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: List.generate(10, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSemester = index + 1;
                                    });
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
                    child: ListView(
                      children: semesterResults[selectedSemester - 1].map((result) {
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
                const SizedBox(height: 10), // Add spacing above the divider

                // Adjusted Divider with reduced length on the right side
                const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1.75,
                        color: kLightGrey,
                      ),
                    ),
                    SizedBox(
                        width:
                            73), // Adjust this to control the shortening on the right
                  ],
                ),

                const SizedBox(
                    height: 5), // Add spacing below the divider if needed

                // Scores Row (horizontal layout)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(scores.length, (index) {
                    List<Widget> scoreWidgets = [
                      Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              "${scores[index]['score'].toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width *
                                    0.04, // Scale font size with screen width
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
                    ];

                    if (index < scores.length - 1) {
                      scoreWidgets.add(const SizedBox(
                        width: 13,
                        height: 30,
                        child: VerticalDivider(
                          color: kLightGrey,
                          thickness: 2.5,
                        ),
                      ));
                    }

                    return Row(children: scoreWidgets);
                  }),
                ),
                const SizedBox(height: 7),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 8, // Align to the bottom of the card
          right: 0,
          child: Container(
            height: MediaQuery.of(context).size.width *
                0.18, // Scale height with screen width
            width: MediaQuery.of(context).size.width *
                0.18, // Scale width with screen width
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
                  fontSize: MediaQuery.of(context).size.width *
                      0.1, // Scale font size with screen width
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
}
