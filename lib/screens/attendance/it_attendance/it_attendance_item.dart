import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';

class ITAttendanceItem extends StatelessWidget {
  final String subject;
  final String period;
  final String professor;
  final int total;
  final String timestamp;
  final String className; 
  final Function() onEdit;
  final Function() onApprove;

  const ITAttendanceItem({
    super.key,
    required this.subject,
    required this.period,
    required this.professor,
    required this.total,
    required this.timestamp,
    required this.className,
    required this.onEdit,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'P$period',
                  style: const TextStyle(
                    color: kDarkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: kGrey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Professor: $professor',
                  style: const TextStyle(color: kGrey),
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.class_, size: 16, color: kGrey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Class: $className',
                  style: const TextStyle(color: kGrey),
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.people, size: 16, color: kGrey),
              const SizedBox(width: 4),
              Text(
                'Students: $total',
                style: const TextStyle(color: kGrey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: kGrey),
              const SizedBox(width: 4),
              Text(
                'Submitted: ${_formatTimestamp(timestamp)}',
                style: const TextStyle(color: kGrey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: kBlue),
                label: const Text('Edit', style: TextStyle(color: kBlue)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}