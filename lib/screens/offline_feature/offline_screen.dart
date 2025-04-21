import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SVG Image
            SvgPicture.asset(
              'assets/project_image/undraw_going-offline_v4oo.svg',
              height: 280,
            ),
            const SizedBox(height: 48),

            // Offline message
            const Text(
              "You're Offline",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF393348),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "There are no bottons to push\nJust turn off your internet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
