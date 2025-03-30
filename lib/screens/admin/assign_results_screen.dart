import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../components/kbutton.dart';
import '../../constants.dart';
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
  final List<String> departments = ['All', 'General', 'CE', 'ECE', 'ME', 'IE'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String selectedAcademicYear = 'All';
  List<String> academicYears = ['All', 'GN', '1st', '2nd', '3rd', '4th'];
  Set<String> selectedStudentIds = {};

  // For bulk operations
  bool _isBulkMode = false;
  String _bulkOperationType = 'Select Operation';
  final List<String> _bulkOperations = [
    'Select Operation',
    'Assign Subjects',
    'Update Grades',
    'Reset Scores'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> getStudentsStream() {
    Query query = FirebaseFirestore.instance.collection('users').where('role',
        isEqualTo: 'Student');

    if (selectedDepartment != 'All') {
      query = query.where('department', isEqualTo: selectedDepartment);
    }

    if (selectedAcademicYear != 'All') {
      query = query.where('academicYear', isEqualTo: selectedAcademicYear);
    }

    return query.snapshots();
  }

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

  Future<List<Map<String, dynamic>>> _getDepartmentSubjects(
      String department) async {
    final subjects = await _resultsService.getDepartmentSubjects(department);
    return subjects.map((subject) {
      return {
        "code": subject["code"],
        "name": subject["name"],
        "credits": subject["credits"] ?? 4,
        "grade": "F",
        "points": 0.0,
        "scores": {
          "week5": 0.0,
          "week10": 0.0,
          "coursework": subject["hasCoursework"] ? 0.0 : null,
          "lab": subject["hasLab"] ? 0.0 : null,
        },
      };
    }).toList();
  }

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
                const SnackBar(
                  content: Text("Results updated successfully"),
                  backgroundColor: kgreen,
                ),
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

      if (!context.mounted) return;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw Exception('Student not found');
      }

      final userData = userDoc.data()!;

      if (!context.mounted) return;
      final currentSubjects = await _resultsService.getStudentSubjects(
        userId,
        selectedSemester.toString(),
      );

      if (!context.mounted) return;
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => SubjectSelectionDialog(
          userId: userId,
          department: userData['department'],
          semester: selectedSemester,
          initiallySelectedSubjects: currentSubjects,
        ),
      );

      if (shouldContinue != true || !context.mounted) return;

      DocumentReference resultDoc = FirebaseFirestore.instance
          .collection('results')
          .doc(userId)
          .collection('semesters')
          .doc(selectedSemester.toString());

      final subjects = await _getDepartmentSubjects(userData['department']);

      await resultDoc.set({
        "semesterNumber": selectedSemester,
        "department": userData['department'],
        "lastUpdated": FieldValue.serverTimestamp(),
        "subjects": subjects,
      }, SetOptions(merge: true));

      if (!context.mounted) return;
      final results = await _resultsService.getSemesterResults(
          userId, selectedSemester.toString());

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Subjects assigned successfully"),
          backgroundColor: kgreen,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _assignGradesForStudent(
      BuildContext context, String userId) async {
    if (!context.mounted) return;
    try {
      if (!await _resultsService.isUserAdmin()) {
        throw Exception('Only admins can modify results');
      }
      
      if (!context.mounted) return;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
          
      if (!userDoc.exists) throw Exception('Student not found');
      final userData = userDoc.data()!;

      if (!context.mounted) return;
      DocumentReference resultDoc = FirebaseFirestore.instance
          .collection('results')
          .doc(userId)
          .collection('semesters')
          .doc(selectedSemester.toString());
          
      var results = await _resultsService.getSemesterResults(
          userId, selectedSemester.toString());
          
      if (!context.mounted) return;
      if (results == null) {
        final subjects = await _getDepartmentSubjects(userData['department']);
        
        await resultDoc.set({
          "semesterNumber": selectedSemester,
          "department": userData['department'],
          "lastUpdated": FieldValue.serverTimestamp(),
          "subjects": subjects,
        }, SetOptions(merge: true));
        
        if (!context.mounted) return;
        results = await _resultsService.getSemesterResults(
            userId, selectedSemester.toString());
      }

      if (!context.mounted) return;
      await _showGradesSheet(context, userId, userData, results);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showGradesSheet(
    BuildContext context,
    String userId,
    Map<String, dynamic> userData,
    Map<String, dynamic>? results,
  ) async {
    if (results == null || !results.containsKey('subjects')) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No subjects found for this student'),
        ),
      );
      return;
    }

    final List<dynamic> subjects = results['subjects'];
    
    if (!context.mounted) return;
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${userData['firstName']} ${userData['lastName']} - Semester $selectedSemester",
                      style: kTextStyleBold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: kLightGrey, width: 1),
                      ),
                      elevation: 0,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(
                          subject['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Lexend',
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Code: ${subject['code']}'),
                            Text('Grade: ${subject['grade']} (${subject['points']})'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: kBlue),
                              onPressed: () {
                                Navigator.pop(context);
                                _showSubjectResultsDialog(
                                    context, userId, subject, index);
                              },
                            ),
                          ],
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
  }

  Future<void> _processBulkOperation() async {
    if (selectedStudentIds.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select students first')),
      );
      return;
    }

    if (selectedDepartment == 'All') {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a specific department first')),
      );
      return;
    }

    // Verify all selected students are from the same department
    try {
      final selectedStudents = await Future.wait(selectedStudentIds.map((id) =>
          FirebaseFirestore.instance.collection('users').doc(id).get()));

      if (!context.mounted) return;
      
      final differentDepartments = selectedStudents
          .where((doc) => doc.data()?['department'] != selectedDepartment)
          .toList();

      if (differentDepartments.isNotEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'All selected students must be from the selected department')),
        );
        return;
      }

      // Perform the bulk operation based on type
      switch (_bulkOperationType) {
        case 'Assign Subjects':
          await _bulkAssignSubjects();
          break;
        case 'Update Grades':
          await _bulkUpdateGrades();
          break;
        case 'Reset Scores':
          await _bulkResetScores();
          break;
        default:
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an operation')),
          );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _bulkAssignSubjects() async {
    final departmentSubjects = await _getDepartmentSubjects(selectedDepartment);

    if (departmentSubjects.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No subjects found for selected department')),
      );
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Assign Subjects'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: kBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                Navigator.pop(context);
                
                await _resultsService.batchAssignResults(
                  studentIds: selectedStudentIds.toList(),
                  department: selectedDepartment,
                  semester: selectedSemester,
                  subjects: departmentSubjects,
                );
                
                if (!context.mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subjects assigned successfully'),
                    backgroundColor: kgreen,
                  ),
                );
                
                this.setState(() {
                  selectedStudentIds.clear();
                  _isBulkMode = false;
                });
              } catch (e) {
                if (!context.mounted) return;
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
  }

  Future<void> _bulkUpdateGrades() async {
    // Show a dialog to select a grade to apply to all students
    final grades = [
      'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'D-', 'F'
    ];
    String selectedGrade = 'C';
    
    if (!context.mounted) return;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Bulk Update Grades'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Selected Students: ${selectedStudentIds.length}'),
              const SizedBox(height: 16),
              const Text('Select grade to apply:'),
              DropdownButton<String>(
                value: selectedGrade,
                items: grades.map((grade) {
                  return DropdownMenuItem(
                    value: grade,
                    child: Text(grade),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGrade = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('This will update the grade for all subjects for the selected students.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
                
                try {
                  final batch = FirebaseFirestore.instance.batch();
                  
                  for (final studentId in selectedStudentIds) {
                    final resultRef = FirebaseFirestore.instance
                        .collection('results')
                        .doc(studentId)
                        .collection('semesters')
                        .doc(selectedSemester.toString());
                    
                    final resultDoc = await resultRef.get();
                    if (resultDoc.exists) {
                      final data = resultDoc.data() as Map<String, dynamic>;
                      if (data.containsKey('subjects')) {
                        final List<dynamic> subjects = List.from(data['subjects']);
                        for (int i = 0; i < subjects.length; i++) {
                          subjects[i]['grade'] = selectedGrade;
                          subjects[i]['points'] = _gradeToPoints(selectedGrade);
                        }
                        
                        batch.update(resultRef, {
                          'subjects': subjects,
                          'lastUpdated': FieldValue.serverTimestamp()
                        });
                      }
                    }
                  }
                  
                  await batch.commit();
                  
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Grades updated successfully'),
                      backgroundColor: kgreen,
                    ),
                  );
                  this.setState(() {
                    selectedStudentIds.clear();
                    _isBulkMode = false;
                  });
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating grades: $e')),
                  );
                }
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bulkResetScores() async {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Scores'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Selected Students: ${selectedStudentIds.length}'),
            const SizedBox(height: 8),
            const Text('This action will:'),
            const Text('• Reset all scores to 0'),
            const Text('• Reset all grades to F'),
            const Text('• Keep subject assignments intact'),
            const SizedBox(height: 8),
            const Text('This action cannot be undone.', 
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final batch = FirebaseFirestore.instance.batch();
                
                for (final studentId in selectedStudentIds) {
                  final resultRef = FirebaseFirestore.instance
                      .collection('results')
                      .doc(studentId)
                      .collection('semesters')
                      .doc(selectedSemester.toString());
                  
                  final resultDoc = await resultRef.get();
                  if (resultDoc.exists) {
                    final data = resultDoc.data() as Map<String, dynamic>;
                    if (data.containsKey('subjects')) {
                      final List<dynamic> subjects = List.from(data['subjects']);
                      for (int i = 0; i < subjects.length; i++) {
                        subjects[i]['grade'] = 'F';
                        subjects[i]['points'] = 0.0;
                        subjects[i]['scores'] = {
                          'week5': 0.0,
                          'week10': 0.0,
                          'coursework': subjects[i]['scores']['coursework'] != null ? 0.0 : null,
                          'lab': subjects[i]['scores']['lab'] != null ? 0.0 : null,
                        };
                      }
                      
                      batch.update(resultRef, {
                        'subjects': subjects,
                        'lastUpdated': FieldValue.serverTimestamp()
                      });
                    }
                  }
                }
                
                await batch.commit();
                
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Scores reset successfully'),
                    backgroundColor: kgreen,
                  ),
                );
                this.setState(() {
                  selectedStudentIds.clear();
                  _isBulkMode = false;
                });
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error resetting scores: $e')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Results"),
        titleTextStyle: kTextStyleBold,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          // Template management
          IconButton(
            icon: const Icon(Icons.assignment, color: kBlue),
            onPressed: () {
              if (!context.mounted) return;
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
            tooltip: 'Manage Templates',
          ),
          // Subjects management
          IconButton(
            icon: const Icon(Icons.library_books, color: kBlue),
            onPressed: () {
              if (!context.mounted) return;
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
            tooltip: 'Manage Subjects',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filters section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kbabyblue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.filter_list, color: kBlue),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // First row - Department and Semester
                Row(
                  children: [
                    // Department dropdown
                    Expanded(
                      child: _buildDropdownField(
                        icon: Icons.business,
                        label: 'Department',
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kLightGrey),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kBlue),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          value: selectedDepartment,
                          items: departments.map((String department) {
                            return DropdownMenuItem<String>(
                              value: department,
                              child: Text(
                                department,
                                style: const TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedDepartment = value!;
                              if (selectedStudentIds.isNotEmpty) {
                                selectedStudentIds.clear();
                              }
                            });
                          },
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.arrow_drop_down, color: kBlue),
                          isExpanded: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Semester dropdown
                    Expanded(
                      child: _buildDropdownField(
                        icon: Icons.event_note,
                        label: 'Semester',
                        child: DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kLightGrey),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kBlue),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          value: selectedSemester,
                          items: List.generate(10, (index) => index + 1)
                              .map((int semester) {
                            return DropdownMenuItem<int>(
                              value: semester,
                              child: Text(
                                'Semester $semester',
                                style: const TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            setState(() {
                              selectedSemester = value!;
                            });
                          },
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.arrow_drop_down, color: kBlue),
                          isExpanded: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Second row - Academic Year and Search
                Row(
                  children: [
                    // Academic year dropdown
                    Expanded(
                      child: _buildDropdownField(
                        icon: Icons.school,
                        label: 'Academic Year',
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kLightGrey),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: kBlue),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          value: selectedAcademicYear,
                          items: academicYears.map((String year) {
                            return DropdownMenuItem<String>(
                              value: year,
                              child: Text(
                                year,
                                style: const TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedAcademicYear = value!;
                              if (selectedStudentIds.isNotEmpty) {
                                selectedStudentIds.clear();
                              }
                            });
                          },
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.arrow_drop_down, color: kBlue),
                          isExpanded: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Search field
                    Expanded(
                      child: _buildDropdownField(
                        icon: Icons.search,
                        label: 'Search Students',
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: kLightGrey),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: kBlue),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            hintText: 'Type to search...',
                            hintStyle: const TextStyle(
                              color: kGrey,
                              fontSize: 14,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bulk actions toggle and controls
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: 16, 
              vertical: _isBulkMode ? 12 : 8,
            ),
            decoration: BoxDecoration(
              color: _isBulkMode ? kbabyblue : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isBulkMode ? kShadow : null,
              border: Border.all(
                color: _isBulkMode ? kBlue.withOpacity(0.3) : kLightGrey,
                width: _isBulkMode ? 1.0 : 1.0,
              ),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isBulkMode ? kBlue.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isBulkMode ? Icons.group_work : Icons.group_outlined,
                    color: _isBulkMode ? kBlue : kGrey,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                // Title text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isBulkMode ? 'Bulk Mode' : 'Student Results',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: _isBulkMode ? kBlue : kGrey,
                        ),
                      ),
                      if (_isBulkMode)
                        Text(
                          '${selectedStudentIds.length} students selected',
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 12,
                            color: kGrey,
                          ),
                        ),
                    ],
                  ),
                ),
                // Action controls with animations
                if (_isBulkMode) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kLightGrey),
                    ),
                    child: DropdownButton<String>(
                      value: _bulkOperationType,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: kBlue, size: 18),
                      items: _bulkOperations.map((String operation) {
                        return DropdownMenuItem<String>(
                          value: operation,
                          child: Text(
                            operation,
                            style: const TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 13,
                              color: kGrey,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _bulkOperationType = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedOpacity(
                    opacity: _bulkOperationType != 'Select Operation' ? 1.0 : 0.6,
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text(
                        'Apply',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlue,
                        foregroundColor: Colors.white,
                        elevation: _bulkOperationType != 'Select Operation' ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        minimumSize: const Size(0, 32),
                      ),
                      onPressed: _processBulkOperation,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: kGrey,
                      padding: const EdgeInsets.all(6),
                      minimumSize: const Size(32, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: kLightGrey, width: 1),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isBulkMode = false;
                        selectedStudentIds.clear();
                      });
                    },
                  ),
                ] else
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'Bulk Mode',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: kBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: kBlue.withOpacity(0.5)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                    onPressed: () {
                      setState(() {
                        _isBulkMode = true;
                        _bulkOperationType = 'Select Operation';
                      });
                    },
                  ),
              ],
            ),
          ),

          // Students list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getStudentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: kBlue,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading students...',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                            color: kGrey.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error.toString()}',
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_alt_outlined,
                          color: kGrey.withOpacity(0.6),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No students found',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: kGrey.withOpacity(0.8),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty || selectedDepartment != 'All' || selectedAcademicYear != 'All')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Try adjusting your filters',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 14,
                                color: kGrey.withOpacity(0.7),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                final docs = filterStudents(snapshot.data!.docs);

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          color: kGrey.withOpacity(0.6),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matches found',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: kGrey.withOpacity(0.8),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Try a different search term or filter',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 14,
                              color: kGrey.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with count
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            Text(
                              'Students (${docs.length})',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: kBlue,
                              ),
                            ),
                            const Spacer(),
                            if (_isBulkMode && selectedStudentIds.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: kbabyblue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: kBlue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${selectedStudentIds.length} selected',
                                      style: const TextStyle(
                                        fontFamily: 'Lexend',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: kBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Divider
                      const Divider(height: 1),
                      // Students ListView
                      Expanded(
                        child: ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            final userData = docs[index].data() as Map<String, dynamic>;
                            final firstName = userData['firstName'] as String? ?? 'No Name';
                            final lastName = userData['lastName'] as String? ?? '';
                            final studentId = docs[index].id;
                            final department = userData['department'] as String? ?? 'No Dept';
                            final academicYear = userData['academicYear'] as String? ?? '';
                            final isSelected = selectedStudentIds.contains(studentId);
                            
                            // First letter of name for avatar
                            final avatarText = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'S';
                            
                            // Generate a consistent color based on the name
                            final colorIndex = (firstName.isNotEmpty ? firstName.codeUnitAt(0) : 0) % 5;
                            final List<Color> avatarColors = [
                              const Color(0xFF5E35B1), // Deep Purple
                              const Color(0xFF00897B), // Teal
                              const Color(0xFF039BE5), // Light Blue
                              const Color(0xFFD81B60), // Pink
                              const Color(0xFF6D4C41), // Brown
                            ];
                            final avatarColor = avatarColors[colorIndex];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected ? kBlue : Colors.transparent,
                                  width: isSelected ? 1.5 : 0,
                                ),
                              ),
                              color: isSelected ? kbabyblue.withOpacity(0.3) : Colors.white,
                              elevation: 0,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _isBulkMode
                                    ? () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedStudentIds.remove(studentId);
                                          } else {
                                            selectedStudentIds.add(studentId);
                                          }
                                        });
                                      }
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      if (_isBulkMode)
                                        Checkbox(
                                          value: isSelected,
                                          activeColor: kBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedStudentIds.add(studentId);
                                              } else {
                                                selectedStudentIds.remove(studentId);
                                              }
                                            });
                                          },
                                        ),
                                      // Student avatar
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: avatarColor,
                                        child: Text(
                                          avatarText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$firstName $lastName',
                                              style: const TextStyle(
                                                fontFamily: 'Lexend',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, 
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: kBlue.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    department,
                                                    style: TextStyle(
                                                      fontFamily: 'Lexend',
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: kBlue.withOpacity(0.8),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, 
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: kOrange.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    academicYear,
                                                    style: TextStyle(
                                                      fontFamily: 'Lexend',
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: kOrange.withOpacity(0.8),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!_isBulkMode)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            KButton(
                                              text: 'Assign',
                                              onPressed: () =>
                                                  assignResultsForStudent(
                                                      context, studentId),
                                              backgroundColor: kBlue,
                                              textColor: Colors.white,
                                              width: 90,
                                              height: 36,
                                              fontSize: 13,
                                              borderRadius: 8,
                                              icon: Icons.assignment,
                                              elevated: true,
                                            ),
                                            const SizedBox(width: 8),
                                            KButton(
                                              text: 'Grades',
                                              onPressed: () =>
                                                  _assignGradesForStudent(
                                                      context, studentId),
                                              backgroundColor: Colors.white,
                                              textColor: kBlue,
                                              width: 90,
                                              height: 36,
                                              fontSize: 13,
                                              borderColor: kBlue,
                                              borderWidth: 1,
                                              borderRadius: 8,
                                              icon: Icons.grade,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: kBlue),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kGrey,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: child,
        ),
      ],
    );
  }
}

