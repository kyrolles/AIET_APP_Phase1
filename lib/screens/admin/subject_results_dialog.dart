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
    'A': const Color(0xFF4CAF50), // Green
    'A-': const Color(0xFF8BC34A), // Light Green
    'B+': const Color(0xFFCDDC39), // Lime
    'B': const Color(0xFFFFEB3B), // Yellow
    'B-': const Color(0xFFFFC107), // Amber
    'C+': const Color(0xFFFF9800), // Orange
    'C': const Color(0xFFFF5722), // Deep Orange
    'C-': const Color(0xFFE91E63), // Pink
    'D+': const Color(0xFF9C27B0), // Purple
    'D': const Color(0xFF673AB7), // Deep Purple
    'D-': const Color(0xFF3F51B5), // Indigo
    'F': const Color(0xFFF44336), // Red
  };

  @override
  void initState() {
    super.initState();
    editedSubject = Map<String, dynamic>.from(widget.subject);
    // Ensure grade has a default value if null
    editedSubject['grade'] ??= 'F';
    // Ensure credits exist but don't display the field
    editedSubject['credits'] ??= 4;
    // Initialize scores if null
    editedSubject['scores'] ??= {
      'week5': 0.0,
      'week10': 0.0,
      'classwork': 0.0,
      'labExam': 0.0,
      'finalExam': 0.0,
    };

    // Make sure finalExam exists
    final scores = editedSubject['scores'] as Map<String, dynamic>;
    scores['finalExam'] ??= 0.0;

    // Calculate initial scores and grades
    Future.microtask(() => _updateCalculations());
  }

  void _updateGrade(String newGrade) {
    setState(() {
      editedSubject['grade'] = newGrade;
      editedSubject['points'] = gradePoints[newGrade] ?? 0.0;

      // Make sure any manually selected grade is preserved
      // This overrides the auto-calculated grade from _updateCalculations
      editedSubject['manualGradeOverride'] = true;

      // Update totalPoints to reflect new grade
      double points = gradePoints[newGrade] ?? 0.0;
      editedSubject['points'] = points;

      // Calculate GPA contribution
      double credits = (editedSubject['credits'] as num?)?.toDouble() ?? 4.0;
      editedSubject['totalGPA'] = points * credits;
    });
  }

  double _calculateTotalScore() {
    final scores = editedSubject['scores'] as Map<String, dynamic>;
    double week5 = (scores['week5'] as num?)?.toDouble() ?? 0.0;
    double week10 = (scores['week10'] as num?)?.toDouble() ?? 0.0;
    double classwork = (scores['classwork'] as num?)?.toDouble() ??
        (scores['coursework'] as num?)?.toDouble() ??
        0.0;
    double labExam = (scores['labExam'] as num?)?.toDouble() ??
        (scores['lab'] as num?)?.toDouble() ??
        0.0;
    double finalExam = (scores['finalExam'] as num?)?.toDouble() ?? 0.0;

    // Maximum possible scores
    double maxWeek5 = 8.0;
    double maxWeek10 = 12.0;
    double maxClasswork = 10.0;
    double maxLabExam = 10.0;
    double maxFinalExam = 60.0;

    // Normalize the scores to a total of 100%
    double totalPossible = maxWeek5 + maxWeek10 + maxFinalExam;
    double totalObtained = week5 + week10 + finalExam;

    bool hasLabExam = scores['labExam'] != null || scores['lab'] != null;
    bool hasClasswork =
        scores['classwork'] != null || scores['coursework'] != null;

    if (hasLabExam) {
      totalPossible += maxLabExam;
      totalObtained += labExam;
    }

    if (hasClasswork) {
      totalPossible += maxClasswork;
      totalObtained += classwork;
    }

    // Calculate percentage
    if (totalPossible > 0) {
      return (totalObtained / totalPossible) * 100.0;
    } else {
      return 0.0;
    }
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
      child: SingleChildScrollView(
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
                                child: const Icon(Icons.library_books,
                                    color: kBlue, size: 20),
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
                          child:
                              const Icon(Icons.close, color: kGrey, size: 20),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
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
                                          color:
                                              gradeColors[recommendedGrade] ??
                                                  gradeColors['F']!,
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                            color: isSelected
                                ? color.withOpacity(0.15)
                                : Colors.grey.shade50,
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kLightGrey),
                  ),
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scores',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildScoreField(
                        label: 'Week 5',
                        iconData: Icons.calendar_today,
                        value: (editedSubject['scores']
                            as Map<String, dynamic>)['week5'],
                        onChanged: (value) {
                          setState(() {
                            (editedSubject['scores']
                                    as Map<String, dynamic>)['week5'] =
                                double.tryParse(value) ?? 0.0;
                            _updateCalculations();
                          });
                        },
                        maxValue: 8.0,
                      ),
                      _buildScoreField(
                        label: 'Week 10',
                        iconData: Icons.calendar_today,
                        value: (editedSubject['scores']
                            as Map<String, dynamic>)['week10'],
                        onChanged: (value) {
                          setState(() {
                            (editedSubject['scores']
                                    as Map<String, dynamic>)['week10'] =
                                double.tryParse(value) ?? 0.0;
                            _updateCalculations();
                          });
                        },
                        maxValue: 12.0,
                      ),
                      _buildScoreField(
                        label: 'Classwork',
                        iconData: Icons.assignment,
                        value: (editedSubject['scores']
                                as Map<String, dynamic>)['classwork'] ??
                            (editedSubject['scores']
                                as Map<String, dynamic>)['coursework'],
                        onChanged: (value) {
                          setState(() {
                            (editedSubject['scores']
                                    as Map<String, dynamic>)['classwork'] =
                                double.tryParse(value) ?? 0.0;
                            // For backward compatibility
                            (editedSubject['scores']
                                as Map<String, dynamic>)['coursework'] = null;
                            _updateCalculations();
                          });
                        },
                        maxValue: 10.0,
                      ),
                      _buildScoreField(
                        label: 'Lab Exam',
                        iconData: Icons.science,
                        value: (editedSubject['scores']
                                as Map<String, dynamic>)['labExam'] ??
                            (editedSubject['scores']
                                as Map<String, dynamic>)['lab'],
                        onChanged: (value) {
                          setState(() {
                            (editedSubject['scores']
                                    as Map<String, dynamic>)['labExam'] =
                                double.tryParse(value) ?? 0.0;
                            // For backward compatibility
                            (editedSubject['scores']
                                as Map<String, dynamic>)['lab'] = null;
                            _updateCalculations();
                          });
                        },
                        maxValue: 10.0,
                      ),
                      _buildScoreField(
                        label: 'Final Exam',
                        iconData: Icons.edit_document,
                        value: (editedSubject['scores']
                            as Map<String, dynamic>)['finalExam'],
                        onChanged: (value) {
                          setState(() {
                            (editedSubject['scores']
                                    as Map<String, dynamic>)['finalExam'] =
                                double.tryParse(value) ?? 0.0;
                            _updateCalculations();
                          });
                        },
                        maxValue: 60.0,
                      ),
                    ],
                  ),
                ),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Save',
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
      ),
    );
  }

  Widget _buildScoreField({
    required String label,
    required IconData iconData,
    required dynamic value,
    required ValueChanged<String> onChanged,
    double maxValue = 100.0,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGreyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, size: 16, color: kBlue),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value?.toString() ?? '0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
              border: const OutlineInputBorder(),
              suffix: Text(
                '/$maxValue',
                style: const TextStyle(
                  fontSize: 12,
                  color: kGrey,
                ),
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 14,
            ),
            onChanged: (value) {
              onChanged(value);
              _updateCalculations();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }

              double? score = double.tryParse(value);
              if (score == null) {
                return 'Invalid number';
              }
              if (score < 0 || score > maxValue) {
                return 'Range: 0-$maxValue';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _updateCalculations() {
    // First, cap all scores at their maximum values
    Map<String, dynamic> scores = Map<String, dynamic>.from(
        editedSubject['scores'] as Map<String, dynamic>);

    // Define maximum values
    final maxValues = {
      'week5': 8.0,
      'week10': 12.0,
      'classwork': 10.0,
      'coursework': 10.0,
      'labExam': 10.0,
      'lab': 10.0,
      'finalExam': 60.0,
    };

    // Cap values at their maximums
    for (final key in scores.keys.toList()) {
      if (scores[key] != null && maxValues.containsKey(key)) {
        double value = (scores[key] as num).toDouble();
        double max = maxValues[key]!;
        scores[key] = value > max ? max : value;
      }
    }

    // Calculate total score as a percentage of 100
    double totalScore = _calculateTotalScore();

    // If there's no manual grade override, calculate the grade based on total score
    if (editedSubject['manualGradeOverride'] != true) {
      String grade = _getRecommendedGrade(totalScore);
      double points = gradePoints[grade] ?? 0.0;
      double credits = (editedSubject['credits'] as num?)?.toDouble() ?? 4.0;

      setState(() {
        // Make sure we have the proper key names
        if (scores.containsKey('coursework')) {
          scores['classwork'] = scores['coursework'];
          scores.remove('coursework');
        }
        if (scores.containsKey('lab')) {
          scores['labExam'] = scores['lab'];
          scores.remove('lab');
        }

        editedSubject['scores'] = scores;
        editedSubject['grade'] = grade;
        editedSubject['points'] = points;
        editedSubject['totalPoints'] = totalScore;
        editedSubject['totalGPA'] = points * credits;
      });
    } else {
      // Just update the scores but keep the manually selected grade
      setState(() {
        // Make sure we have the proper key names
        if (scores.containsKey('coursework')) {
          scores['classwork'] = scores['coursework'];
          scores.remove('coursework');
        }
        if (scores.containsKey('lab')) {
          scores['labExam'] = scores['lab'];
          scores.remove('lab');
        }

        editedSubject['scores'] = scores;
        editedSubject['totalPoints'] = totalScore;
      });
    }
  }
}
