import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/screens/attendance/professor_attendance/attendance_archive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class Period {
  String number;
  String timeRange;
  bool isSelected;
  Color color;

  Period({
    required this.number,
    required this.timeRange,
    required this.isSelected,
    required this.color,
  });
}

class AttendanceButtomSheet extends StatefulWidget {
  final String defaultStatus;
  
  const AttendanceButtomSheet({
    super.key, 
    this.defaultStatus = 'none'
  });

  @override
  State<AttendanceButtomSheet> createState() => _AttendanceButtomSheetState();
}

class _AttendanceButtomSheetState extends State<AttendanceButtomSheet> {
  final TextEditingController _subjectCodeController = TextEditingController();
  Map<String, String> _allSubjects = {};
  List<MapEntry<String, String>> _filteredSubjects = [];
  bool _showDropdown = false;
  String _selectedSubjectName = '';
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  
  final List<Period> periods = [
    Period(number: '1', timeRange: '9:00-10:30', isSelected: false, color: Colors.blue),
    Period(number: '2', timeRange: '10:40-12:10', isSelected: false, color: Colors.green),
    Period(number: '3', timeRange: '12:20-1:50', isSelected: false, color: Colors.orange),
    Period(number: '4', timeRange: '2:00-3:30', isSelected: false, color: Colors.red),
  ];

  
  String? getSelectedPeriod() {
    final selectedPeriod = periods.firstWhere(
      (period) => period.isSelected,
      orElse: () => Period(number: '', timeRange: '', isSelected: false, color: Colors.grey),
    );
    return selectedPeriod.number.isEmpty ? null : selectedPeriod.number;
  }

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  
  Future<void> _loadSubjects() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/attendance/all_subjects.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      setState(() {
        
        _allSubjects = Map<String, String>.from(jsonData);
      });
      debugPrint('Loaded ${_allSubjects.length} subjects'); 
    } catch (e) {
      debugPrint('Error loading subjects: $e');
    }
  }

  void _showSubjectDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, -200), 
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                itemCount: _filteredSubjects.length,
                itemBuilder: (context, index) {
                  final entry = _filteredSubjects[index];
                  return ListTile(
                    dense: true,
                    title: Row(
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _subjectCodeController.text = entry.key;
                        _selectedSubjectName = entry.value;
                        _showDropdown = false;
                      });
                      _hideSubjectDropdown();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSubjectDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.length >= 2) {
        _filteredSubjects = _allSubjects.entries
            .where((entry) => entry.key.toLowerCase().contains(query.toLowerCase()))
            .toList();
        if (_filteredSubjects.isNotEmpty && !_showDropdown) {
          _showDropdown = true;
          _showSubjectDropdown();
        } else if (_filteredSubjects.isEmpty && _showDropdown) {
          _showDropdown = false;
          _hideSubjectDropdown();
        }
      } else {
        _filteredSubjects = [];
        _showDropdown = false;
        _hideSubjectDropdown();
      }
    });
  }

  @override
  void dispose() {
    _hideSubjectDropdown();
    _subjectCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              bottom: 22.0, left: 16.0, right: 16.0, top: 22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  'QR Code',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF6C7072)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Subject Code'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: TextField(
                      controller: _subjectCodeController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Enter the subject code',
                        labelStyle: TextStyle(color: kGrey),
                      ),
                    ),
                  ),
                  if (_showDropdown && _filteredSubjects.isNotEmpty)
                    Transform.translate(
                      offset: Offset(0, MediaQuery.of(context).viewInsets.bottom > 0 ? -MediaQuery.of(context).viewInsets.bottom - 50 : 0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          itemCount: _filteredSubjects.length,
                          itemBuilder: (context, index) {
                            final entry = _filteredSubjects[index];
                            return ListTile(
                              dense: true,
                              title: Row(
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  _subjectCodeController.text = entry.key;
                                  _selectedSubjectName = entry.value;
                                  _showDropdown = false;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  if (_selectedSubjectName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _selectedSubjectName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Period'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var period in periods)
                    PeriodButton(
                      period: period,
                      ontap: () {
                        setState(() {
                          for (var p in periods) {
                            p.isSelected = false;
                          }
                          period.isSelected = true;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 25),
              KButton(
                text: 'Generate QR Code',
                backgroundColor: kBlue,
                onPressed: () async {
                  final subjectCode = _subjectCodeController.text.trim();
                  final selectedPeriod = getSelectedPeriod();

                  if (subjectCode.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter a subject code')),
                    );
                    return;
                  }

                  if (_selectedSubjectName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select a subject from the dropdown')),
                    );
                    return;
                  }

                  if (selectedPeriod == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a period')),
                    );
                    return;
                  }

                  
                  try {
                    
                    final User? currentUser = FirebaseAuth.instance.currentUser;
                    String? userEmail = currentUser?.email;
                    
                    
                    String profName = '';
                    if (currentUser != null) {
                      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
                          .collection('users')
                          .where('email', isEqualTo: userEmail)
                          .limit(1)
                          .get();
                      
                      if (userSnapshot.docs.isNotEmpty) {
                        DocumentSnapshot userDoc = userSnapshot.docs.first;
                        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
                        profName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
                      }
                    }
                    
                    
                    DocumentReference docRef = await FirebaseFirestore.instance.collection('attendance').add({
                      'subjectName': _selectedSubjectName, 
                      'period': selectedPeriod,
                      'studentsList': [],
                      'status': widget.defaultStatus,
                      'profName': profName,
                      'email': userEmail,
                      'timestamp': DateTime.now().toIso8601String(),
                    });

                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceArchive(
                            subjectName: _selectedSubjectName, 
                            period: selectedPeriod,
                            existingDocId: docRef.id,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating attendance: $e')),
                      );
                    }
                  }
                },
                fontSize: 22,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

 
}

class PeriodButton extends StatelessWidget {
  const PeriodButton({
    super.key,
    required this.period,
    this.ontap,
  });

  final Period period;
  final Function()? ontap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: period.isSelected
          ? Container(
              height: 60, 
              width: 85,
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(14))),
              child: Center(
                child: Container(
                  height: 56, 
                  width: 81,
                  decoration: BoxDecoration(
                      color: period.color,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12))),
                  child: Center(
                    child: unPressedSmallButton(),
                  ),
                ),
              ),
            )
          : unPressedSmallButton(),
    );
  }

  Widget unPressedSmallButton() {
    return Container(
      height: 50, 
      width: 75,
      decoration: BoxDecoration(
          color: period.color,
          borderRadius: const BorderRadius.all(Radius.circular(12))),
      child: Center(
        child: Text(
          'P${period.number}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }
}
