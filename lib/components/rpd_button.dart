import 'package:flutter/material.dart';

class RejectPendinDoneButton extends StatelessWidget {
  const RejectPendinDoneButton({
    super.key,
    required this.onpressed,
    required this.color,
    required this.content,
  });
  final Function() onpressed;
  final Color color;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onpressed,
        child: Text(content, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
