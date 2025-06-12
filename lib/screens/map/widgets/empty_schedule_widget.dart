import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Widget displayed when no classes are scheduled
class EmptyScheduleWidget extends StatelessWidget {
  const EmptyScheduleWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Center(
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations?.noClassesScheduledForRoom ?? 'No classes scheduled',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations?.roomAvailableAllDay ??
                'This room is available all day',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
