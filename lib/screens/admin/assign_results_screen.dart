import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/results_service.dart';
import 'subject_results_dialog.dart';
import 'results_management/semester_template_screen.dart';
import 'subjects/department_subjects_screen.dart';
import 'subjects/subject_selection_dialog.dart';

class AssignResultsScreen extends StatefulWidget {
  const AssignResultsScreen({super.key});

  @override
  _AssignResultsScreenState createState() => _AssignResultsScreenState();
}

class _AssignResultsScreenState extends State<AssignResultsScreen> {
  final ResultsService _resultsService = ResultsService();
  String selectedDepartment = 'All';
  int selectedSemester = 1;
  // Updated departments list to include 'General'
  final List<String> departments = ['All', 'General', 'CE', 'ECE', 'ME', 'IE'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String selectedAcademicYear = 'All';
  // Update academic years list to match Firebase data
  List<String> academicYears = ['All', 'GN', '1st', '2nd', '3rd', '4th'];
  // Add new state variable
  Set<String> selectedStudentIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Updated query to properly fetch student data
  Stream<QuerySnapshot> getStudentsStream() {
    Query query = FirebaseFirestore.instance.collection('users').where('role',
        isEqualTo:
            'Student'); // Changed 'student' to 'Student' to match creation

    if (selectedDepartment != 'All') {
      query = query.where('department', isEqualTo: selectedDepartment);
    }

    if (selectedAcademicYear != 'All') {
      query = query.where('academicYear', isEqualTo: selectedAcademicYear);
    }

    return query.snapshots();
  }

  // Filter students based on search query
  List<QueryDocumentSnapshot> filterStudents(
      List<QueryDocumentSnapshot> students) {
    if (_searchQuery.isEmpty) return students;

    return students.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final id = data['id']?.toString().toLowerCase() ?? '';
      final firstName = data['firstName']?.toString().toLowerCase() ?? '';
      final lastName = data['lastName']?.toString().toLowerCase() ?? '';

      final query = _searchQuery.toLowerCase();
      return id.contains(query) ||
          firstName.contains(query) ||
          lastName.contains(query);
    }).toList();
  }

  // Replace _getDefaultSubjects with this new method
  Future<List<Map<String, dynamic>>> _getDepartmentSubjects(
      String department) async {
    final subjects = await _resultsService.getDepartmentSubjects(department);
    return subjects.map((subject) {
      return {
        "code": subject["code"],
        "name": subject["name"],
        "credits": subject["credits"] ?? 4,
        "grade": "F", // Default grade
        "points": 0.0, // Default points
        "scores": {
          "week5": 0.0,
          "week10": 0.0,
          "coursework": subject["hasCoursework"] ? 0.0 : null,
          "lab": subject["hasLab"] ? 0.0 : null,
        },
      };
    }).toList();
  }

  // Simple mapping from grade to points
  double _gradeToPoints(String grade) {
    switch (grade) {
      case 'A':
        return 4.0;
      case 'B':
        return 3.0;
      case 'C':
        return 2.0;
      case 'D':
        return 1.0;
      default:
        return 0.0;
    }
  }

  Future<void> _showSubjectResultsDialog(BuildContext context, String userId,
      Map<String, dynamic> subject, int index) async {
    if (!context.mounted) return;

    try {
      if (!await _resultsService.isUserAdmin()) {
        throw Exception('Only admins can modify results');
      }

      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) => SubjectResultsDialog(
          subject: subject,
          onSave: (updatedSubject) async {
            try {
              await _resultsService.updateSubjectResults(
                userId: userId,
                semesterId: selectedSemester.toString(),
                subjectIndex: index,
                updatedSubject: updatedSubject,
              );

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Results updated successfully")),
              );
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error updating results: $e")),
              );
            }
          },
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> assignResultsForStudent(
      BuildContext context, String userId) async {
    if (!context.mounted) return;

    try {
      if (!await _resultsService.isUserAdmin()) {
        throw Exception('Only admins can assign results');
      }

      // Get student data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw Exception('Student not found');
      }

      final userData = userDoc.data()!;

      // Show subject selection dialog first
      if (!context.mounted) return;
      final currentSubjects = await _resultsService.getStudentSubjects(
        userId,
        selectedSemester.toString(),
      );

      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => SubjectSelectionDialog(
          userId: userId,
          department: userData['department'],
          semester: selectedSemester,
          initiallySelectedSubjects: currentSubjects,
        ),
      );

      if (shouldContinue != true || !mounted) return;

      // Initialize results document
      DocumentReference resultDoc = FirebaseFirestore.instance
          .collection('results')
          .doc(userId)
          .collection('semesters')
          .doc(selectedSemester.toString());

      // Get subjects from department instead of default subjects
      final subjects = await _getDepartmentSubjects(userData['department']);

      // Create/update the results document
      await resultDoc.set({
        "semesterNumber": selectedSemester,
        "department": userData['department'],
        "lastUpdated": FieldValue.serverTimestamp(),
        "subjects": subjects,
      }, SetOptions(merge: true));

      // Show subjects editor
      if (!context.mounted) return;
      final results = await _resultsService.getSemesterResults(
          userId, selectedSemester.toString());

      if (!context.mounted) return;
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext sheetContext) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Editing results for ${userData['firstName']} ${userData['lastName']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: results?['subjects']?.length ?? 0,
                    itemBuilder: (BuildContext listContext, index) {
                      final subject = results!['subjects'][index];
                      return Card(
                        child: ListTile(
                          title: Text(subject['name']),
                          subtitle: Text(
                              '${subject['code']}\nGrade: ${subject['grade']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showSubjectResultsDialog(
                                listContext, userId, subject, index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // New method to assign grades (modify subject results)
  Future<void> _assignGradesForStudent(
      BuildContext context, String userId) async {
    if (!context.mounted) return;
    try {
      // Ensure admin privileges
      if (!await _resultsService.isUserAdmin()) {
        throw Exception('Only admins can modify results');
      }
      // Get student data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!userDoc.exists) throw Exception('Student not found');
      final userData = userDoc.data()!;

      // Retrieve or initialize results document for the selected semester
      DocumentReference resultDoc = FirebaseFirestore.instance
          .collection('results')
          .doc(userId)
          .collection('semesters')
          .doc(selectedSemester.toString());
      var results = await _resultsService.getSemesterResults(
          userId, selectedSemester.toString());
      if (results == null) {
        // Initialize with department subjects if missing
        final subjects = await _getDepartmentSubjects(userData['department']);
        await resultDoc.set({
          "semesterNumber": selectedSemester,
          "department": userData['department'],
          "lastUpdated": FieldValue.serverTimestamp(),
          "subjects": subjects,
        }, SetOptions(merge: true));
        results = await _resultsService.getSemesterResults(
            userId, selectedSemester.toString());
      }
      // Show bottom sheet to assign grades (similar UI to earlier implementation)
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext sheetContext) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Assign Grades for ${userData['firstName']} ${userData['lastName']}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: results?['subjects']?.length ?? 0,
                    itemBuilder: (BuildContext listCtx, index) {
                      final subject = results!['subjects'][index];
                      return Card(
                        child: ListTile(
                          title: Text(subject['name']),
                          subtitle: Text(
                              '${subject['code']}\nGrade: ${subject['grade']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showSubjectResultsDialog(
                                listCtx, userId, subject, index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // New method to modify subjects (add, remove or update elective subjects)
  Future<void> _modifySubjectsForStudent(
      BuildContext context, String userId) async {
    if (!context.mounted) return;
    try {
      // Ensure admin privileges
      if (!await _resultsService.isUserAdmin()) {
        throw Exception('Only admins can modify subjects');
      }
      // Get student data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!userDoc.exists) throw Exception('Student not found');
      final userData = userDoc.data()!;

      // Open subject selection dialog to modify elective subjects
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (_) {
          // Get subjects before showing dialog
          return FutureBuilder<List<dynamic>>(
            future: _resultsService.getStudentSubjects(
                userId, selectedSemester.toString()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: Text('${snapshot.error}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Close'),
                    ),
                  ],
                );
              }
              return SubjectSelectionDialog(
                userId: userId,
                department: userData['department'],
                semester: selectedSemester,
                initiallySelectedSubjects:
                    (snapshot.data as List<dynamic>?)?.cast<String>() ?? [],
              );
            },
          );
        },
      );
      // Optionally show message if update occurred
      if (shouldContinue == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subjects updated successfully')));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Add selection methods
  void toggleStudentSelection(String studentId) {
    setState(() {
      if (selectedStudentIds.contains(studentId)) {
        selectedStudentIds.remove(studentId);
      } else {
        selectedStudentIds.add(studentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Results"),
        backgroundColor: Colors.blue,
        actions: [
          // Add template management
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SemesterTemplateScreen(
                    department: selectedDepartment,
                    semester: selectedSemester,
                  ),
                ),
              );
            },
          ),
          // Add subjects management
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () {
              if (selectedDepartment == 'All') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please select a department first')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DepartmentSubjectsScreen(
                    department: selectedDepartment,
                  ),
                ),
              );
            },
          ),
          // Add export/import
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Export Results'),
                onTap: () async {
                  final data = await _resultsService.exportResults(
                    selectedDepartment,
                    selectedSemester,
                  );
                  // Handle export data (e.g., save to file)
                },
              ),
              PopupMenuItem(
                child: const Text('Import Results'),
                onTap: () {
                  // Show file picker and import data
                },
              ),
              PopupMenuItem(
                child: const Text('Batch Assign'),
                onTap: () => _showBatchAssignDialog(context),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Student ID...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Filters Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Department Dropdown
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: DropdownButtonFormField<String>(
                          value: selectedDepartment,
                          decoration: const InputDecoration(
                            labelText: "Department",
                            border: OutlineInputBorder(),
                          ),
                          items: departments
                              .map((dept) => DropdownMenuItem(
                                    value: dept,
                                    child: Text(dept),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedDepartment = val!;
                            });
                          },
                        ),
                      ),
                    ),
                    // Updated Academic Year Dropdown
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 2.0),
                        child: DropdownButtonFormField<String>(
                          value: selectedAcademicYear,
                          decoration: const InputDecoration(
                            labelText: "Academic Year",
                            border: OutlineInputBorder(),
                          ),
                          items: academicYears
                              .map((year) => DropdownMenuItem(
                                    value: year,
                                    child:
                                        Text(year == 'GN' ? 'General' : year),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedAcademicYear = val!;
                            });
                          },
                        ),
                      ),
                    ),
                    // Semester Dropdown
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedSemester,
                        decoration: const InputDecoration(
                          labelText: "Semester",
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(
                          10,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text("Sem ${index + 1}"),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            selectedSemester = val!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Fetch and list student documents stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getStudentsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(
                      "Error fetching data: ${snapshot.error}"); // Added debug print
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = filterStudents(snapshot.data?.docs ?? []);
                if (docs.isEmpty) {
                  return const Center(child: Text("No students found."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final userData = docs[index].data() as Map<String, dynamic>;
                    final firstName =
                        userData['firstName'] as String? ?? 'No Name';
                    final lastName = userData['lastName'] as String? ?? '';
                    final studentId = docs[index].id;
                    final department =
                        userData['department'] as String? ?? 'No Dept';
                    final academicYear =
                        userData['academicYear'] as String? ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: SizedBox(
                          width: 32,
                          child: Checkbox(
                            value: selectedStudentIds.contains(studentId),
                            onChanged: (_) => toggleStudentSelection(studentId),
                          ),
                        ),
                        title: Text(
                          "$firstName $lastName",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          "ID: ${userData['id']}\nDepartment: $department • Year: $academicYear",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Container(
                          width: 200, // Fixed width for buttons container
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    minimumSize: const Size(0, 36),
                                  ),
                                  icon: const Icon(Icons.grade, size: 16),
                                  label: const Text(
                                    "Grades",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  onPressed: () => _assignGradesForStudent(
                                      context, studentId),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: TextButton.icon(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    minimumSize: const Size(0, 36),
                                  ),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text(
                                    "Modify",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  onPressed: () => _modifySubjectsForStudent(
                                      context, studentId),
                                ),
                              ),
                            ],
                          ),
                        ),
                        horizontalTitleGap: 8,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBatchAssignDialog(BuildContext context) async {
    // Check if department is selected
    if (selectedDepartment == 'All') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a specific department first')),
      );
      return;
    }

    // Check if students are selected
    if (selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select students first')),
      );
      return;
    }

    // Verify all selected students are from the same department
    try {
      final selectedStudents = await Future.wait(selectedStudentIds.map((id) =>
          FirebaseFirestore.instance.collection('users').doc(id).get()));

      final differentDepartments = selectedStudents
          .where((doc) => doc.data()?['department'] != selectedDepartment)
          .toList();

      if (differentDepartments.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'All selected students must be from the selected department')),
        );
        return;
      }

      // Get department subjects instead of template
      final departmentSubjects =
          await _getDepartmentSubjects(selectedDepartment);

      if (departmentSubjects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No subjects found for selected department')),
        );
        return;
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Batch Assign Results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Department: $selectedDepartment'),
              Text('Selected Students: ${selectedStudentIds.length}'),
              Text('Available Subjects: ${departmentSubjects.length}'),
              const SizedBox(height: 8),
              const Text('This action will:'),
              const Text('• Initialize results for selected semester'),
              const Text('• Add all department subjects'),
              const Text('• Set default grades (F)'),
              const Text('• Initialize score structure'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _resultsService.batchAssignResults(
                    studentIds: selectedStudentIds.toList(),
                    department: selectedDepartment,
                    semester: selectedSemester,
                    subjects: departmentSubjects,
                  );
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Results assigned successfully')),
                  );
                  // Clear selections after successful batch assign
                  setState(() {
                    selectedStudentIds.clear();
                  });
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error assigning results: $e')),
                  );
                }
              },
              child: const Text('Assign'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying students: $e')),
      );
    }
  }
}
