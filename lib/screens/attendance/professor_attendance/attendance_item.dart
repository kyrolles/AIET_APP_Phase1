import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';

class CurrentAttendanceItem extends StatelessWidget {
  const CurrentAttendanceItem({
    super.key,
    required this.subject,
    required this.period,
    required this.startTime,
    required this.endTime,
    required this.total,
    required this.ontapOnReview,
    required this.ontapOnSend,
    this.onDelete,  
  });

  final String subject;
  final String period;
  final String startTime;
  final String endTime;
  final int total;
  final Function() ontapOnReview;
  final Function() ontapOnSend;
  final Function()? onDelete;  

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 5),
              width: 60,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFEB8991),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(child: Text('P$period', style: kTextStyleBold)), // Add 'P' prefix
            ),
            Text(startTime, style: kTextStyleNormal),
            Text(
              endTime,
              style: const TextStyle(
                fontFamily: 'Lexend',
                fontSize: 16,
                color: kGrey,
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
              decoration: BoxDecoration(
                color: kGreyLight,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(subject, style: kTextStyleBold),
                      
                      InkWell(
                        onTap: onDelete,
                        child: const Icon(Icons.close, color: kGrey),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Total: ', style: kTextStyleNormal),
                      Text(
                        "$total",
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w600,
                          fontSize: 34,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: ontapOnReview,
                        child: const Text('Review'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: ontapOnSend,
                        child: const Text('Send'),
                      ),
                    ],
                  )
                ],
              )),
        ),
      ],
    );
  }
}
