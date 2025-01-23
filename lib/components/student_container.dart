import 'package:flutter/material.dart';
import '../constants.dart';

class StudentContainer extends StatelessWidget {
  const StudentContainer({
    super.key,
    this.onTap,
    this.name,
    this.status,
    this.statusColor,
    this.id,
    this.year,
    required this.title,
    required this.image,
    this.button,
  });

  final Function(BuildContext)? onTap;
  final String? name;
  final String? status;
  final Color? statusColor;
  final String? id;
  final String? year;
  final String title;
  final String image;
  final Function(BuildContext)? button;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(context);
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
                if (name != null)
                  Expanded(
                    child: Text(
                      name!,
                      style: kTextStyleNormal,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (id != null)
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
                if (year != null)
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
                const SizedBox(width: 5), // Add spacing for better layout
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center, // Center the text
                    overflow: TextOverflow.ellipsis, // Enables "..."
                    maxLines: 1, // Keeps it on one line
                  ),
                ),
                const SizedBox(width: 5),
                if (status != null)
                  Text(
                    status!,
                    style:
                        const TextStyle(fontSize: 14, color: Color(0XFF6C7072)),
                  ),
                const SizedBox(width: 6),
                if (statusColor != null)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                    ),
                    height: 22,
                    width: 22,
                  ),
                if (button != null) button!(context),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
