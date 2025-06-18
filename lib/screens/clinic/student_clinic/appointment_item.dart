import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppointmentItem extends StatelessWidget {
  final String date;
  final String time;
  final String problem;
  final String status;
  final String appointmentId;
  final VoidCallback onCancelled;

  const AppointmentItem({
    super.key,
    required this.date,
    required this.time,
    required this.problem,
    required this.status,
    required this.appointmentId,
    required this.onCancelled,
  });

  Future<void> _cancelAppointment() async {
    try {
      await FirebaseFirestore.instance
          .collection('clinic_appointments')
          .doc(appointmentId)
          .update({'status': 'cancelled'});

      onCancelled();
    } catch (e) {
      print('Error cancelling appointment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        // Red color for cancelled appointments
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }
//s
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status.capitalize(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: kGrey),
              const SizedBox(width: 4),
              Text(
                time,
                style: const TextStyle(color: kGrey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Problem: $problem',
            style: const TextStyle(color: kGrey),
          ),
          const SizedBox(height: 12),
          if (status == 'pending')
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(localizations?.cancelAppointment ??
                        'Cancel Appointment'),
                    content: Text(localizations?.areYouSureCancelAppointment ??
                        'Are you sure you want to cancel this appointment?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(localizations?.no ?? 'No'),
                      ),
                      TextButton(
                        onPressed: () {
                          _cancelAppointment();
                          Navigator.pop(context);
                        },
                        child: Text(localizations?.yes ?? 'Yes'),
                      ),
                    ],
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                  localizations?.cancelAppointment ?? 'Cancel Appointment'),
            ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
