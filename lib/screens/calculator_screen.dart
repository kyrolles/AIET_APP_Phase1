import 'package:flutter/material.dart';
import '../components/my_app_bar.dart';

class GPACalculatorScreen extends StatefulWidget {
  const GPACalculatorScreen({super.key});

  @override
  GPACalculatorScreenState createState() => GPACalculatorScreenState();
}

class GPACalculatorScreenState extends State<GPACalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _creditsControllers = [];
  final List<String> _grades = [];
  double _gpa = 0.0;
  double _totalCredits = 0.0;

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

  void _addCourse() {
    setState(() {
      _creditsControllers.add(TextEditingController());
      _grades.add('A'); // Default grade
    });
  }

  void _removeCourse(int index) {
    setState(() {
      _creditsControllers[index].dispose();
      _creditsControllers.removeAt(index);
      _grades.removeAt(index);
    });
  }

  void _calculateGPA() {
    double totalPoints = 0.0;
    double totalCredits = 0.0;

    for (int i = 0; i < _creditsControllers.length; i++) {
      final credits = double.tryParse(_creditsControllers[i].text) ?? 0.0;
      final grade = _grades[i];
      final gradePoint = gradePoints[grade] ?? 0.0;

      totalPoints += credits * gradePoint;
      totalCredits += credits;
    }

    setState(() {
      _totalCredits = totalCredits;
      _gpa = totalCredits > 0 ? totalPoints / totalCredits : 0.0;
    });
  }

  @override
  void initState() {
    super.initState();
    _addCourse(); // Add the first course by default
  }

  @override
  void dispose() {
    for (var controller in _creditsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'GPA Calculator',
        onpressed: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Display GPA and Total Credits
              Card(
                color: Colors.blue.shade50,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your GPA: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          // SizedBox(
                          //   width: 40,
                          // ),
                          Text(
                            'Total Credits: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _gpa.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          // const SizedBox(
                          //   width: 32,
                          // ),
                          Text(
                            _totalCredits.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              // List of Courses
              Expanded(
                child: ListView.builder(
                  itemCount: _creditsControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          // Credits input
                          Expanded(
                            child: TextFormField(
                              controller: _creditsControllers[index],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Credits ${index + 1}',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter credits';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Grade dropdown
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: Colors.blue.shade50,
                              elevation: 2,
                              value: _grades[index],
                              items: gradePoints.keys.map((grade) {
                                return DropdownMenuItem(
                                  value: grade,
                                  child: Text(grade),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _grades[index] = value!;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Grade ${index + 1}',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Remove button
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.blue),
                            onPressed: () => _removeCourse(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Add and Calculate Buttons
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addCourse,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.blueAccent,
                    ),
                    label: const Text(
                      'Add Course',
                      style: TextStyle(
                        color: Colors.blueAccent,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _calculateGPA();
                      }
                    },
                    icon: const Icon(
                      Icons.calculate,
                      color: Colors.blueAccent,
                    ),
                    label: const Text(
                      'Calculate GPA',
                      style: TextStyle(
                        color: Colors.blueAccent,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
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
}
