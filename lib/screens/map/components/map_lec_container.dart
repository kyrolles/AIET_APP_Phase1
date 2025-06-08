import 'package:flutter/material.dart';

class LecContainer extends StatelessWidget {
  const LecContainer({
    super.key,
    required this.lec,
    required this.isEmpty,
    this.onTap, // Add onTap callback
  });

  final String lec;
  final Color isEmpty;
  final VoidCallback? onTap; // New parameter for tap handling

  @override
  Widget build(BuildContext context) {
    //* the small container that holds the name of the place. for ex: M1 or CR2
    return GestureDetector(
      // Wrap with GestureDetector
      onTap: onTap, // Call the onTap callback when tapped
      child: Container(
        decoration: BoxDecoration(
            color: isEmpty, borderRadius: BorderRadius.circular(3)),
        margin: const EdgeInsets.only(bottom: 8, top: 8, left: 8),
        height: 35,
        width: 56,
        child: Center(
          child: Text(
            //* the name that will be in the container
            lec,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
