import 'package:flutter/material.dart';

class AnnouncementCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onPressed; // Callback for tap action

  const AnnouncementCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.onPressed, // Required callback
  });

  static const double cardHeight = 120;
  static const double imageWidth = 160; // Fixed width for the image
  static const double imageHeight = 130; // Overflow from top & bottom
  static const Color cardColor = Color(0xFF2980B9);
  static const Color borderColor = Color(0xFFEBEBEB);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed, // Handle tap event
      child: Stack(
        clipBehavior: Clip.none, // Allows the image to overflow
        children: [
          /// **Main Card**
          Container(
            width: double.infinity, // Full width of the screen
            height: cardHeight,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1, color: borderColor),
            ),
            child: Row(
              children: [
                /// Empty space for image (Keeps text aligned)
                const SizedBox(width: imageWidth),

                /// **Text Section**
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// **Floating Image - Overflowing**
          Positioned(
            left: -10, // Slight overflow on the left
            top: -5, // Overflow from top
            bottom: -5, // Overflow from bottom
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Container(
                width: imageWidth,
                height: imageHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1.5, color: Colors.black),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
