import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KButton extends StatelessWidget {
  final String? svgPath; // Optional SVG path
  final String? text; // Optional text
  final Color textColor; // Text color
  final Color backgroundColor; // Background color
  final double? width; // Optional width for flexibility
  final double? height; // Optional height for flexibility
  final VoidCallback? onPressed; // Callback for button press
  final double? borderWidth; // Optional border width
  final Color? borderColor; // Optional border color

  const KButton({
    super.key,
    this.svgPath, // Optional
    this.text, // Optional
    this.textColor = Colors.white, // Default text color
    this.backgroundColor = const Color(0xFFE5E5E5), // Default background color
    this.width, // Null by default for extendable width
    this.height = 62, // Default height
    this.onPressed, // Null for non-clickable buttons
    this.borderWidth, // Optional border width
    this.borderColor, // Optional border color
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20), // Matches container radius
      child: Padding(
        padding:
            const EdgeInsets.only(left: 13, right: 13, top: 10, bottom: 10),
        child: Container(
          width: width, // Null allows width to adapt to parent constraints
          height: height, // Null allows height to adapt to parent constraints
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: borderWidth != null && borderColor != null
                ? Border.all(color: borderColor!, width: borderWidth!)
                : null, // Optional border
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (svgPath != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(
                    svgPath!,
                    width: 30,
                    height: 30,
                  ),
                ),
              if (text != null)
                Center(
                  child: Text(
                    text!,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 25,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
