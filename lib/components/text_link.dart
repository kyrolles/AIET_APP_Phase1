import 'package:flutter/material.dart';
import '../constants.dart';

class TextLink extends StatelessWidget {
  const TextLink({
    super.key,
    required this.text,
    this.textLink,
    this.onTap,
  });

  final String text;
  final String? textLink;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(left: 25),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        if (textLink != null)
          GestureDetector(
            onTap: onTap,
            child: Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(right: 15),
              child: Text(
                textLink!,
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
