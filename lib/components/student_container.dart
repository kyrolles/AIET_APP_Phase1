import 'package:flutter/material.dart';

import '../constants.dart';

class StudentContainer extends StatelessWidget {
  const StudentContainer({
    super.key,
    this.onTap,
    this.name, // Nullable by default
    this.status, // Nullable by default
    this.statusColor, // Nullable by default
    this.id, // Nullable by default
    this.year, // Nullable by default
    required this.title,
    required this.image,
    this.button,
  });

  final Function(BuildContext)? onTap;
  final String? name; // Nullable by default
  final String? status; // Nullable by default
  final Color? statusColor; // Nullable by default
  final String? id; // Nullable by default
  final String? year; // Nullable by default
  final String title;
  final String image;
  final Function(BuildContext)? button;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(context); // Pass the context here
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          children: [
            Row(
              children: [
                if (name != null) // Only show name if it's not null
                  Expanded(
                    child: Text(
                      name!,
                      style: kTextStyleNormal,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (id != null) // Only show ID if it's not null
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Text(
                      id!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                const SizedBox(width: 5),
                if (year != null) // Only show year if it's not null
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Text(
                      year!,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
              ],
            ),
            if (name != null) const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 16.5,
                  backgroundColor: Colors.black,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        image,
                        width: 35,
                        height: 35,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18),
                ),
                Row(
                  spacing: 6,
                  children: [
                    if (status != null) // Only show status if it's not null
                      Text(
                        status!,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0XFF6C7072)),
                      ),
                    // const SizedBox(width: 3),
                    if (statusColor !=
                        null) // Only show status color if it's not null
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                        height: 22,
                        width: 22,
                      ),
                    if (button != null) button!(context)
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
