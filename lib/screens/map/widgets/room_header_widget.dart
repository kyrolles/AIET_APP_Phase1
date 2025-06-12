import 'package:flutter/material.dart';
import '../../../constants.dart';

/// Widget that displays the room header information
class RoomHeaderWidget extends StatelessWidget {
  final String roomName;
  final String roomType;
  final bool isEmpty;

  const RoomHeaderWidget({
    super.key,
    required this.roomName,
    required this.roomType,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
