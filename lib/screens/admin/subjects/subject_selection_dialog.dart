import 'package:flutter/material.dart';
import '../../../services/results_service.dart';

class SubjectSelectionDialog extends StatefulWidget {
  final String userId;
  final String department;
  final int semester;
  final List<String> initiallySelectedSubjects;

  const SubjectSelectionDialog({
    super.key,
    required this.userId,
    required this.department,
    required this.semester,
    required this.initiallySelectedSubjects,
  });

  @override
  State<SubjectSelectionDialog> createState() => _SubjectSelectionDialogState();
}

class _SubjectSelectionDialogState extends State<SubjectSelectionDialog> {
  final ResultsService _resultsService = ResultsService();
  List<Map<String, dynamic>> availableSubjects = [];
  Set<String> selectedSubjectCodes = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedSubjectCodes = Set.from(widget.initiallySelectedSubjects);
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => isLoading = true);
    try {
      availableSubjects = await _resultsService.getDepartmentSubjects(widget.department);
      // Filter subjects by semester availability
      availableSubjects = availableSubjects
          .where((s) => (s['availableForSemesters'] as List).contains(widget.semester))
          .toList();
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Subjects'),
      content: SizedBox(
        width: double.maxFinite,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: availableSubjects.length,
                      itemBuilder: (context, index) {
                        final subject = availableSubjects[index];
                        final bool isElective = subject['isElective'] ?? false;
                        
                        return CheckboxListTile(
                          title: Text(subject['name']),
                          subtitle: Text(
                            '${subject['code']} ${isElective ? '(Elective)' : '(Mandatory)'}',
                          ),
                          value: selectedSubjectCodes.contains(subject['code']),
                          onChanged: isElective
                              ? (bool? value) {
                                  setState(() {
                                    if (value ?? false) {
                                      selectedSubjectCodes.add(subject['code']);
                                    } else {
                                      selectedSubjectCodes.remove(subject['code']);
                                    }
                                  });
                                }
                              : null,
                        );
                      },
                    ),
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
            await _resultsService.updateStudentSubjects(
              userId: widget.userId,
              semesterId: widget.semester.toString(),
              selectedSubjectCodes: selectedSubjectCodes.toList(),
            );
            if (!mounted) return;
            Navigator.pop(context, true);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
