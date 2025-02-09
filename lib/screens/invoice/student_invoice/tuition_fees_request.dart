import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/models/request_model.dart';

class TuitionFeesPreview extends StatefulWidget {
  const TuitionFeesPreview({super.key, required this.requestsList});

  final List<Request> requestsList;

  @override
  State<TuitionFeesPreview> createState() => _TuitionFeesPreviewState();
}

class _TuitionFeesPreviewState extends State<TuitionFeesPreview> {
  bool payInInstallments = false;

  // Show custom snackbar function
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
    return SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    'Tuition Fees',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6C7072)),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    'Do you want to pay in installments ?',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              YesNoButton(
                ontap: () {
                  setState(() {
                    payInInstallments = true;
                  });
                },
                text: 'Yes',
                isSelected: payInInstallments,
                color: const Color.fromARGB(255, 197, 200, 206),
              ),
              YesNoButton(
                ontap: () {
                  setState(() {
                    payInInstallments = false;
                  });
                },
                text: 'No',
                isSelected: !payInInstallments,
                color: const Color.fromARGB(255, 197, 200, 206),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: KButton(
              onPressed: () async {
                String? email = FirebaseAuth.instance.currentUser!.email;

                final QuerySnapshot snapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: email)
                    .get();

                int counter = 0;
                for (var i = 0; i < widget.requestsList.length; i++) {
                  if (widget.requestsList[i].studentId ==
                          snapshot.docs.first['id'] &&
                      widget.requestsList[i].type == 'Tuition Fees' &&
                      widget.requestsList[i].createdAt.toDate().year ==
                          DateTime.now().year) {
                    counter++;
                  }
                }
                //* the limit for Tuitin Fees requests is 3
                if (counter < 3) {
                  FirebaseFirestore.instance.collection('requests').add({
                    'addressed_to': '',
                    'comment': '',
                    'file_name': '',
                    'pdfBase64': '',
                    //!pay in installments or not
                    'stamp': payInInstallments,
                    'status': 'No Status',
                    'student_id': snapshot.docs.first['id'],
                    'student_name':
                        '${snapshot.docs.first['firstName']} ${snapshot.docs.first['lastName']}'
                            .trim(),
                    'training_score': 0,
                    'type': 'Tuition Fees',
                    'year': snapshot.docs.first['academicYear'],
                    'created_at': Timestamp.now(),
                  });
                  // ignore: use_build_context_synchronously
                  _showCustomSnackBar('Request sent successfully');
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } else {
                  _showCustomSnackBar(
                      'You have reached the maximum number of requests',
                      isError: true);
                }
              },
              text: 'Request',
              fontSize: 21.7,
              textColor: Colors.white,
              backgroundColor: kBlue,
              borderColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class YesNoButton extends StatelessWidget {
  const YesNoButton({
    super.key,
    required this.text,
    this.ontap,
    required this.isSelected,
    required this.color,
  });

  final Function()? ontap;
  final bool isSelected;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: isSelected
          ? Container(
              height: 60,
              width: 80,
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(14))),
              child: Center(
                child: Container(
                  height: 56,
                  width: 76,
                  decoration: BoxDecoration(
                      color: color,
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
      width: 70,
      decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(12))),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
    );
  }
}
