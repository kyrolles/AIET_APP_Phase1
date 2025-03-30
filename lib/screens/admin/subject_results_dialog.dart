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

  double _calculateTotalScore() {
    final scores = editedSubject['scores'] as Map<String, dynamic>;
    double week5 = (scores['week5'] as num?)?.toDouble() ?? 0.0;
    double week10 = (scores['week10'] as num?)?.toDouble() ?? 0.0;
    double coursework = (scores['coursework'] as num?)?.toDouble() ?? 0.0;
    double lab = (scores['lab'] as num?)?.toDouble() ?? 0.0;
    
    // Normalize the scores to a total of 100
    double totalScore = 0.0;
    double week5Weight = 0.2;  // 20%
    double week10Weight = 0.2; // 20%
    
    bool hasLab = widget.subject['hasLab'] ?? false;
    bool hasCoursework = widget.subject['hasCoursework'] ?? false;
    
    if (hasLab && hasCoursework) {
      double labWeight = 0.3;      // 30%
      double courseworkWeight = 0.3; // 30%
      totalScore = (week5 * week5Weight) + (week10 * week10Weight) + 
                  (lab * labWeight) + (coursework * courseworkWeight);
    } else if (hasLab) {
      double labWeight = 0.6;      // 60%
      totalScore = (week5 * week5Weight) + (week10 * week10Weight) + (lab * labWeight);
    } else if (hasCoursework) {
      double courseworkWeight = 0.6; // 60%
      totalScore = (week5 * week5Weight) + (week10 * week10Weight) + (coursework * courseworkWeight);
    } else {
      // Adjust weights if no lab or coursework
      week5Weight = 0.5;  // 50%
      week10Weight = 0.5; // 50%
      totalScore = (week5 * week5Weight) + (week10 * week10Weight);
    }
    
    return totalScore;
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return gradeColors['A']!;
    if (score >= 80) return gradeColors['B']!;
    if (score >= 70) return gradeColors['C']!;
    if (score >= 60) return gradeColors['D']!;
    return gradeColors['F']!;
  }

  String _getRecommendedGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 85) return 'A-';
    if (score >= 80) return 'B+';
    if (score >= 75) return 'B';
    if (score >= 70) return 'B-';
    if (score >= 65) return 'C+';
    if (score >= 60) return 'C';
    if (score >= 55) return 'C-';
    if (score >= 50) return 'D+';
    if (score >= 45) return 'D';
    if (score >= 40) return 'D-';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    final subjectName = editedSubject['name'] ?? 'Subject';
    final subjectCode = editedSubject['code'] ?? '';
    final currentGrade = editedSubject['grade'] as String? ?? 'F';
    final gradeColor = gradeColors[currentGrade] ?? gradeColors['F']!;
    final totalScore = _calculateTotalScore();
    final recommendedGrade = _getRecommendedGrade(totalScore);
    final scoreColor = _getScoreColor(totalScore);
    
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
                        // Visual indicator for the current grade
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: gradeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            currentGrade,
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
                    const SizedBox(height: 12),
                    
                    // Total Score and Recommended Grade
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Score',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 12,
                                  color: kGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    totalScore.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: scoreColor,
                                    ),
                                  ),
                                  Text(
                                    '/100',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 14,
                                      color: kGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: kGreyLight,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 12),
                                child: Text(
                                  'Recommended Grade',
                                  style: TextStyle(
                                    fontFamily: 'Lexend',
                                    fontSize: 12,
                                    color: kGrey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Row(
                                  children: [
                                    Text(
                                      recommendedGrade,
                                      style: TextStyle(
                                        fontFamily: 'Lexend',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: gradeColors[recommendedGrade] ?? gradeColors['F']!,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${(gradePoints[recommendedGrade] ?? 0.0).toStringAsFixed(1)} pts)',
                                      style: TextStyle(
                                        fontFamily: 'Lexend',
                                        fontSize: 12,
                                        color: kGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Grade Selection
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Select Grade',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kGreyLight),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: gradePoints.length,
                  itemBuilder: (context, index) {
                    final grade = gradePoints.keys.elementAt(index);
                    final isSelected = currentGrade == grade;
                    final color = gradeColors[grade] ?? gradeColors['F']!;
                    
                    return InkWell(
                      onTap: () => _updateGrade(grade),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : kGreyLight,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          grade,
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isSelected ? color : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Scores Section
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Text(
                      'Scores',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    // Info icon with tooltip
                    Tooltip(
                      message: 'Scores should be between 0-100',
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: kBlue,
                      ),
                    ),
                  ],
                ),
              ),
              _buildScoreFields(),
              const SizedBox(height: 20),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kGrey,
                      side: BorderSide(color: kGreyLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave(editedSubject);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreFields() {
    final scores = editedSubject['scores'] as Map<String, dynamic>;
    final bool hasLab = widget.subject['hasLab'] ?? false;
    final bool hasCoursework = widget.subject['hasCoursework'] ?? false;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildScoreField(
                label: 'Week 5',
                iconData: Icons.calendar_today,
                value: scores['week5'],
                onChanged: (value) {
                  setState(() {
                    scores['week5'] = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScoreField(
                label: 'Week 10',
                iconData: Icons.calendar_month,
                value: scores['week10'],
                onChanged: (value) {
                  setState(() {
                    scores['week10'] = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (hasCoursework)
              Expanded(
                child: _buildScoreField(
                  label: 'Coursework',
                  iconData: Icons.assignment,
                  value: scores['coursework'],
                  onChanged: (value) {
                    setState(() {
                      scores['coursework'] = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              ),
            if (hasCoursework && hasLab)
              const SizedBox(width: 12),
            if (hasLab)
              Expanded(
                child: _buildScoreField(
                  label: 'Lab',
                  iconData: Icons.science,
                  value: scores['lab'],
                  onChanged: (value) {
                    setState(() {
                      scores['lab'] = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              ),
            if (!hasCoursework && !hasLab)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kGreyLight),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: kGrey),
                      const SizedBox(width: 8),
                      Text(
                        'No additional components',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 12,
                          color: kGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreField({
    required String label,
    required IconData iconData,
    required dynamic value,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGreyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Icon(iconData, size: 16, color: kBlue),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextFormField(
              initialValue: '${value ?? 0.0}',
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(),
                suffix: Text(
                  '/100',
                  style: TextStyle(
                    fontSize: 12,
                    color: kGrey,
                  ),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 14,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                final score = double.tryParse(value);
                if (score == null) {
                  return 'Invalid number';
                }
                if (score < 0 || score > 100) {
                  return 'Range: 0-100';
                }
                return null;
              },
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
