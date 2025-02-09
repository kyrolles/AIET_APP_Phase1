import 'package:flutter/material.dart';

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
  }

  void _updateGrade(String newGrade) {
    setState(() {
      editedSubject['grade'] = newGrade;
      editedSubject['points'] = gradePoints[newGrade] ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${editedSubject['name']}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grade Dropdown
              DropdownButtonFormField<String>(
                value: editedSubject['grade'] as String,
                decoration: const InputDecoration(labelText: 'Grade'),
                items: gradePoints.keys.map((grade) {
                  return DropdownMenuItem(
                    value: grade,
                    child: Text('$grade (${gradePoints[grade]?.toStringAsFixed(1)})'),
                  );
                }).toList(),
                onChanged: (value) => _updateGrade(value!),
              ),
              const SizedBox(height: 16),
              
              // Score inputs
              TextFormField(
                initialValue: editedSubject['scores']['week5'].toString(),
                decoration: const InputDecoration(labelText: '5th Week Score'),
                keyboardType: TextInputType.number,
                validator: (value) => _validateScore(value),
                onSaved: (value) {
                  editedSubject['scores']['week5'] = double.parse(value ?? '0');
                },
              ),
              TextFormField(
                initialValue: editedSubject['scores']['week10'].toString(),
                decoration: const InputDecoration(labelText: '10th Week Score'),
                keyboardType: TextInputType.number,
                validator: (value) => _validateScore(value),
                onSaved: (value) {
                  editedSubject['scores']['week10'] = double.parse(value ?? '0');
                },
              ),
              TextFormField(
                initialValue: editedSubject['scores']['coursework'].toString(),
                decoration: const InputDecoration(labelText: 'Coursework Score'),
                keyboardType: TextInputType.number,
                validator: (value) => _validateScore(value),
                onSaved: (value) {
                  editedSubject['scores']['coursework'] = double.parse(value ?? '0');
                },
              ),
              TextFormField(
                initialValue: editedSubject['scores']['lab'].toString(),
                decoration: const InputDecoration(labelText: 'Lab Score'),
                keyboardType: TextInputType.number,
                validator: (value) => _validateScore(value),
                onSaved: (value) {
                  editedSubject['scores']['lab'] = double.parse(value ?? '0');
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onSave(editedSubject);
            }
          },
          child: const Text('Save'),
        ),
      ],
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
