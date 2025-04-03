import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/schedule_model.dart';
import 'class_session_card.dart';

class WeeklyScheduleView extends StatelessWidget {
  final WeekType weekType;
  final ClassIdentifier classIdentifier;
  final List<ClassSession> sessions;
  final String semesterName;
  
  const WeeklyScheduleView({
    Key? key,
    required this.weekType,
    required this.classIdentifier,
    required this.sessions,
    this.semesterName = '',
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6, // 6 days from Saturday to Thursday
      child: Column(
        children: [
          // Semester name header
          if (semesterName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                semesterName,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            
          // Tab bar for days
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              tabs: DayOfWeek.values.map((day) => _buildDayTab(day)).toList(),
              indicator: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: kPrimaryColor,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              padding: const EdgeInsets.all(4),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
            ),
          ),
          const SizedBox(height: 16),
          
          // Tab content
          Expanded(
            child: TabBarView(
              children: DayOfWeek.values.map((day) => _buildDaySchedule(day)).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDayTab(DayOfWeek day) {
    return Tab(
      child: Text(
        day.shortName,
        style: const TextStyle(
          fontFamily: 'Lexend',
          fontSize: 14,
        ),
      ),
    );
  }
  
  Widget _buildDaySchedule(DayOfWeek day) {
    // Filter sessions for this day
    final daySessions = sessions.where((s) => s.day == day).toList()
      ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
    
    if (daySessions.isEmpty) {
      return const Center(
        child: Text(
          'No classes scheduled for this day',
          style: TextStyle(color: kGrey),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: daySessions.length,
      itemBuilder: (context, index) {
        final session = daySessions[index];
        return ClassSessionCard(session: session);
      },
    );
  }
  
  // Helper method to get a beautiful visual schedule layout
  Widget _buildVisualSchedule(DayOfWeek day) {
    // Get all periods
    final periods = Period.getPeriods();
    
    // Filter sessions for this day
    final daySessions = sessions.where((s) => s.day == day).toList();
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: periods.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final period = periods[index];
        final sessionsForPeriod = daySessions.where((s) => s.periodNumber == period.number).toList();
        
        return Container(
          height: 80,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Time column
              Container(
                width: 80,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'P${period.number}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    Text(
                      period.displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Session column
              Expanded(
                child: sessionsForPeriod.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Center(
                          child: Text(
                            'No class',
                            style: TextStyle(color: kGrey),
                          ),
                        ),
                      )
                    : Column(
                        children: sessionsForPeriod
                            .map((session) => Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: _getSessionColor(session),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          session.courseName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          session.location,
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Color _getSessionColor(ClassSession session) {
    if (session.isLab) {
      return const Color(0xFFFFF9C4); // Light yellow for labs
    }
    
    if (session.isTutorial) {
      return const Color(0xFFE1F5FE); // Light blue for tutorials
    }
    
    return Colors.white;
  }
} 