import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
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
                  "Please check your internet connection and try again",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),

                const SizedBox(height: 40),

                // Retry button
                ElevatedButton(
                  onPressed: () {
                    // Retry connection logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38B6FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Try Again",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
