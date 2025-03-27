import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentManuallyBottmSheet extends StatefulWidget {
  final String documentId;
  
  const AddStudentManuallyBottmSheet({
    super.key, 
    required this.documentId
  });

  @override
  State<AddStudentManuallyBottmSheet> createState() => _AddStudentManuallyBottmSheetState();
}

class _AddStudentManuallyBottmSheetState extends State<AddStudentManuallyBottmSheet> {
  final TextEditingController idController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Add Student",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ),
              const SizedBox(height: 20),
              const Text("ID", style: TextStyle(fontWeight: FontWeight.normal)),
              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Enter student id",
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : KButton(
                    onPressed: () async {
                      if (idController.text.trim().isEmpty) {
                        _showErrorDialog("Please enter a student ID");
                        return;
                      }
                      
                      setState(() {
                        isLoading = true;
                      });
                      
                      try {
                        await _addStudentToAttendance();
                      } catch (e) {
                        _showErrorDialog("An error occurred: ${e.toString()}");
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    text: 'Add',
                    fontSize: 22,
                    textColor: Colors.white,
                    backgroundColor: kBlue,
                    borderColor: Colors.white,
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _addStudentToAttendance() async {
    String studentId = idController.text.trim();
    
    // First check if student exists in users collection
    try {
      print("Searching for student with ID: $studentId"); // Debug log
      
      // Try both with and without string conversion to handle different data types
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: studentId)
          .where('role', isEqualTo: 'Student') // Changed from 'student' to 'Student'
          .get();
      
      if (userSnapshot.docs.isEmpty) {
        // Try again with different data type (if ID is stored as number)
        int? numericId = int.tryParse(studentId);
        if (numericId != null) {
          userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('id', isEqualTo: numericId.toString())
              .where('role', isEqualTo: 'Student')
              .get();
        }
      }
      
      if (userSnapshot.docs.isEmpty) {
        _showErrorDialog("No student found with ID: $studentId");
        return;
      }
      
      // Get student data
      DocumentSnapshot studentDoc = userSnapshot.docs.first;
      Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;
      
      // Check if student is already in the attendance list
      DocumentSnapshot attendanceDoc = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.documentId)
          .get();
      
      if (!attendanceDoc.exists) {
        _showErrorDialog("Attendance record not found");
        return;
      }
      
      Map<String, dynamic> attendanceData = attendanceDoc.data() as Map<String, dynamic>;
      List<dynamic> studentList = attendanceData['studentList'] ?? [];
      
      // Check if student is already in the list
      bool studentExists = studentList.any((student) => student['id'] == studentId);
      
      if (studentExists) {
        _showErrorDialog("This student is already in the attendance list");
        return;
      }
      
      // Add student to attendance
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.documentId)
          .update({
        'studentList': FieldValue.arrayUnion([{
          'id': studentData['id'],
          'name': studentData['name'] ?? 
                 ((studentData['firstName'] != null ? 
                   studentData['firstName'] + " " + (studentData['lastName'] ?? "") : 
                   "Unknown")),
          'email': studentData['email'] ?? "",
          'timestamp': Timestamp.now(),
          'subjectName': attendanceData['subjectName'] ?? "GG",
          'academicYear': attendanceData['academicYear'] ?? "4th"
        }])
      });
      
      // Show success message and close the bottom sheet
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student added successfully'))
        );
      }
    } catch (e) {
      _showErrorDialog("Error: ${e.toString()}");
    }
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
