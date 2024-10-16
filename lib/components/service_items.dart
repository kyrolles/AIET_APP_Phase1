import 'package:flutter/material.dart';

class ServiceItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const ServiceItem({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 92,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        margin: const EdgeInsets.only(top: 7, bottom: 7, left: 17, right: 17),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 66,
              height: 66,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: const ShapeDecoration(
                        color: Colors.white,
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                      left: 2.54,
                      top: 3,
                      child: ClipOval(
                        child: Image.asset(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.fitHeight,
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
