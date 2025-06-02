import 'package:flutter/material.dart';
import '../../constants.dart';
import 'time_coursedetails_component.dart'; // Import ClassSchedule component

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
                width: 59,
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
          const SizedBox(height: 20),

          // Today's schedule - REPLACED WITH CLASSSCHEDULE COMPONENT
          const Text(
            "Today's Schedule:",
            style: TextStyle(
              fontFamily: 'Lexend',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          // Using ClassSchedule component instead of ScheduleItem
          Column(
            children: const [
              ClassSchedule(
                period: "P1",
                courseName: "Data Structures",
                instructor: "Dr. Sara Ahmed",
              ),
              SizedBox(height: 16),
              ClassSchedule(
                period: "P2",
                courseName: "Introduction to CS",
                instructor: "Dr. Ahmed Hassan",
              ),
              SizedBox(height: 16),
              ClassSchedule(
                period: "P3",
                courseName: "Algorithms",
                instructor: "Dr. Mohamed Ali",
              ),
              SizedBox(height: 16),
              ClassSchedule(
                period: "P4",
                courseName: "Software Engineering",
                instructor: "Dr. Layla Ibrahim",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
