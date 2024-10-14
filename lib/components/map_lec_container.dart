import 'package:flutter/material.dart';

class LecContainer extends StatelessWidget {
  const LecContainer({super.key, required this.lec, required this.isEmpty});
  final String lec;
  final Color isEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: isEmpty, borderRadius: BorderRadius.circular(3)),
      margin: const EdgeInsets.only(bottom: 8, top: 8, left: 8),
      height: 35,
      width: 56,
      child: Center(
        child: Text(
          lec,
          style: const TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
