import 'package:flutter/material.dart';

class AppointmentItem extends StatelessWidget {
  const AppointmentItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 200,
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD8E8F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Column(
              children: [
                Text(
                  'Time',
                  style: TextStyle(
                    fontFamily: 'lexend',
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '9:00',
                  style: TextStyle(
                    fontFamily: 'lexend',
                    color: Colors.black,
                  ),
                ),
                Text(
                  '10:30',
                  style: TextStyle(
                    fontFamily: 'lexend',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            VerticalDivider(
              color: Colors.white,
              indent: 30,
            ),
            Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 50),
                    Text(
                      'Date',
                      style: TextStyle(
                        fontFamily: 'lexend',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Expanded(child: SmallContianer()),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SmallContianer extends StatelessWidget {
  const SmallContianer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Spacer(),
              Text(
                '24',
                style: TextStyle(
                  fontFamily: 'lexend',
                  fontSize: 32,
                ),
              ),
              Spacer(),
              Text(
                'Wednesday',
                style: TextStyle(
                  fontFamily: 'lexend',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Color(0XFF88889D),
              ),
              Text(
                'Room 2-168',
                style: TextStyle(fontFamily: 'lexend'),
              )
            ],
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: AssetImage('assets/images/dr-sheshtawey.jpg'),
              ),
              Text(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                'DR. Reda Elsheshtawy',
                style: TextStyle(fontFamily: 'lexend'),
              )
            ],
          )
        ],
      ),
    );
  }
}
