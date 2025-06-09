import 'package:flutter/material.dart';
import '../../../constants.dart';
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
      availableSubjects =
          await _resultsService.getDepartmentSubjects(widget.department);
      // Filter subjects by semester availability
      availableSubjects = availableSubjects
          .where((s) =>
              (s['availableForSemesters'] as List).contains(widget.semester))
          .toList();

      // Sort subjects: mandatory first, then electives
      availableSubjects.sort((a, b) {
        final aElective = a['isElective'] ?? false;
        final bElective = b['isElective'] ?? false;
        if (aElective == bElective) {
          return (a['name'] as String).compareTo(b['name'] as String);
        }
        return aElective ? 1 : -1;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: kShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Subjects',
                      style: kTextStyleBold,
                    ),
                    Text(
                      'Department: ${widget.department}',
                      style: const TextStyle(
                        color: kGrey,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Semester: ${widget.semester}',
                      style: const TextStyle(
                        color: kGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Filter & Counter section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: kbabyblue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Subjects: ${availableSubjects.length}',
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Selected: ${selectedSubjectCodes.length}',
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: kBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subjects List
            SizedBox(
              height: 400,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: kBlue))
                  : availableSubjects.isEmpty
                      ? const Center(
                          child: Text(
                            'No subjects available for this semester',
                            style: TextStyle(color: kGrey),
                          ),
                        )
                      : ListView.separated(
                          itemCount: availableSubjects.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final subject = availableSubjects[index];
                            final bool isElective =
                                subject['isElective'] ?? false;
                            final bool isSelected =
                                selectedSubjectCodes.contains(subject['code']);

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isSelected ? kBlue : Colors.transparent,
                                  width: isSelected ? 1 : 0,
                                ),
                              ),
                              child: CheckboxListTile(
                                title: Text(
                                  subject['name'],
                                  style: const TextStyle(
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Code: ${subject['code']}'),
                                    Column(
                                      spacing: 4,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isElective
                                                ? kOrange.withOpacity(0.2)
                                                : kgreen.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            isElective
                                                ? 'Elective'
                                                : 'Mandatory',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  isElective ? kOrange : kgreen,
                                            ),
                                          ),
                                        ),
                                        if (subject['credits'] != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: kGrey.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${subject['credits']} Credits',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: kGrey,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                value: isSelected,
                                onChanged: isElective
                                    ? (bool? value) {
                                        setState(() {
                                          if (value ?? false) {
                                            selectedSubjectCodes
                                                .add(subject['code']);
                                          } else {
                                            selectedSubjectCodes
                                                .remove(subject['code']);
                                          }
                                        });
                                      }
                                    : null,
                                activeColor: kBlue,
                                checkColor: Colors.white,
                                tileColor: isSelected
                                    ? kbabyblue.withOpacity(0.3)
                                    : Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: kGrey),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    await _resultsService.updateStudentSubjects(
                      userId: widget.userId,
                      semesterId: widget.semester.toString(),
                      selectedSubjectCodes: selectedSubjectCodes.toList(),
                    );
                    if (!mounted) return;
                    Navigator.pop(context, true);
                  },
                  child: const Text('Save Subjects'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
