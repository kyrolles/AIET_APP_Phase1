import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants.dart';
import '../../models/schedule_model.dart';

class ClassSessionCard extends StatelessWidget {
  final ClassSession session;

  const ClassSessionCard({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        boxShadow: kShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left sidebar with period time indicator
            Container(
              width: 4,
              height: 70,
              decoration: BoxDecoration(
                color: _getAccentColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),

            // Middle section with class info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.courseName == 'DAY OFF'
                        ? (AppLocalizations.of(context)?.dayOff ?? 'DAY OFF')
                        : session.courseName,
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (session.courseCode.isNotEmpty)
                    Text(
                      session.courseCode,
                      style: const TextStyle(
                        color: kGrey,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          session.instructor,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right section with period and location
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Time indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTimeIndicatorColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getPeriodTime(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Location
                if (session.location.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        session.location,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (session.courseName == 'DAY OFF') {
      return Colors.grey[100]!;
    }

    if (session.isLab) {
      return const Color(0xFFFFF9C4); // Light yellow for labs
    }

    if (session.isTutorial) {
      return const Color(0xFFE1F5FE); // Light blue for tutorials
    }

    return Colors.white;
  }

  Color _getAccentColor() {
    if (session.courseName == 'DAY OFF') {
      return Colors.grey;
    }

    if (session.isLab) {
      return const Color(0xFFFFD600); // Amber for labs
    }

    if (session.isTutorial) {
      return const Color(0xFF039BE5); // Light blue for tutorials
    }

    switch (session.classIdentifier.department) {
      case Department.C:
        return kPrimaryColor;
      case Department.E:
        return const Color(0xFF4CAF50); // Green for communications
      case Department.I:
        return const Color(0xFFFF5722); // Deep orange for industrial
      case Department.M:
        return const Color(0xFF9C27B0); // Purple for mechatronics
      case Department.G:
        return const Color(0xFF607D8B); // Blue grey for general
    }
  }

  Color _getTimeIndicatorColor() {
    if (session.isLab) {
      return const Color(0xFFFBC02D); // Darker amber for labs
    }

    if (session.isTutorial) {
      return const Color(0xFF0288D1); // Darker blue for tutorials
    }

    return kPrimaryColor;
  }

  String _getPeriodTime() {
    switch (session.periodNumber) {
      case 1:
        return 'P1 (9:00-10:30)';
      case 2:
        return 'P2 (10:40-12:10)';
      case 3:
        return 'P3 (12:20-1:50)';
      case 4:
        return 'P4 (2:00-3:30)';
      case 5:
        return 'P5 (3:40-5:10)';
      default:
        return 'Unknown';
    }
  }
}
