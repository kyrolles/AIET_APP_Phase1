import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../services/results_service.dart';
import 'subject_results_dialog.dart';
import '../../utils/subjects_data.dart';
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

  // Updated query to properly fetch student data
  Stream<QuerySnapshot> getStudentsStream() {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Student'); // Changed 'student' to 'Student' to match creation
    
    if (selectedDepartment != 'All') {
      query = query.where('department', isEqualTo: selectedDepartment);
    }
    
    return query.snapshots();
  }

  // Replace _getDefaultSubjects with this new method
  Future<List<Map<String, dynamic>>> _getDepartmentSubjects(String department) async {
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

  Future<void> _showSubjectResultsDialog(BuildContext context, String userId, Map<String, dynamic> subject, int index) async {
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

  Future<void> assignResultsForStudent(BuildContext context, String userId) async {
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
      final results = await _resultsService.getSemesterResults(userId, selectedSemester.toString());
      
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
                          subtitle: Text('${subject['code']}\nGrade: ${subject['grade']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showSubjectResultsDialog(
                              listContext, 
                              userId, 
                              subject, 
                              index
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

    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // New method to assign grades (modify subject results)
  Future<void> _assignGradesForStudent(BuildContext context, String userId) async {
    if (!context.mounted) return;
    try {
      // Ensure admin privileges
      if (!await _resultsService.isUserAdmin()) {
        throw Exception('Only admins can modify results');
      }
      // Get student data
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!userDoc.exists) throw Exception('Student not found');
      final userData = userDoc.data()!;
      
      // Retrieve or initialize results document for the selected semester
      DocumentReference resultDoc = FirebaseFirestore.instance
          .collection('results')
          .doc(userId)
          .collection('semesters')
          .doc(selectedSemester.toString());
      var results = await _resultsService.getSemesterResults(userId, selectedSemester.toString());
      if (results == null) {
        // Initialize with department subjects if missing
        final subjects = await _getDepartmentSubjects(userData['department']);
        await resultDoc.set({
          "semesterNumber": selectedSemester,
          "department": userData['department'],
          "lastUpdated": FieldValue.serverTimestamp(),
          "subjects": subjects,
        }, SetOptions(merge: true));
        results = await _resultsService.getSemesterResults(userId, selectedSemester.toString());
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          subtitle: Text('${subject['code']}\nGrade: ${subject['grade']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showSubjectResultsDialog(listCtx, userId, subject, index),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // New method to modify subjects (add, remove or update elective subjects)
  Future<void> _modifySubjectsForStudent(BuildContext context, String userId) async {
    if (!context.mounted) return;
    try {
      // Ensure admin privileges
      if (!await _resultsService.isUserAdmin()) {
        throw Exception('Only admins can modify subjects');
      }
      // Get student data
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!userDoc.exists) throw Exception('Student not found');
      final userData = userDoc.data()!;
      
      // Open subject selection dialog to modify elective subjects
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (_) {
          // Get subjects before showing dialog
          return FutureBuilder<List<dynamic>>(
            future: _resultsService.getStudentSubjects(userId, selectedSemester.toString()),
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
                initiallySelectedSubjects: (snapshot.data as List<dynamic>?)?.cast<String>() ?? [],
              );
            },
          );
        },
      );
      // Optionally show message if update occurred
      if (shouldContinue == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subjects updated successfully')));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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
                  const SnackBar(content: Text('Please select a department first')),
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
          // Filter UI: Department and Semester Dropdowns
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Updated Department filter dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDepartment,
                    decoration: const InputDecoration(labelText: "Department"),
                    items: departments
                        .map((dept) =>
                            DropdownMenuItem(value: dept, child: Text(dept)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedDepartment = val!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Semester dropdown
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedSemester,
                    decoration: const InputDecoration(labelText: "Semester"),
                    items: List.generate(10, (index) => index + 1)
                        .map((sem) =>
                            DropdownMenuItem(value: sem, child: Text("Sem $sem")))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedSemester = val!;
                      });
                    },
                  ),
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
                if(snapshot.hasError){
                  print("Error fetching data: ${snapshot.error}"); // Added debug print
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }
                
                final docs = snapshot.data?.docs ?? [];
                if(docs.isEmpty){
                  return const Center(child: Text("No students found."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    // Debug print to check the data
                    print("Document data: ${docs[index].data()}");
                    
                    final userData = docs[index].data() as Map<String, dynamic>;
                    final firstName = userData['firstName'] as String? ?? 'No Name';
                    final lastName = userData['lastName'] as String? ?? '';
                    final studentId = docs[index].id;
                    final department = userData['department'] as String? ?? 'No Dept';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(
                          "$firstName $lastName",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "ID: ${userData['id']}\nDepartment: $department",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () => _assignGradesForStudent(context, studentId),
                              child: const Text("Assign Grades"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _modifySubjectsForStudent(context, studentId),
                              child: const Text("Modify Subjects"),
                            ),
                          ],
                        ),
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
    final template = await _resultsService.getSemesterTemplate(
      selectedDepartment,
      selectedSemester,
    );

    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batch Assign Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This will assign default results to all selected students.'),
            Text('Template has ${template.length} subjects.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get selected student IDs
              final selectedIds = []; // Implement selection logic
              await _resultsService.batchAssignResults(
                studentIds: selectedIds.cast<String>(),
                department: selectedDepartment,
                semester: selectedSemester,
                subjects: template,
              );
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}
