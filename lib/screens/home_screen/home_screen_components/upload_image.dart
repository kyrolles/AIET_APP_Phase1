import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

class UploadImage extends StatefulWidget {
  const UploadImage({super.key, this.imageBase64});
  final String? imageBase64;

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage>
    with SingleTickerProviderStateMixin {
  // Animation controller for blur effect
  late AnimationController _blurController;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _blurController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Define the blur animation
    _blurAnimation = Tween<double>(begin: 0, end: 10).animate(_blurController);
  }

  @override
  void dispose() {
    _blurController.dispose();
    super.dispose();
  }

  void _showFullScreenImage(BuildContext context, String imageBase64) {
    _blurController.forward();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: AnimatedBuilder(
            animation: _blurAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _blurAnimation.value,
                      sigmaY: _blurAnimation.value,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _blurController.reverse().then((_) {
                        Navigator.of(context).pop();
                      });
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: InteractiveViewer(
                        panEnabled: true,
                        boundaryMargin: const EdgeInsets.all(0),
                        minScale: 1.0,
                        maxScale: 3.0,
                        child: Center(
                          child: Image.memory(
                            base64Decode(imageBase64),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? imageBase64 = widget.imageBase64;

    if (imageBase64 != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: GestureDetector(
          onTap: () {
            _showFullScreenImage(context, imageBase64);
          },
          child: Image.memory(
            base64Decode(imageBase64),
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
