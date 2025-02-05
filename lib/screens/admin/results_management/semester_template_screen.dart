import 'package:flutter/material.dart';
import '../../../services/results_service.dart';

class SemesterTemplateScreen extends StatefulWidget {
  final String department;
  final int semester;
  
  const SemesterTemplateScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  @override
  State<SemesterTemplateScreen> createState() => _SemesterTemplateScreenState();
}

class _SemesterTemplateScreenState extends State<SemesterTemplateScreen> {
  final ResultsService _resultsService = ResultsService();
  List<Map<String, dynamic>> subjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplate();
  }

  Future<void> _loadTemplate() async {
    setState(() => isLoading = true);
    try {
      subjects = await _resultsService.getSemesterTemplate(
        widget.department,
        widget.semester,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.department} Semester ${widget.semester}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await _resultsService.saveSemesterTemplate(
                widget.department,
                widget.semester,
                subjects,
              );
              if (!mounted) return;
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSubject,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ReorderableListView.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) => ListTile(
                key: ValueKey(index),
                title: TextFormField(
                  initialValue: subjects[index]['name'],
                  onChanged: (value) => subjects[index]['name'] = value,
                  decoration: const InputDecoration(labelText: 'Subject Name'),
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: subjects[index]['code'],
                        onChanged: (value) => subjects[index]['code'] = value,
                        decoration: const InputDecoration(labelText: 'Code'),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: subjects[index]['credits'].toString(),
                        onChanged: (value) => subjects[index]['credits'] = int.tryParse(value) ?? 4,
                        decoration: const InputDecoration(labelText: 'Credits'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => setState(() => subjects.removeAt(index)),
                ),
              ),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = subjects.removeAt(oldIndex);
                  subjects.insert(newIndex, item);
                });
              },
            ),
    );
  }

  void _addSubject() {
    setState(() {
      subjects.add({
        'name': '',
        'code': '',
        'credits': 4,
      });
    });
  }
}
