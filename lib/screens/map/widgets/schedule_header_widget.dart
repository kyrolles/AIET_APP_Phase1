import 'package:flutter/material.dart';

/// Widget that displays the schedule header with current status
class ScheduleHeaderWidget extends StatelessWidget {
  final String statusText;

  const ScheduleHeaderWidget({
    super.key,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            statusText,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
