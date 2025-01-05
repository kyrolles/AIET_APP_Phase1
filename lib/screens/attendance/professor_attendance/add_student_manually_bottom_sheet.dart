import 'package:flutter/material.dart';

class AddStudentManuallyBottmSheet extends StatelessWidget {
  const AddStudentManuallyBottmSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
            const Text("Name", style: TextStyle(fontWeight: FontWeight.normal)),
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
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text("Add", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
