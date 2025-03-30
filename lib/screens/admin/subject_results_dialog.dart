import 'package:flutter/material.dart';
import '../../constants.dart';

class SubjectResultsDialog extends StatefulWidget {
  final Map<String, dynamic> subject;
  final Function(Map<String, dynamic>) onSave;

  const SubjectResultsDialog({
    super.key,
    required this.subject,
    required this.onSave,
  });

  @override
  State<SubjectResultsDialog> createState() => _SubjectResultsDialogState();
}

class _SubjectResultsDialogState extends State<SubjectResultsDialog> {
  late Map<String, dynamic> editedSubject;
  final _formKey = GlobalKey<FormState>();

  // Updated grade points to match calculator screen
  final Map<String, double> gradePoints = {
    'A': 4.0,
    'A-': 3.7,
    'B+': 3.3,
    'B': 3.0,
    'B-': 2.7,
    'C+': 2.3,
    'C': 2.0,
    'C-': 1.7,
    'D+': 1.3,
    'D': 1.0,
    'D-': 0.7,
    'F': 0.0,
  };

  @override
  void initState() {
    super.initState();
    editedSubject = Map<String, dynamic>.from(widget.subject);
    // Ensure grade has a default value if null
    editedSubject['grade'] ??= 'F';
    // Initialize scores if null
    editedSubject['scores'] ??= {
      'week5': 0.0,
      'week10': 0.0,
      'coursework': 0.0,
      'lab': 0.0,
    };
  }

  void _updateGrade(String newGrade) {
    setState(() {
      editedSubject['grade'] = newGrade;
      editedSubject['points'] = gradePoints[newGrade] ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjectName = editedSubject['name'] ?? 'Subject';
    final subjectCode = editedSubject['code'] ?? '';
    final currentGrade = editedSubject['grade'] as String? ?? 'F';
    
    // Define grade colors for visual indicator
    final Map<String, Color> gradeColors = {
      'A': const Color(0xFF4CAF50),   // Green
      'A-': const Color(0xFF8BC34A),  // Light Green
      'B+': const Color(0xFFCDDC39),  // Lime
      'B': const Color(0xFFFFEB3B),   // Yellow
      'B-': const Color(0xFFFFC107),  // Amber
      'C+': const Color(0xFFFF9800),  // Orange
      'C': const Color(0xFFFF5722),   // Deep Orange
      'C-': const Color(0xFFE91E63),  // Pink
      'D+': const Color(0xFF9C27B0),  // Purple
      'D': const Color(0xFF673AB7),   // Deep Purple
      'D-': const Color(0xFF3F51B5),  // Indigo
      'F': const Color(0xFFF44336),   // Red
    };
    final gradeColor = gradeColors[currentGrade] ?? gradeColors['F']!;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x29000000),
              offset: Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: kBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.library_books, color: kBlue, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                subjectName,
                                style: kTextStyleBold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Subject Code: $subjectCode',
                          style: const TextStyle(
                            color: kGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.close, color: kGrey, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              
              // Grade Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kbabyblue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.grade, color: kBlue, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Current Grade',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        // Add a visual indicator for the current grade
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: gradeColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: gradeColor, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentGrade,
                                style: TextStyle(
                                  color: gradeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${gradePoints[currentGrade]?.toStringAsFixed(1)})',
                                style: TextStyle(
                                  color: gradeColor.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select grade to update:',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 14,
                        color: kGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Grade selection with visual grade chips
                    Container(
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kLightGrey),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: gradePoints.keys.map((grade) {
                            final isSelected = currentGrade == grade;
                            final gradeColor = gradeColors[grade] ?? Colors.grey;
                            
                            return GestureDetector(
                              onTap: () => _updateGrade(grade),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? gradeColor.withOpacity(0.2) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? gradeColor : Colors.grey.withOpacity(0.3),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      grade,
                                      style: TextStyle(
                                        color: isSelected ? gradeColor : Colors.grey,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${gradePoints[grade]?.toStringAsFixed(1)})',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected ? gradeColor.withOpacity(0.8) : Colors.grey.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Scores Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kLightGrey),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assignment, color: kBlue, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Assessment Scores',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Divider with score legend
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Component',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: kGrey,
                            ),
                          ),
                          Text(
                            'Score (0-100)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: kGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 5th Week Score
                    buildScoreField(
                      label: '5th Week Score',
                      icon: Icons.calendar_today,
                      initialValue: (editedSubject['scores']?['week5'] ?? 0.0).toString(),
                      onSaved: (value) {
                        editedSubject['scores'] ??= {};
                        editedSubject['scores']['week5'] = double.parse(value ?? '0');
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // 10th Week Score
                    buildScoreField(
                      label: '10th Week Score',
                      icon: Icons.calendar_month,
                      initialValue: (editedSubject['scores']?['week10'] ?? 0.0).toString(),
                      onSaved: (value) {
                        editedSubject['scores'] ??= {};
                        editedSubject['scores']['week10'] = double.parse(value ?? '0');
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Coursework Score (conditional)
                    if (editedSubject['scores']?['coursework'] != null)
                      Column(
                        children: [
                          buildScoreField(
                            label: 'Coursework Score',
                            icon: Icons.assignment,
                            initialValue: (editedSubject['scores']?['coursework'] ?? 0.0).toString(),
                            onSaved: (value) {
                              editedSubject['scores'] ??= {};
                              editedSubject['scores']['coursework'] = double.parse(value ?? '0');
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    
                    // Lab Score (conditional)
                    if (editedSubject['scores']?['lab'] != null)
                      buildScoreField(
                        label: 'Lab Score',
                        icon: Icons.science,
                        initialValue: (editedSubject['scores']?['lab'] ?? 0.0).toString(),
                        onSaved: (value) {
                          editedSubject['scores'] ??= {};
                          editedSubject['scores']['lab'] = double.parse(value ?? '0');
                        },
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Buttons
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
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save Results'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: kBlue.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Use a local variable for the widget.onSave callback
                        // to avoid context issues if the widget is disposed
                        final onSave = widget.onSave;
                        onSave(editedSubject);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildScoreField({
    required String label,
    required IconData icon,
    required String initialValue,
    required Function(String?) onSaved,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, color: kBlue),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.number,
      validator: (value) => _validateScore(value),
      onSaved: onSaved,
    );
  }

  String? _validateScore(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a score';
    }
    final score = double.tryParse(value);
    if (score == null) {
      return 'Please enter a valid number';
    }
    if (score < 0 || score > 100) {
      return 'Score must be between 0 and 100';
    }
    return null;
  }
}
