import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import '../../../constants.dart';

class ProofOfEnrollment extends StatefulWidget {
  const ProofOfEnrollment({
    super.key,
  });

  @override
  State<ProofOfEnrollment> createState() => _ProofOfEnrollmentState();
}

class _ProofOfEnrollmentState extends State<ProofOfEnrollment> {
  bool? isChecked = false;
  late String studentName;
  late String addressedTo;

  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context)
            .viewInsets
            .bottom, // Adjusts for the keyboard
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'اثبات القيد',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0XFF6C7072)),
                      ),
                    ]),
                const SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Feild is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    studentName = value;
                  },
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'ادخل الاسم',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Feild is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    addressedTo = value;
                  },
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'ادخل الجهة الموجه إليها',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Checkbox(
                        value: isChecked,
                        activeColor: kPrimaryColor,
                        onChanged: (newBool) {
                          setState(() {
                            isChecked = newBool ?? false;
                          });
                        },
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'هل تريد ختم النسر ؟',
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            '(!ملحوظة: سيأخذ الكثير من الوقت)',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                KButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      String? email = FirebaseAuth.instance.currentUser!.email;

                      final QuerySnapshot snapshot = await FirebaseFirestore
                          .instance
                          .collection('users')
                          .where('email', isEqualTo: email)
                          .get();
                      FirebaseFirestore.instance.collection('requests').add({
                        'addressed_to': addressedTo,
                        'comment': '',
                        'file_name': '',
                        'pdfBase64': '',
                        'stamp': isChecked ?? false,
                        'status': 'No Status',
                        'student_id': snapshot.docs.first['id'],
                        'student_name': studentName,
                        'training_score': 0,
                        'type': 'Proof of enrollment',
                        'year': snapshot.docs.first['academicYear'],
                        'created_at': Timestamp.now(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Request sent successfully'),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  text: 'Submit',
                  backgroundColor: const Color(0xFF0693F1),
                  padding: const EdgeInsets.all(0),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
