import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KButton extends StatelessWidget {
  final String? svgPath; // Optional SVG path
  final String? text; // Optional text
  final Color textColor; // Text color
  final Color backgroundColor; // Background color
  final Color? rippleColor; // New parameter for ripple color
  final double? width; // Optional width for flexibility
  final double? height; // Optional height for flexibility
  final VoidCallback? onPressed; // Callback for button press
  final double? borderWidth; // Optional border width
  final Color? borderColor; // Optional border color
  final double? fontSize; // Optional font size for text
  final double? svgWidth; // Optional width for the SVG icon
  final double? svgHeight; // Optional height for the SVG icon
  final DecorationImage? backgroundImage; // Optional background image
  final EdgeInsetsGeometry? padding; // Optional padding (default maintained)
  final EdgeInsetsGeometry? margin; // New optional margin parameter

  const KButton({
    super.key,
    this.svgPath, // Optional
    this.text, // Optional
    this.textColor = Colors.white, // Default text color
    this.backgroundColor = const Color(0xFFE5E5E5), // Default background color
    this.rippleColor, // Optional ripple color
    this.width, // Null by default for extendable width
    this.height = 62, // Default height
    this.onPressed, // Null for non-clickable buttons
    this.borderWidth, // Optional border width
    this.borderColor, // Optional border color
    this.fontSize = 25, // Default font size for text
    this.svgWidth = 30, // Default SVG width
    this.svgHeight = 30, // Default SVG height
    this.backgroundImage, // Optional background image
    this.padding, // Allow overriding default padding
    this.margin, // Optional margin
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin, // Apply optional margin
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: borderWidth != null && borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth!)
            : null, // Optional border
        image: backgroundImage, // Optional background image
      ),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: rippleColor ?? Colors.white.withOpacity(0.3),
          highlightColor: rippleColor ?? Colors.white.withOpacity(0.1),
          onTap: onPressed,
          child: Padding(
            padding: padding ??
                const EdgeInsets.only(
                    left: 13,
                    right: 13,
                    top: 10,
                    bottom: 10), // Use default if null
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (svgPath != null)
                  Align(
                    alignment:
                        text != null ? Alignment.centerLeft : Alignment.center,
                    child: SvgPicture.asset(
                      svgPath!,
                      width: svgWidth, // Customizable SVG width
                      height: svgHeight, // Customizable SVG height
                    ),
                  ),
                if (text != null)
                  Center(
                    child: Text(
                      text!,
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize, // Customizable font size
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w600,
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
