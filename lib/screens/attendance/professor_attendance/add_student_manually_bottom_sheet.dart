import 'package:flutter/material.dart';
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/constants.dart';

class AddStudentManuallyBottmSheet extends StatelessWidget {
  const AddStudentManuallyBottmSheet({super.key});

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
              const Text("Name",
                  style: TextStyle(fontWeight: FontWeight.normal)),
              const TextField(
                decoration: InputDecoration(
                  hintText: "Enter student name",
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              const Text("ID", style: TextStyle(fontWeight: FontWeight.normal)),
              const TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter student id",
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: KButton(
                  onPressed: () {
                    // Add student
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
}
