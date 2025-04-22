import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../components/kbutton.dart';
import '../../components/my_app_bar.dart';
import '../../components/excel_upload_widget.dart';
import '../../constants.dart';
import '../../services/results_service.dart';
import '../../services/template_downloader.dart';
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
  final List<String> departments = ['All', 'General', 'CE', 'ECE', 'EME', 'IE'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String selectedAcademicYear = 'All';
  List<String> academicYears = ['All', 'GN', '1st', '2nd', '3rd', '4th'];
  Set<String> selectedStudentIds = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isProcessingExcel = false;
  String _processingMessage = '';
  bool _canModifyResults = false; // Flag to indicate if user can modify results

  // For bulk operations
  bool _isBulkMode = false;
  String _bulkOperationType = 'Select Operation';
  final List<String> _bulkOperations = [
    'Select Operation',
    'Assign Subjects',
    'Reset Scores'
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool canModify = await _resultsService.canModifyResults();
    setState(() {
      _canModifyResults = canModify;
    });
  }

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
      // Ensure credits is always a numeric value, defaulting to 4
      int credits = 4;
      if (subject.containsKey("credits")) {
        if (subject["credits"] is int) {
          credits = subject["credits"];
        } else if (subject["credits"] is num) {
          credits = (subject["credits"] as num).toInt();
        } else if (subject["credits"] is String) {
          credits = int.tryParse(subject["credits"]) ?? 4;
        }
      }
      
      return {
        "code": subject["code"],
        "name": subject["name"],
        "credits": credits,
        "grade": "F",
        "points": 0.0,
        "scores": {
          "week5": 0.0,
          "week10": 0.0,
          "classwork": subject["hasCoursework"] ? 0.0 : null,
          "labExam": subject["hasLab"] ? 0.0 : null,
          "finalExam": 0.0,
        },
      };
    }).toList();
  }

  double _gradeToPoints(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+': return 4.0;
      case 'A': return 4.0;
      case 'A-': return 3.7;
      case 'B+': return 3.3;
      case 'B': return 3.0;
      case 'B-': return 2.7;
      case 'C+': return 2.3;
      case 'C': return 2.0;
      case 'C-': return 1.7;
      case 'D+': return 1.3;
      case 'D': return 1.0;
      case 'D-': return 0.7;
      default: return 0.0;
    }
  }

  Future<void> _showSubjectResultsDialog(BuildContext context, String userId,
      Map<String, dynamic> subject, int index) async {
    if (!context.mounted) return;

    try {
      if (!_canModifyResults) {
        throw Exception('Only Admin and IT can modify results');
      }

      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) => SubjectResultsDialog(
          subject: subject,
          onSave: (updatedSubject) async {
            try {
              await _resultsService.updateStudentSubjectResults(
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
      if (!_canModifyResults) {
        throw Exception('Only Admin and IT can assign results');
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
      // Convert Map<String, dynamic> to List<String> for subject codes
      final currentSubjectsData = await _resultsService.getStudentSubjects(
        userId,
        selectedSemester.toString(),
      );
      
      // Extract subject codes from the data
      final List<String> currentSubjectCodes = currentSubjectsData
          .map((subject) => subject['code'] as String)
          .toList();

      if (!context.mounted) return;
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => SubjectSelectionDialog(
          userId: userId,
          department: userData['department'],
          semester: selectedSemester,
          initiallySelectedSubjects: currentSubjectCodes,
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

  // Show Excel upload dialog
  Future<void> _showExcelUploadDialog(BuildContext context) async {
    if (!_canModifyResults) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only Admin and IT users can upload Excel files'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    PlatformFile? selectedFile;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Upload Student Grades Excel Sheet'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Upload an Excel sheet with student grades in the specified format:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Column A: Student ID\nColumn B: Course Name\nColumn C: Course Code\nColumn D: Week 5 Score\nColumn E: Week 10 Score\nColumn F: Coursework\nColumn G: Lab\nColumn H: Final Grade',
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download Template'),
                  onPressed: () async {
                    // Use TemplateDownloader from services
                    final templateDownloader = TemplateDownloader();
                    final success = await templateDownloader.generateAndSaveTemplate();
                    
                    if (!success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to generate template'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                ExcelUploadWidget(
                  height: 200,
                  width: double.infinity,
                  onFileSelected: (file) {
                    selectedFile = file;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Semester: $selectedSemester',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedFile != null) {
                  Navigator.pop(dialogContext);
                  await _processExcelFile(selectedFile!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select an Excel file first'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Upload and Process'),
            ),
          ],
        );
      },
    );
  }

  // Process the uploaded Excel file
  Future<void> _processExcelFile(PlatformFile file) async {
    try {
      setState(() {
        _isProcessingExcel = true;
        _processingMessage = 'Processing Excel file...';
      });

      // Process the Excel file and assign results to students
      final successCount = await _resultsService.processAndAssignResultsFromExcel(
        file,
        selectedSemester,
      );

      // Force refresh the UI
      setState(() {
        _isProcessingExcel = false;
        _processingMessage = '';
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully processed grades for $successCount students'),
          backgroundColor: kgreen,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Add a small delay to ensure Firebase updates are complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Trigger a rebuild of the entire screen to refresh data
      if (mounted) {
        setState(() {
          // This empty setState forces a rebuild
        });
      }
    } catch (e) {
      setState(() {
        _isProcessingExcel = false;
        _processingMessage = '';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing Excel file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show admin options FAB menu
  void _showAdminOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Text(
              'Admin Controls',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kbabyblue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.upload_file, color: kBlue),
            ),
            title: const Text('Upload Excel Grade Sheet'),
            subtitle: const Text('Batch import grades from Excel file'),
            onTap: () {
              Navigator.pop(context);
              _showExcelUploadDialog(context);
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.subject, color: kOrange),
            ),
            title: const Text('Manage Department Subjects'),
            subtitle: const Text('Add, edit or remove course subjects'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DepartmentSubjectsScreen(
                    department: selectedDepartment == 'All'
                        ? 'General'
                        : selectedDepartment,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.assignment, color: kBlue),
            ),
            title: const Text('Manage Semester Templates'),
            subtitle: const Text('Configure semester subject templates'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SemesterTemplateScreen(
                    department: selectedDepartment == 'All'
                        ? 'General'
                        : selectedDepartment,
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
                color: kgreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.import_export, color: kgreen),
            ),
            title: const Text('Bulk Operations'),
            subtitle: const Text('Apply operations to multiple students'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _isBulkMode = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bulk mode activated. Select students to perform operations.'),
                  backgroundColor: kBlue,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu() {
    _showAdminOptions();
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
      floatingActionButton: _isProcessingExcel
          ? FloatingActionButton.extended(
              backgroundColor: kBlue,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
              label: Text(
                _processingMessage,
                style: const TextStyle(color: Colors.white, fontFamily: 'Lexend'),
              ),
            )
          : _isBulkMode
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
      body: _isProcessingExcel
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_processingMessage),
                ],
              ),
            )
          : Column(
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
      ],
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
    // Force refresh from Firestore to get latest data
    // Skip cache to ensure we get the latest data
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

  Future<void> _processBulkOperation() async {
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

    // Show a progress indicator
    setState(() {
      _isProcessingExcel = true;
      _processingMessage = 'Processing ${_bulkOperationType}...';
    });

    try {
      if (_bulkOperationType == 'Assign Subjects') {
        await _bulkAssignSubjects();
      } else if (_bulkOperationType == 'Reset Scores') {
        await _bulkResetScores();
      }

      // Hide progress indicator
      setState(() {
        _isProcessingExcel = false;
        _processingMessage = '';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_bulkOperationType} completed successfully'),
          backgroundColor: kgreen,
        ),
      );
    } catch (e) {
      // Hide progress indicator
      setState(() {
        _isProcessingExcel = false;
        _processingMessage = '';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Bulk assign subjects to selected students
  Future<void> _bulkAssignSubjects() async {
    int successCount = 0;
    int failCount = 0;
    
    // Get the students' department and subjects
    final List<Map<String, dynamic>> studentsData = [];
    
    for (String studentId in selectedStudentIds) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(studentId)
            .get();
            
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          studentsData.add({
            'id': studentId,
            'department': userData['department'] ?? 'General',
          });
        }
      } catch (e) {
        debugPrint('Error getting student data: $e');
        failCount++;
      }
    }
    
    // Show dialog to select subjects by department
    final List<String> uniqueDepartments = studentsData
      .map((data) => data['department'] as String)
      .toSet()
      .toList();
      
    // If there are multiple departments, we need to handle each separately
    for (String department in uniqueDepartments) {
      final studentsInDepartment = studentsData
        .where((data) => data['department'] == department)
        .toList();
        
      if (studentsInDepartment.isEmpty) continue;
      
      // Show dialog to select subjects for this department
      if (!mounted) break;
      
      // Get existing subject codes for the first student to use as initial selection
      List<String> initialSelectedSubjectCodes = [];
      try {
        final currentSubjectsData = await _resultsService.getStudentSubjects(
          studentsInDepartment.first['id'],
          selectedSemester.toString(),
        );
        
        initialSelectedSubjectCodes = currentSubjectsData
            .map((subject) => subject['code'] as String)
            .toList();
      } catch (e) {
        debugPrint('Error getting initial subjects: $e');
        // Continue with empty initial selection
      }
      
      final bool? shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => SubjectSelectionDialog(
          userId: studentsInDepartment.first['id'],
          department: department,
          semester: selectedSemester,
          initiallySelectedSubjects: initialSelectedSubjectCodes,
        ),
      );
      
      if (shouldContinue != true) continue;
      
      // Apply subjects to all students in this department
      for (var studentData in studentsInDepartment) {
        try {
          // Get updated subject codes from the student we used for selection
          final updatedSubjectsData = await _resultsService.getStudentSubjects(
            studentsInDepartment.first['id'],
            selectedSemester.toString(),
          );
          
          // Get the department subjects in the proper format for other students
          final subjects = await _getDepartmentSubjects(department);
          
          // Filter to only include the selected subjects
          final List<String> selectedCodes = updatedSubjectsData
              .map((subject) => subject['code'] as String)
              .toList();
              
          final List<Map<String, dynamic>> selectedSubjects = subjects
              .where((subject) => selectedCodes.contains(subject['code']))
              .toList();
          
          // Update the student's semester with these subjects
          DocumentReference resultDoc = FirebaseFirestore.instance
              .collection('results')
              .doc(studentData['id'])
              .collection('semesters')
              .doc(selectedSemester.toString());

          await resultDoc.set({
            "semesterNumber": selectedSemester,
            "department": department,
            "lastUpdated": FieldValue.serverTimestamp(),
            "subjects": selectedSubjects,
          }, SetOptions(merge: true));
          
          successCount++;
        } catch (e) {
          debugPrint('Error assigning subjects to student: $e');
          failCount++;
        }
      }
    }
    
    setState(() {
      _processingMessage = 'Completed: $successCount successful, $failCount failed';
    });
  }
  
  // Bulk reset scores for all selected students
  Future<void> _bulkResetScores() async {
    int successCount = 0;
    int failCount = 0;
    
    for (String studentId in selectedStudentIds) {
      try {
        // Get current student results
        final results = await _resultsService.getSemesterResults(
          studentId, 
          selectedSemester.toString()
        );
        
        if (results == null || (results['subjects'] as List?)?.isEmpty == true) {
          continue; // Skip if no results exist
        }
        
        // Reset scores for each subject
        List<Map<String, dynamic>> subjects = 
          List<Map<String, dynamic>>.from(results['subjects'] as List);
        
        for (int i = 0; i < subjects.length; i++) {
          final subject = subjects[i];
          
          // Reset the scores while maintaining the structure
          Map<String, dynamic> scores = Map<String, dynamic>.from(subject['scores'] as Map);
          
          // Reset scores to 0.0
          if (scores.containsKey('week5')) scores['week5'] = 0.0;
          if (scores.containsKey('week10')) scores['week10'] = 0.0;
          if (scores.containsKey('classwork')) scores['classwork'] = 0.0;
          if (scores.containsKey('coursework')) scores['coursework'] = 0.0;
          if (scores.containsKey('labExam')) scores['labExam'] = 0.0;
          if (scores.containsKey('lab')) scores['lab'] = 0.0;
          if (scores.containsKey('finalExam')) scores['finalExam'] = 0.0;
          
          // Reset grade and points
          subjects[i]['grade'] = 'F';
          subjects[i]['points'] = 0.0;
          subjects[i]['scores'] = scores;
        }
        
        // Update the document with reset scores
        await FirebaseFirestore.instance
          .collection('results')
          .doc(studentId)
          .collection('semesters')
          .doc(selectedSemester.toString())
          .update({
            'subjects': subjects,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          
        successCount++;
      } catch (e) {
        debugPrint('Error resetting scores: $e');
        failCount++;
      }
    }
    
    setState(() {
      _processingMessage = 'Completed: $successCount successful, $failCount failed';
    });
  }

  // Method to show student results in a dialog
  Future<void> _showStudentResults(BuildContext context, String userId) async {
    try {
      // Force refresh from Firestore to get the latest data
      final results = await _resultsService.getSemesterResults(
          userId, selectedSemester.toString());

      if (results == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No results found for this semester"),
          ),
        );
        return;
      }

      final subjects = List<Map<String, dynamic>>.from(results['subjects'] ?? []);

      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Semester Results'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return ListTile(
                    title: Text(subject['name'] ?? 'Unknown Subject'),
                    subtitle: Text(
                        'Code: ${subject['code']} | Grade: ${subject['grade']}'),
                    trailing: _canModifyResults 
                        ? IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.pop(context);
                              _showSubjectResultsDialog(
                                  context, userId, subject, index);
                            },
                          )
                        : null,
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }
}

