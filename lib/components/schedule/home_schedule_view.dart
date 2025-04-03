import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../../controllers/schedule_controller.dart';
import '../../models/schedule_model.dart';
import 'class_session_card.dart';
import 'weekly_schedule_view.dart';

class HomeScheduleView extends ConsumerWidget {
  const HomeScheduleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(scheduleControllerProvider);
    final weekType = scheduleState.selectedWeekType; 
    final todaySessions = scheduleState.getTodaySessions();
    final upcomingSessions = scheduleState.getUpcomingSessions();
    
    // If still loading, show loading indicator
    if (scheduleState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    // If there's an error, show error message
    if (scheduleState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              scheduleState.errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(scheduleControllerProvider.notifier).refreshSchedule();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    // If no class identifier yet, show message
    if (scheduleState.classIdentifier == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No schedule information available.\nMake sure your profile has your academic year, department, and section set.',
              style: TextStyle(color: kGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(scheduleControllerProvider.notifier).refreshSchedule();
              },
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }
    
    // Check if we have any sessions for the student's class and selected week
    final allSessionsForClass = scheduleState.getFilteredSessions();
    if (allSessionsForClass.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kGrey.withOpacity(0.3)),
        ),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildScheduleHeader(weekType, scheduleState, context, ref),
            const SizedBox(height: 16),
            Text(
              'No sessions found for ${scheduleState.classIdentifier!.year}${scheduleState.classIdentifier!.department.name}${scheduleState.classIdentifier!.section} in the ${weekType == WeekType.ODD ? "Odd" : "Even"} week.',
              style: const TextStyle(color: kGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showFullWeekSchedule(context, scheduleState);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('View Full Week'),
            ),
          ],
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Header with current day and week type
          _buildScheduleHeader(weekType, scheduleState, context, ref),
          
          // Show today's schedule
          if (todaySessions.isNotEmpty)
            _buildTodaySchedule(todaySessions)
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No classes scheduled for today (${_getCurrentDayName()}).',
                style: const TextStyle(color: kGrey),
              ),
            ),
            
          // View full schedule button
          _buildViewFullScheduleButton(context, scheduleState),
        ],
      ),
    );
  }
  
  Widget _buildScheduleHeader(
    WeekType weekType, 
    ScheduleState scheduleState, 
    BuildContext context,
    WidgetRef ref,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Schedule - ${_getCurrentDayName()}',
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    weekType == WeekType.ODD ? 'Odd Week' : 'Even Week',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${scheduleState.classIdentifier!.year}${scheduleState.classIdentifier!.department.name}${scheduleState.classIdentifier!.section}',
                    style: const TextStyle(
                      color: kGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Refresh button to sync with Firestore
          IconButton(
            icon: const Icon(Icons.refresh),
            color: kPrimaryColor,
            onPressed: () {
              final controller = ref.read(scheduleControllerProvider.notifier);
              final refreshMessage = controller.getRefreshMessage();
              
              if (refreshMessage != null) {
                // Show cooldown message if in cooldown
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(refreshMessage),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                // Refresh if not in cooldown
                controller.refreshSchedule();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Refreshing schedule from server...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            tooltip: 'Refresh Schedule',
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            color: kPrimaryColor,
            onPressed: () {
              ref.read(scheduleControllerProvider.notifier).toggleWeekType();
            },
            tooltip: 'Toggle Week Type',
          ),
        ],
      ),
    );
  }
  
  Widget _buildTodaySchedule(List<ClassSession> todaySessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Today\'s Classes',
            style: TextStyle(
              fontFamily: 'Lexend',
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
        // List of today's sessions
        ...todaySessions.map((session) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClassSessionCard(session: session),
        )).toList(),
      ],
    );
  }
  
  Widget _buildViewFullScheduleButton(BuildContext context, ScheduleState scheduleState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // View full week schedule button
          GestureDetector(
            onTap: () {
              _showFullWeekSchedule(context, scheduleState);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Full Week',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.calendar_month,
                    size: 18,
                    color: kPrimaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getCurrentDayName() {
    final now = DateTime.now();
    return DateFormat('EEEE').format(now);
  }
  
  // Helper method to show the full week schedule
  void _showFullWeekSchedule(BuildContext context, ScheduleState scheduleState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Bottom sheet handle
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Weekly Schedule',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                // Week type and refresh controls
                Consumer(
                  builder: (context, ref, _) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          scheduleState.selectedWeekType == WeekType.ODD ? 'Odd Week' : 'Even Week',
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            // Add toggle week type button
                            IconButton(
                              icon: const Icon(Icons.swap_horiz),
                              color: kPrimaryColor,
                              onPressed: () {
                                ref.read(scheduleControllerProvider.notifier).toggleWeekType();
                              },
                              tooltip: 'Toggle Week Type',
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              color: kPrimaryColor,
                              onPressed: () {
                                final controller = ref.read(scheduleControllerProvider.notifier);
                                final refreshMessage = controller.getRefreshMessage();
                                
                                if (refreshMessage != null) {
                                  // Show cooldown message if in cooldown
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(refreshMessage),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  // Refresh if not in cooldown
                                  controller.refreshSchedule();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Refreshing schedule from server...'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              tooltip: 'Refresh Schedule',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Full schedule display
                Expanded(
                  child: scheduleState.classIdentifier != null
                      ? WeeklyScheduleView(
                          weekType: scheduleState.selectedWeekType,
                          classIdentifier: scheduleState.classIdentifier!,
                          sessions: scheduleState.getFilteredSessions(),
                        )
                      : const Center(
                          child: Text('No schedule available'),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 