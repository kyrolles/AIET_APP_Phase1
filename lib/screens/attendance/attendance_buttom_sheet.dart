import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';

class AttendanceButtomSheet extends StatelessWidget {
  const AttendanceButtomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              bottom: 32.0, left: 16.0, right: 16.0, top: 22.0),
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
              const TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter the subject code',
                ),
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter the period',
                ),
              ),
              const SizedBox(height: 20),
              MyButton(
                text: 'Generate QR Code',
                onPressed: () {
                  Navigator.pushNamed(context, '/attendance/archive');
                },
                height: 50,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    this.onPressed,
    required this.text,
    this.color,
    this.textColor,
    required this.height,
    required this.width,
  });

  final Function()? onPressed;
  final String text;
  final Color? color;
  final Color? textColor;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? kPrimaryColor,
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 21.7,
              fontWeight: FontWeight.w700,
              color: textColor ?? Colors.white)),
    );
  }
}
