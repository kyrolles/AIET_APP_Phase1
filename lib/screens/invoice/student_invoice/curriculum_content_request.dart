import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../components/kbutton.dart';
import '../../../constants.dart';
import 'proof_of_enrollment.dart';

class CurriculumContentRequest extends StatefulWidget {
  const CurriculumContentRequest({super.key});

  @override
  State<CurriculumContentRequest> createState() => _GradesReportRequestState();
}

class _GradesReportRequestState extends State<CurriculumContentRequest> {
  GlobalKey<FormState> formKey = GlobalKey();
  late String studentName;
  late String addressedTo;
  late String location;
  late String phoneNumber;
  DocumentLanguage selectedLanguage = DocumentLanguage.arabic;
  StampType selectedStampType = StampType.institute;
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressedToController = TextEditingController();

  final RegExp arabicRegex = RegExp(r'[\u0600-\u06FF\s]+$');
  final RegExp englishRegex = RegExp(r'^[a-zA-Z\s]+$');

  String? validateLanguageText(String? value, DocumentLanguage language) {
    if (value == null || value.isEmpty) {
      return 'Field is required';
    }

    if (language == DocumentLanguage.arabic && !arabicRegex.hasMatch(value)) {
      return 'Please enter text in Arabic';
    } else if (language == DocumentLanguage.english &&
        !englishRegex.hasMatch(value)) {
      return 'Please enter text in English';
    }

    return null;
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : kgreen,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            right: 20,
            left: 20,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 8.0,
            bottom: MediaQuery.of(context).viewInsets.bottom == 0
                ? 16
                : MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    'Curriculum Content Request',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF6C7072),
                    ),
                  ),
                ),
                TextFormField(
                  controller: addressedToController,
                  validator: (value) =>
                      validateLanguageText(value, selectedLanguage),
                  onChanged: (value) {
                    addressedTo = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter the target organization',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Field is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    location = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter Your Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Field is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: KButton(
                    onPressed: _isLoading ? null : _submitRequest,
                    text: _isLoading ? 'Submitting...' : 'Submit Request',
                    backgroundColor: kBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';

      final userData = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userData.docs.isEmpty) throw 'User data not found';

      String languageValue =
          selectedLanguage == DocumentLanguage.english ? 'english' : 'arabic';
      String stampTypeValue =
          selectedStampType == StampType.ministry ? 'ministry' : 'institute';

      await FirebaseFirestore.instance
          .collection('student_affairs_requests')
          .add({
        'addressed_to': addressedTo,
        'comment': '',
        'file_name': '',
        'pdfBase64': '',
        'status': 'No Status',
        'student_id': userData.docs.first['id'],
        'student_name':
            '${userData.docs.first['firstName']} ${userData.docs.first['lastName']}',
        'type': 'Curriculum Content',
        'year': userData.docs.first['academicYear'],
        'created_at': Timestamp.now(),
        'location': location,
        'phone_number': phoneNumber,
        'document_language': languageValue,
        'stamp_type': stampTypeValue,
        'department': userData.docs.first['department']
      });

      _showCustomSnackBar('Request submitted successfully');
      Navigator.pop(context);
    } catch (e) {
      _showCustomSnackBar('Error: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
