import 'package:flutter/material.dart';

class ClassSchedule extends StatelessWidget {
  final String period;
  final String courseName;
  final String instructor;
  final String? groups; // Changed from room to groups
  final bool isCurrentPeriod; // New parameter for highlighting

  const ClassSchedule({
    super.key,
    required this.period,
    required this.courseName,
    required this.instructor,
    this.groups, // Changed from room to groups
    this.isCurrentPeriod = false, // Default to false
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
                color: isCurrentPeriod
                    ? const Color(0xFF2196F3)
                    : _getColorForPeriod(period),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isCurrentPeriod
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2196F3).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  period,
                  style: TextStyle(
                    color: isCurrentPeriod ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: isCurrentPeriod
                  ? BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    )
                  : null,
              child: Text(
                _getTimeForPeriod(period),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isCurrentPeriod
                      ? const Color(0xFF2196F3)
                      : Colors.black87,
                  fontSize: 13,
                  fontWeight:
                      isCurrentPeriod ? FontWeight.bold : FontWeight.w600,
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
              color: isCurrentPeriod
                  ? const Color(0xFF2196F3).withOpacity(0.1)
                  : const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        courseName,
                        style: TextStyle(
                          color: isCurrentPeriod
                              ? const Color(0xFF1976D2)
                              : Colors.black,
                          fontSize: 20,
                          fontWeight: isCurrentPeriod
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  instructor,
                  style: TextStyle(
                    color: isCurrentPeriod
                        ? const Color(0xFF1976D2)
                        : Colors.black87,
                    fontSize: 16,
                    fontWeight:
                        isCurrentPeriod ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (groups != null && groups!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.group_outlined,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          groups!,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
