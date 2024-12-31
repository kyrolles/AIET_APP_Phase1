import 'package:flutter/material.dart';
import '../constants.dart';

class ProofOfEnrollment extends StatefulWidget {
  const ProofOfEnrollment({
    super.key,
  });

  @override
  State<ProofOfEnrollment> createState() => _ProofOfEnrollmentState();
}

class _ProofOfEnrollmentState extends State<ProofOfEnrollment> {
  bool? isChecked = false;

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
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'ادخل الاسم',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
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
                      activeColor: kPrimary,
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
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Submit',
                    style: TextStyle(
                        fontSize: 21.7,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFFFFF))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
