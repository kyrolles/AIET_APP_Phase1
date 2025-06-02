import 'package:flutter/material.dart';
import '../../constants.dart';

class RoomDetailsBottomSheet extends StatelessWidget {
  final String roomName;
  final bool isEmpty;
  final String roomType; // "Lecture", "Section", or "Lab"

  const RoomDetailsBottomSheet({
    super.key,
    required this.roomName,
    required this.roomType,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Room header
          Row(
            children: [
              // Room icon
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: isEmpty ? kGreyLight : kOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    roomName,
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Room details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$roomType Room: $roomName",
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      isEmpty ? "Available" : "Occupied",
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 14,
                        color: isEmpty ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Current class info (if room is occupied)
          if (!isEmpty) ...[
            const Text(
              "Current Class:",
              style: TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Course: Introduction to Computer Science"),
                  Text("Instructor: Dr. Ahmed Hassan"),
                  Text("Time: 10:00 AM - 11:30 AM"),
                  Text("Student Count: 45"),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Today's schedule
          const Text(
            "Today's Schedule:",
            style: TextStyle(
              fontFamily: 'Lexend',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: const [
                ScheduleItem(
                    time: "8:30 AM - 10:00 AM", course: "Data Structures"),
                ScheduleItem(
                    time: "10:00 AM - 11:30 AM",
                    course: "Introduction to CS",
                    isActive: true),
                ScheduleItem(time: "12:00 PM - 1:30 PM", course: "Algorithms"),
                ScheduleItem(
                    time: "2:00 PM - 3:30 PM", course: "Software Engineering"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Schedule item component
class ScheduleItem extends StatelessWidget {
  final String time;
  final String course;
  final bool isActive;

  const ScheduleItem({
    super.key,
    required this.time,
    required this.course,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? kOrange : Colors.transparent,
              border: Border.all(
                color: isActive ? kOrange : Colors.grey,
                width: 2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(course),
              ],
            ),
          ),
          Icon(
            isActive ? Icons.access_time_filled : Icons.access_time,
            color: isActive ? kOrange : Colors.grey,
            size: 16,
          ),
        ],
      ),
    );
  }
}
