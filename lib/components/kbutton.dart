import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants.dart';

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
  final bool elevated; // Whether to add elevation effect
  final IconData? icon; // Optional icon (alternative to SVG)
  final Gradient? gradient; // Optional gradient for the background
  final double borderRadius; // Border radius for the button

  const KButton({
    super.key,
    this.svgPath, // Optional
    this.text, // Optional
    this.textColor = Colors.white, // Default text color
    this.backgroundColor = const Color(0xFFE5E5E5), // Default background color
    this.rippleColor, // Optional ripple color
    this.width, // Null by default for extendable width
    this.height = 48, // Updated default height
    this.onPressed, // Null for non-clickable buttons
    this.borderWidth, // Optional border width
    this.borderColor, // Optional border color
    this.fontSize = 14, // Updated default font size for text
    this.svgWidth = 20, // Updated default SVG width
    this.svgHeight = 20, // Updated default SVG height
    this.backgroundImage, // Optional background image
    this.padding, // Allow overriding default padding
    this.margin, // Optional margin
    this.elevated = false, // No elevation by default
    this.icon, // Optional icon
    this.gradient, // Optional gradient
    this.borderRadius = 12, // Default border radius
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin, // Apply optional margin
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderWidth != null && borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth!)
            : null, // Optional border
        image: backgroundImage, // Optional background image
        boxShadow: elevated ? kShadow : null,
      ),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: rippleColor ?? Colors.white.withOpacity(0.3),
          highlightColor: rippleColor ?? Colors.white.withOpacity(0.1),
          onTap: onPressed,
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                if (icon != null)
                  Align(
                    alignment:
                        text != null ? Alignment.centerLeft : Alignment.center,
                    child: Icon(
                      icon,
                      color: textColor,
                      size: svgWidth ?? 20,
                    ),
                  ),
                if (text != null)
                  Row(
                    mainAxisAlignment: (svgPath != null || icon != null) 
                        ? MainAxisAlignment.center 
                        : MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (svgPath != null || icon != null) 
                        const SizedBox(width: 28),
                      Flexible(
                        child: Text(
                          text!,
                          style: TextStyle(
                            color: textColor,
                            fontSize: fontSize, // Customizable font size
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
