import 'package:flutter/material.dart';
import '../../../services/results_service.dart';

class DepartmentSubjectsScreen extends StatefulWidget {
  final String department;
  
  const DepartmentSubjectsScreen({
    super.key,
    required this.department,
  });

  @override
  State<DepartmentSubjectsScreen> createState() => _DepartmentSubjectsScreenState();
}

class _DepartmentSubjectsScreenState extends State<DepartmentSubjectsScreen> {
  final ResultsService _resultsService = ResultsService();
  List<Map<String, dynamic>> subjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => isLoading = true);
    try {
      subjects = await _resultsService.getDepartmentSubjects(widget.department);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showAddSubjectDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final creditsController = TextEditingController(text: '4');
    bool hasCoursework = true;
    bool hasLab = true;
    bool isElective = false;
    List<int> availableSemesters = [1,2,3,4,5,6,7,8,9,10];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Subject'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                    hintText: 'e.g., Mathematics 1',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Code',
                    hintText: 'e.g., MAT 001',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: creditsController,
                  decoration: const InputDecoration(labelText: 'Credits'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Has Coursework'),
                  value: hasCoursework,
                  onChanged: (value) => setState(() => hasCoursework = value!),
                ),
                CheckboxListTile(
                  title: const Text('Has Lab'),
                  value: hasLab,
                  onChanged: (value) => setState(() => hasLab = value!),
                ),
                CheckboxListTile(
                  title: const Text('Elective Subject'),
                  value: isElective,
                  onChanged: (value) => setState(() => isElective = value!),
                ),
                const Text('Available in Semesters:'),
                Wrap(
                  spacing: 8,
                  children: List.generate(10, (index) {
                    final semester = index + 1;
                    return FilterChip(
                      label: Text(semester.toString()),
                      selected: availableSemesters.contains(semester),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            availableSemesters.add(semester);
                          } else {
                            availableSemesters.remove(semester);
                          }
                        });
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || codeController.text.isEmpty) {
                  return;
                }

                final newSubject = {
                  'name': nameController.text,
                  'code': codeController.text,
                  'credits': int.tryParse(creditsController.text) ?? 4,
                  'hasCoursework': hasCoursework,
                  'hasLab': hasLab,
                  'isElective': isElective,
                  'availableForSemesters': availableSemesters,
                };

                await _resultsService.addDepartmentSubject(
                  widget.department,
                  newSubject,
                );

                if (!mounted) return;
                Navigator.pop(context);
                _loadSubjects();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.department} Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSubjectDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return Card(
                  child: ListTile(
                    title: Text(subject['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Code: ${subject['code']}'),
                        Text('Credits: ${subject['credits']}'),
                        Row(
                          children: [
                            Icon(
                              subject['hasCoursework'] ? Icons.check : Icons.close,
                              color: subject['hasCoursework'] ? Colors.green : Colors.red,
                            ),
                            const Text(' Coursework'),
                            const SizedBox(width: 16),
                            Icon(
                              subject['hasLab'] ? Icons.check : Icons.close,
                              color: subject['hasLab'] ? Colors.green : Colors.red,
                            ),
                            const Text(' Lab'),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _resultsService.deleteDepartmentSubject(
                          widget.department,
                          subject['code'],
                        );
                        _loadSubjects();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
