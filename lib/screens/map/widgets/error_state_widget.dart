import 'package:flutter/material.dart';

/// Widget displayed when there's an error loading the schedule
class ErrorStateWidget extends StatelessWidget {
  final String error;

  const ErrorStateWidget({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(
            'Error loading schedule',
            style: TextStyle(
              fontFamily: 'Lexend',
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
