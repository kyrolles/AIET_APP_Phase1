import 'package:flutter/material.dart';
import 'time_coursedetails_component.dart';
import '../utils/schedule_data_utils.dart';
import '../utils/time_utils.dart';
import 'empty_schedule_widget.dart';
import 'error_state_widget.dart';

/// Widget that handles the main schedule content display
class ScheduleContentWidget extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> daySchedule;
  final int currentPeriod;
  final DateTime selectedDate;

  const ScheduleContentWidget({
    super.key,
    required this.isLoading,
    this.error,
    required this.daySchedule,
    required this.currentPeriod,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return ErrorStateWidget(error: error!);
    }

    // Create a schedule showing only periods with scheduled classes
    List<Widget> schedulePeriods = [];

    for (int period = 1; period <= 4; period++) {
      // Only add periods that have scheduled classes
      if (ScheduleDataUtils.hasPeriodScheduled(daySchedule, period)) {
        schedulePeriods.add(_buildPeriodSlot(period));
        if (period < 4) {
          // Don't add spacing after the last item
          schedulePeriods.add(const SizedBox(height: 16));
        }
      }
    }

    if (schedulePeriods.isEmpty) {
      return const EmptyScheduleWidget();
    }

    return Column(children: schedulePeriods);
  }

  Widget _buildPeriodSlot(int period) {
    final scheduleEntry =
        ScheduleDataUtils.getScheduleForPeriod(daySchedule, period);
    final hasClass = scheduleEntry.isNotEmpty;
    final isCurrentPeriod =
        currentPeriod == period && TimeUtils.isToday(selectedDate);

    // Only show periods that have scheduled classes
    if (hasClass) {
      final instructor = ScheduleDataUtils.extractInstructor(scheduleEntry);
      final groups = ScheduleDataUtils.extractGroups(scheduleEntry);
      final subjectName = ScheduleDataUtils.extractSubjectName(scheduleEntry);

      return ClassSchedule(
        period: "P$period",
        courseName: subjectName,
        instructor: instructor,
        groups: groups,
        isCurrentPeriod: isCurrentPeriod,
      );
    } else {
      // Return empty container for free periods (don't display them)
      return const SizedBox.shrink();
    }
  }
}
