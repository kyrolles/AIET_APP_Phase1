import 'package:flutter/material.dart';

import '../constants.dart';

class StudentContainer extends StatelessWidget {
  const StudentContainer({
    super.key,
    required this.onTap,
    required this.name,
    required this.status,
    required this.statusColor,
    required this.id,
    required this.year,
    required this.title,
    required this.image,
  });
  final Function(BuildContext)? onTap;
  final String name;
  final String status;
  final Color statusColor;
  final String id;
  final String year;
  final String title;
  final String image;

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
        // height: 100,
        child: Column(
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: kTextStyleNormal,
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Text(
                    id,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0XFFFF8504),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Text(
                    year,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                  children: [
                    Text(
                      status,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0XFF6C7072)),
                    ),
                    const SizedBox(width: 3),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                      ),
                      height: 22,
                      width: 22,
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
