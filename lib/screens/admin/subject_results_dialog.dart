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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController week5Controller;
  late TextEditingController week10Controller;
  late TextEditingController courseworkController;
  late TextEditingController labController;
  String selectedGrade = 'A';
  final List<String> grades = ['A', 'B', 'C', 'D', 'F'];

  @override
  void initState() {
    super.initState();
    final scores = widget.subject['scores'] as Map<String, dynamic>;
    week5Controller = TextEditingController(text: scores['week5']?.toString() ?? '0.0');
    week10Controller = TextEditingController(text: scores['week10']?.toString() ?? '0.0');
    
    if (scores['coursework'] != null) {
      courseworkController = TextEditingController(text: scores['coursework'].toString());
    }
    
    if (scores['lab'] != null) {
      labController = TextEditingController(text: scores['lab'].toString());
    }
    
    selectedGrade = widget.subject['grade'];
  }

  @override
  Widget build(BuildContext context) {
    final scores = widget.subject['scores'] as Map<String, dynamic>;
    
    return AlertDialog(
      title: Text(widget.subject['name']),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedGrade,
                decoration: const InputDecoration(labelText: 'Grade'),
                items: grades.map((grade) => 
                  DropdownMenuItem(value: grade, child: Text(grade))
                ).toList(),
                onChanged: (value) {
                  setState(() => selectedGrade = value!);
                },
              ),
              TextFormField(
                controller: week5Controller,
                decoration: const InputDecoration(labelText: '5th Week Score'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: week10Controller,
                decoration: const InputDecoration(labelText: '10th Week Score'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              if (scores['coursework'] != null)
                TextFormField(
                  controller: courseworkController,
                  decoration: const InputDecoration(labelText: 'Coursework Score'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              if (scores['lab'] != null)
                TextFormField(
                  controller: labController,
                  decoration: const InputDecoration(labelText: 'Lab Score'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
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
              final updatedSubject = {
                ...widget.subject,
                'grade': selectedGrade,
                'scores': {
                  'week5': double.parse(week5Controller.text),
                  'week10': double.parse(week10Controller.text),
                  if (scores['coursework'] != null)
                    'coursework': double.parse(courseworkController.text),
                  if (scores['lab'] != null)
                    'lab': double.parse(labController.text),
                },
              };
              widget.onSave(updatedSubject);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    week5Controller.dispose();
    week10Controller.dispose();
    courseworkController.dispose();
    labController.dispose();
    super.dispose();
  }
}
