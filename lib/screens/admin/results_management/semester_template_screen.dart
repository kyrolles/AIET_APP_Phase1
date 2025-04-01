import 'package:flutter/material.dart';
import '../../../services/results_service.dart';
import '../../../constants.dart';
import '../../../components/my_app_bar.dart';
import '../../../components/kbutton.dart';

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
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

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
      
      // Ensure all subjects have the required fields
      for (var subject in subjects) {
        subject['hasLab'] = subject['hasLab'] ?? false;
        subject['hasCoursework'] = subject['hasCoursework'] ?? false;
        subject['isElective'] = subject['isElective'] ?? false;
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: MyAppBar(
          title: 'Semester ${widget.semester} Template',
          onpressed: () => Navigator.pop(context),
          actions: [
            IconButton(
              icon: const Icon(Icons.save, color: kBlue),
              onPressed: _saveTemplate,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: kBlue,
          onPressed: _addSubject,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: kBlue))
            : subjects.isEmpty
                ? _buildEmptyState()
                : _buildSubjectsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.subject, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No subjects added yet',
            style: kTextStyleBold.copyWith(color: kGrey),
          ),
          const SizedBox(height: 16),
          KButton(
            text: 'Add Subject',
            backgroundColor: kBlue,
            icon: Icons.add,
            onPressed: _addSubject,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Text(
                'Subject List',
                style: kTextStyleBold,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kbabyblue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.swap_vert, size: 16, color: kBlue),
                    const SizedBox(width: 4),
                    Text(
                      'Drag to reorder',
                      style: TextStyle(
                        color: kBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: kbabyblue,
              borderRadius: BorderRadius.circular(12),
              boxShadow: kShadow,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: kbabyblue,
              ),
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: subjects.length,
                itemBuilder: (context, index) => _buildSubjectCard(index),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = subjects.removeAt(oldIndex);
                    subjects.insert(newIndex, item);
                  });
                  
                  _scaffoldKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text('Subject order updated'),
                      duration: Duration(seconds: 1),
                      backgroundColor: kBlue,
                    ),
                  );
                },
                proxyDecorator: (Widget child, int index, Animation<double> animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (BuildContext context, Widget? child) {
                      return Material(
                        elevation: 4.0 * animation.value,
                        color: Colors.transparent,
                        shadowColor: kBlue.withOpacity(0.3),
                        child: child,
                      );
                    },
                    child: child,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(int index) {
    final subject = subjects[index];
    final bool hasLab = subject['hasLab'] ?? false;
    final bool hasCoursework = subject['hasCoursework'] ?? false;
    final bool isElective = subject['isElective'] ?? false;
    
    return Card(
      key: ValueKey(index),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isElective ? kOrange.withOpacity(0.1) : kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Subject ${index + 1}${isElective ? ' (Elective)' : ''}',
                    style: TextStyle(
                      color: isElective ? kOrange : kPrimaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                // Drag handle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.drag_handle,
                    size: 16,
                    color: kGrey,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() => subjects.removeAt(index)),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: subject['name'],
              onChanged: (value) => subject['name'] = value,
              decoration: _inputDecoration('Subject Name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: subject['code'],
                    onChanged: (value) => subject['code'] = value,
                    decoration: _inputDecoration('Code'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: subject['credits'].toString(),
                    onChanged: (value) => subject['credits'] = int.tryParse(value) ?? 4,
                    decoration: _inputDecoration('Credits'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildOptionSwitch(
                  title: 'Lab',
                  value: hasLab,
                  onChanged: (value) {
                    setState(() {
                      subject['hasLab'] = value;
                    });
                  },
                  icon: Icons.science_outlined,
                ),
                const SizedBox(width: 8),
                _buildOptionSwitch(
                  title: 'Coursework',
                  value: hasCoursework,
                  onChanged: (value) {
                    setState(() {
                      subject['hasCoursework'] = value;
                    });
                  },
                  icon: Icons.assignment_outlined,
                ),
                const SizedBox(width: 8),
                _buildOptionSwitch(
                  title: 'Elective',
                  value: isElective,
                  onChanged: (value) {
                    setState(() {
                      subject['isElective'] = value;
                    });
                  },
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: value ? kbabyblue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? kBlue : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: value ? kBlue : Colors.grey,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: value ? kBlue : Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: kBlue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeTrackColor: kbabyblue,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14, color: kGrey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kGreyLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kGreyLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kBlue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Future<void> _saveTemplate() async {
    setState(() => isLoading = true);
    try {
      await _resultsService.saveSemesterTemplate(
        widget.department,
        widget.semester,
        subjects,
      );
      if (!mounted) return;
      
      _scaffoldKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Template saved successfully'),
          backgroundColor: kgreen,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Error saving template: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _addSubject() {
    setState(() {
      subjects.add({
        'name': '',
        'code': '',
        'credits': 4,
        'hasLab': false,
        'hasCoursework': false,
        'isElective': false,
      });
    });
    
    // Show a snackbar when a subject is added
    _scaffoldKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('New subject added'),
        duration: Duration(seconds: 1),
        backgroundColor: kBlue,
      ),
    );
  }
}
