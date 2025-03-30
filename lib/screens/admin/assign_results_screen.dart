import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../components/kbutton.dart';
import '../../components/my_app_bar.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        title: 'Results Management',
        onpressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: kBlue),
            onPressed: _showSettingsMenu,
          ),
        ],
      ),
      floatingActionButton: _isBulkMode
          ? FloatingActionButton.extended(
              backgroundColor: kBlue,
              onPressed: () => _processBulkOperation(),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Apply',
                style: TextStyle(color: Colors.white, fontFamily: 'Lexend'),
              ),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(),
          if (_isBulkMode) _buildBulkOperationBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getStudentsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: kBlue),
                  );
                }

                final students = filterStudents(snapshot.data!.docs);

                if (students.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildStudentsList(students);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kGreyLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: kGrey, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search students...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: kGrey,
                              fontSize: 14,
                              fontFamily: 'Lexend',
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
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: kGrey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _isBulkMode ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                  color: kBlue,
                ),
                onPressed: () {
                  setState(() {
                    _isBulkMode = !_isBulkMode;
                    if (!_isBulkMode) {
                      selectedStudentIds.clear();
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Department: $selectedDepartment',
                  icon: Icons.school,
                  onTap: _showDepartmentPicker,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Year: $selectedAcademicYear',
                  icon: Icons.calendar_today,
                  onTap: _showAcademicYearPicker,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Semester: $selectedSemester',
                  icon: Icons.book,
                  onTap: _showSemesterPicker,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: kbabyblue,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBlue.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: kBlue),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: kBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lexend',
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 16, color: kBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkOperationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: kbabyblue,
      child: Row(
        children: [
          Text(
            'Bulk Operation: ',
            style: TextStyle(
              color: kBlue,
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBlue.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _bulkOperationType,
                  icon: const Icon(Icons.arrow_drop_down, color: kBlue),
                  elevation: 2,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontFamily: 'Lexend',
                    fontSize: 14,
                  ),
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _bulkOperationType = newValue;
                      });
                    }
                  },
                  items: _bulkOperations
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${selectedStudentIds.length} selected',
            style: TextStyle(
              color: kBlue,
              fontFamily: 'Lexend',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No students found',
            style: kTextStyleBold.copyWith(color: kGrey),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              color: kGrey,
              fontFamily: 'Lexend',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(List<QueryDocumentSnapshot> students) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final studentData = students[index].data() as Map<String, dynamic>;
        final studentId = students[index].id;
        final bool isSelected = selectedStudentIds.contains(studentId);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? kBlue : kGreyLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _viewStudentResults(studentId, studentData),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_isBulkMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedStudentIds.remove(studentId);
                            } else {
                              selectedStudentIds.add(studentId);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? kBlue : kGreyLight,
                              width: 2,
                            ),
                            color: isSelected ? kBlue : Colors.transparent,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : const SizedBox(width: 14, height: 14),
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kbabyblue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${studentData['firstName']?[0] ?? ''}${studentData['lastName']?[0] ?? ''}',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.bold,
                        color: kBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${studentData['firstName'] ?? ''} ${studentData['lastName'] ?? ''}',
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${studentData['id'] ?? 'Unknown'}',
                          style: const TextStyle(
                            color: kGrey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildInfoChip(
                              label: studentData['department'] ?? 'Unknown',
                              color: kPrimaryColor,
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              label: studentData['academicYear'] ?? 'Unknown',
                              color: kOrange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStudentActions(studentId, studentData),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStudentActions(String studentId, Map<String, dynamic> studentData) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.assignment, color: kBlue, size: 20),
          tooltip: 'Assign Subjects',
          onPressed: () => assignResultsForStudent(context, studentId),
        ),
        IconButton(
          icon: const Icon(Icons.grade, color: kOrange, size: 20),
          tooltip: 'Update Grades',
          onPressed: () => _assignGradesForStudent(context, studentId),
        ),
      ],
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kbabyblue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.library_books, color: kBlue),
              ),
              title: const Text(
                'Manage Semester Template',
                style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SemesterTemplateScreen(
                      department: selectedDepartment == 'All' ? 'General' : selectedDepartment,
                      semester: selectedSemester,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.subject, color: kOrange),
              ),
              title: const Text(
                'Manage Department Subjects',
                style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DepartmentSubjectsScreen(
                      department: selectedDepartment == 'All' ? 'General' : selectedDepartment,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kgreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.import_export, color: kgreen),
              ),
              title: const Text(
                'Export/Import Results',
                style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                // Add export/import functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDepartmentPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Select Department',
                style: kTextStyleBold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: departments.length,
                itemBuilder: (context, index) {
                  final department = departments[index];
                  final isSelected = selectedDepartment == department;
                  
                  return ListTile(
                    leading: isSelected
                        ? const Icon(Icons.check_circle, color: kBlue)
                        : const Icon(Icons.circle_outlined, color: kGrey),
                    title: Text(
                      department,
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? kBlue : Colors.black,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedDepartment = department;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAcademicYearPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Select Academic Year',
                style: kTextStyleBold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: academicYears.length,
                itemBuilder: (context, index) {
                  final year = academicYears[index];
                  final isSelected = selectedAcademicYear == year;
                  
                  return ListTile(
                    leading: isSelected
                        ? const Icon(Icons.check_circle, color: kBlue)
                        : const Icon(Icons.circle_outlined, color: kGrey),
                    title: Text(
                      year,
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? kBlue : Colors.black,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedAcademicYear = year;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSemesterPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Select Semester',
                style: kTextStyleBold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  final semester = index + 1;
                  final isSelected = selectedSemester == semester;
                  
                  return ListTile(
                    leading: isSelected
                        ? const Icon(Icons.check_circle, color: kBlue)
                        : const Icon(Icons.circle_outlined, color: kGrey),
                    title: Text(
                      'Semester $semester',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? kBlue : Colors.black,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedSemester = semester;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _viewStudentResults(String studentId, Map<String, dynamic> studentData) async {
    final results = await _resultsService.getSemesterResults(
      studentId,
      selectedSemester.toString(),
    );

    if (!mounted) return;

    if (results == null || (results['subjects'] as List?)?.isEmpty == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No results found for this semester'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final subjects = results['subjects'] as List<dynamic>;

    showModalBottomSheet(
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: kbabyblue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${studentData['firstName']?[0] ?? ''}${studentData['lastName']?[0] ?? ''}',
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.bold,
                        color: kBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${studentData['firstName'] ?? ''} ${studentData['lastName'] ?? ''}',
                          style: kTextStyleBold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Semester $selectedSemester Results',
                          style: const TextStyle(
                            color: kGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kbabyblue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_graph, color: kBlue, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'GPA: ',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w600,
                        color: kBlue,
                      ),
                    ),
                    Text(
                      _calculateGPA(subjects).toStringAsFixed(2),
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: kBlue,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Credits: ',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w600,
                        color: kBlue,
                      ),
                    ),
                    Text(
                      _calculateTotalCredits(subjects).toStringAsFixed(0),
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: kBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Subject Results',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    final grade = subject['grade'] as String? ?? 'F';
                    
                    // Define grade colors
                    final Map<String, Color> gradeColors = {
                      'A': const Color(0xFF4CAF50),
                      'A-': const Color(0xFF8BC34A),
                      'B+': const Color(0xFFCDDC39),
                      'B': const Color(0xFFFFEB3B),
                      'B-': const Color(0xFFFFC107),
                      'C+': const Color(0xFFFF9800),
                      'C': const Color(0xFFFF5722),
                      'C-': const Color(0xFFE91E63),
                      'D+': const Color(0xFF9C27B0),
                      'D': const Color(0xFF673AB7),
                      'D-': const Color(0xFF3F51B5),
                      'F': const Color(0xFFF44336),
                    };
                    final gradeColor = gradeColors[grade] ?? gradeColors['F']!;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showSubjectResultsDialog(
                          context,
                          studentId,
                          Map<String, dynamic>.from(subject),
                          index,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: kGreyLight),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject['name'],
                                      style: const TextStyle(
                                        fontFamily: 'Lexend',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Code: ${subject['code']} • Credits: ${subject['credits']}',
                                      style: const TextStyle(
                                        color: kGrey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: gradeColor.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  grade,
                                  style: TextStyle(
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: gradeColor,
                                  ),
                                ),
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
        ),
      ),
    );
  }

  double _calculateGPA(List<dynamic> subjects) {
    if (subjects.isEmpty) return 0.0;
    
    double totalPoints = 0;
    double totalCredits = 0;
    
    for (final subject in subjects) {
      final credits = (subject['credits'] as num?)?.toDouble() ?? 0;
      final points = (subject['points'] as num?)?.toDouble() ?? 0;
      
      totalPoints += credits * points;
      totalCredits += credits;
    }
    
    return totalCredits > 0 ? totalPoints / totalCredits : 0;
  }

  int _calculateTotalCredits(List<dynamic> subjects) {
    return subjects.fold(0, (total, subject) => 
      total + ((subject['credits'] as num?)?.toInt() ?? 0));
  }

  Future<void> _executeBulkOperation() async {
    if (selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No students selected'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_bulkOperationType == 'Select Operation') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an operation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Implement bulk operations
    // ...
  }
}

