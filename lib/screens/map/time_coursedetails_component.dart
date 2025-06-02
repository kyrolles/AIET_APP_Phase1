import 'package:flutter/material.dart';

class ClassSchedule extends StatelessWidget {
  final String period;
  final String courseName;
  final String instructor;
  final String? room; // Optional now

  const ClassSchedule({
    super.key,
    required this.period,
    required this.courseName,
    required this.instructor,
    this.room,
  });

  // Get time based on period
  String _getTimeForPeriod(String period) {
    switch (period.toUpperCase()) {
      case 'P1':
        return '9:00\n10:30';
      case 'P2':
        return '10:50\n12:10';
      case 'P3':
        return '12:20\n1:50';
      case 'P4':
        return '2:00\n3:30';
      default:
        return '';
    }
  }

  // Get color based on period
  Color _getColorForPeriod(String period) {
    switch (period.toUpperCase()) {
      case 'P1':
        return const Color(0xFFEA8990); // Red
      case 'P2':
        return const Color(0xFF90C3EA); // Blue
      case 'P3':
        return const Color(0xFF90EAB8); // Green
      case 'P4':
        return const Color(0xFFEAC490); // Orange
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period and time box
        Column(
          children: [
            Container(
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                color: _getColorForPeriod(period),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  period,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 60,
              child: Text(
                _getTimeForPeriod(period),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        // Course card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  instructor,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                if (room != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        room!,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
