import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Widget displayed when there's an error loading the schedule
class ErrorStateWidget extends StatelessWidget {
  final String error;

  const ErrorStateWidget({
    super.key,
    required this.error,
  });
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(
            localizations?.errorLoadingSchedule ?? 'Error loading schedule',
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
