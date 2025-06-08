import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import '../../../constants.dart';

class MapDateTimeline extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChange;

  const MapDateTimeline({
    Key? key,
    required this.selectedDate,
    required this.onDateChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EasyDateTimeLine(
      initialDate: selectedDate,
      onDateChange: onDateChange,
      activeColor: Colors.blue,
      dayProps: EasyDayProps(
        height: 70,
        borderColor: Colors.grey.shade600,
        inactiveDayStyle: DayStyle(
          dayNumStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
          monthStrStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black54,
          ),
          dayStrStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black54,
          ),
          decoration: BoxDecoration(
            color: kLightGrey,
            // color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            // border: Border.all(
            //   color: Colors.grey.shade600,
            //   width: 2.0,
            // ),
          ),
        ),
      ),
    );
  }
}
