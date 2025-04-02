import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

// State class for the schedule
class ScheduleState {
  final bool isLoading;
  final Semester? semester;
  final ClassIdentifier? classIdentifier;
  final WeekType selectedWeekType;
  final String? errorMessage;
  
  ScheduleState({
    this.isLoading = false,
    this.semester,
    this.classIdentifier,
    this.selectedWeekType = WeekType.ODD,
    this.errorMessage,
  });
  
  ScheduleState copyWith({
    bool? isLoading,
    Semester? semester,
    ClassIdentifier? classIdentifier,
    WeekType? selectedWeekType,
    String? errorMessage,
  }) {
    return ScheduleState(
      isLoading: isLoading ?? this.isLoading,
      semester: semester ?? this.semester,
      classIdentifier: classIdentifier ?? this.classIdentifier,
      selectedWeekType: selectedWeekType ?? this.selectedWeekType,
      errorMessage: errorMessage,
    );
  }
  
  // Get sessions for the current class and selected week type
  List<ClassSession> getFilteredSessions() {
    if (semester == null || classIdentifier == null) {
      return [];
    }
    
    return semester!.sessions.where((session) => 
      session.weekType == selectedWeekType &&
      session.classIdentifier.year == classIdentifier!.year &&
      session.classIdentifier.department == classIdentifier!.department &&
      session.classIdentifier.section == classIdentifier!.section
    ).toList();
  }
  
  // Get today's sessions
  List<ClassSession> getTodaySessions() {
    final today = DateTime.now().weekday;
    // Convert DateTime weekday (1-7, starting with Monday) to our DayOfWeek enum
    final dayOfWeek = DayOfWeek.values[today == 7 ? 0 : today]; // Adjust for Sunday
    
    return getFilteredSessions().where((session) => 
      session.day == dayOfWeek
    ).toList()
      ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
  }
  
  // Get upcoming sessions (next 24 hours)
  List<ClassSession> getUpcomingSessions() {
    final now = DateTime.now();
    final today = now.weekday;
    final currentHour = now.hour;
    
    // Convert DateTime weekday (1-7, starting with Monday) to our DayOfWeek enum
    final todayIndex = today == 7 ? 0 : today; // Adjust for Sunday
    final tomorrowIndex = (todayIndex + 1) % 6; // Wrap around to Saturday
    
    final todayOfWeek = DayOfWeek.values[todayIndex];
    final tomorrowOfWeek = DayOfWeek.values[tomorrowIndex];
    
    // Get all sessions for today that haven't happened yet
    final todaySessions = getFilteredSessions().where((session) {
      if (session.day != todayOfWeek) return false;
      
      final sessionStartHour = session.periodNumber == 1 ? 9 :
                             session.periodNumber == 2 ? 10 :
                             session.periodNumber == 3 ? 12 :
                             session.periodNumber == 4 ? 14 : 16;
      
      return sessionStartHour > currentHour;
    }).toList();
    
    // Get all sessions for tomorrow (limited to next 24 hours)
    final tomorrowSessions = getFilteredSessions().where((session) {
      if (session.day != tomorrowOfWeek) return false;
      
      final sessionStartHour = session.periodNumber == 1 ? 9 :
                             session.periodNumber == 2 ? 10 :
                             session.periodNumber == 3 ? 12 :
                             session.periodNumber == 4 ? 14 : 16;
      
      return sessionStartHour < currentHour;
    }).toList();
    
    // Combine and sort by day and period
    final upcomingSessions = [...todaySessions, ...tomorrowSessions];
    upcomingSessions.sort((a, b) {
      final dayComparison = a.day.index.compareTo(b.day.index);
      if (dayComparison != 0) return dayComparison;
      return a.periodNumber.compareTo(b.periodNumber);
    });
    
    return upcomingSessions;
  }
}

// Controller class
class ScheduleController extends StateNotifier<ScheduleState> {
  final ScheduleService _scheduleService;
  
  ScheduleController(this._scheduleService) : super(ScheduleState()) {
    loadSchedule();
  }
  
  Future<void> loadSchedule() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final semester = await _scheduleService.getCurrentSemester();
      final classIdentifier = await _scheduleService.getStudentClassIdentifier();
      
      state = state.copyWith(
        isLoading: false,
        semester: semester,
        classIdentifier: classIdentifier ?? ClassIdentifier(
          year: 4,
          department: Department.C,
          section: 2,
        ), // Default to 4C2 if user info not available
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load schedule: $e',
      );
    }
  }
  
  /// Refresh the schedule data from Firestore
  Future<void> refreshSchedule() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // Force a fresh fetch from Firestore, not from cache
      final semester = await _scheduleService.getCurrentSemester(forceRefresh: true);
      
      state = state.copyWith(
        isLoading: false,
        semester: semester,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh schedule: $e',
      );
    }
  }
  
  void toggleWeekType() {
    final newWeekType = state.selectedWeekType == WeekType.ODD
        ? WeekType.EVEN
        : WeekType.ODD;
    
    state = state.copyWith(selectedWeekType: newWeekType);
  }
  
  void setClassIdentifier(ClassIdentifier classIdentifier) {
    state = state.copyWith(classIdentifier: classIdentifier);
  }
}

// Providers
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService();
});

final scheduleControllerProvider = StateNotifierProvider<ScheduleController, ScheduleState>((ref) {
  final scheduleService = ref.watch(scheduleServiceProvider);
  return ScheduleController(scheduleService);
}); 