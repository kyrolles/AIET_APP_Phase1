import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

// State class for the schedule
class ScheduleState {
  final bool isLoading;
  final Semester? semester;
  final List<Semester> availableSemesters; // All available semesters
  final ClassIdentifier? classIdentifier;
  final WeekType selectedWeekType;
  final String? errorMessage;
  final bool isRefreshCooldown;
  final int cooldownRemainingMin;
  
  ScheduleState({
    this.isLoading = false,
    this.semester,
    this.availableSemesters = const [],
    this.classIdentifier,
    this.selectedWeekType = WeekType.ODD,
    this.errorMessage,
    this.isRefreshCooldown = false,
    this.cooldownRemainingMin = 0,
  });
  
  ScheduleState copyWith({
    bool? isLoading,
    Semester? semester,
    List<Semester>? availableSemesters,
    ClassIdentifier? classIdentifier,
    WeekType? selectedWeekType,
    String? errorMessage,
    bool? isRefreshCooldown,
    int? cooldownRemainingMin,
  }) {
    return ScheduleState(
      isLoading: isLoading ?? this.isLoading,
      semester: semester ?? this.semester,
      availableSemesters: availableSemesters ?? this.availableSemesters,
      classIdentifier: classIdentifier ?? this.classIdentifier,
      selectedWeekType: selectedWeekType ?? this.selectedWeekType,
      errorMessage: errorMessage,
      isRefreshCooldown: isRefreshCooldown ?? this.isRefreshCooldown,
      cooldownRemainingMin: cooldownRemainingMin ?? this.cooldownRemainingMin,
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
      // Get the student's class identifier first
      final classIdentifier = await _scheduleService.getStudentClassIdentifier();
      
      if (classIdentifier == null) {
        print('No class identifier available for current user, using default');
        // Use a default class identifier if none found
        state = state.copyWith(
          classIdentifier: ClassIdentifier(
            year: 4,
            department: Department.C,
            section: 2,
          ),
        );
      } else {
        print('Found class identifier: ${classIdentifier.year}${classIdentifier.department.name}${classIdentifier.section}');
        // Set the class identifier from user data
        state = state.copyWith(classIdentifier: classIdentifier);
      }
      
      // Get all available semesters (with empty sessions lists for performance)
      final availableSemesters = await _scheduleService.getAllSemesters();
      
      // Check if we have any semesters available - if not, don't try to load a specific one yet
      if (availableSemesters.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          availableSemesters: [],
          errorMessage: 'No semesters available. Please create a semester first.'
        );
        return;
      }
      
      // Now fetch the current semester data with sessions
      final semester = await _scheduleService.getCurrentSemester();
      
      // Get filtered session count for logging
      final filteredSessionCount = semester.sessions.where((session) =>
        session.classIdentifier.year == state.classIdentifier!.year &&
        session.classIdentifier.department == state.classIdentifier!.department &&
        session.classIdentifier.section == state.classIdentifier!.section
      ).length;
      
      print('Loaded ${semester.sessions.length} total sessions, ${filteredSessionCount} for current class');
      
      state = state.copyWith(
        isLoading: false,
        semester: semester,
        availableSemesters: availableSemesters,
      );
      
      // Update refresh status
      await _updateRefreshStatus();
    } catch (e) {
      print('Failed to load schedule: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load schedule: $e',
      );
    }
  }
  
  // Change the current semester
  Future<void> changeSemester(String semesterId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // Save the selected semester ID in preferences
      await _scheduleService.setSelectedSemesterId(semesterId);
      
      // Load the selected semester
      final semester = await _scheduleService.getSemesterById(semesterId);
      
      state = state.copyWith(
        isLoading: false,
        semester: semester,
      );
    } catch (e) {
      print('Failed to change semester: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to change semester: $e',
      );
    }
  }
  
  // For admins: set a semester as active
  Future<bool> setActiveSemester(String semesterId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final result = await _scheduleService.setSemesterActive(semesterId);
      
      if (result) {
        // Refresh the list of available semesters
        final availableSemesters = await _scheduleService.getAllSemesters(forceRefresh: true);
        
        // Load the now-active semester
        final semester = await _scheduleService.getSemesterById(semesterId, forceRefresh: true);
        
        state = state.copyWith(
          isLoading: false,
          semester: semester,
          availableSemesters: availableSemesters,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to set active semester. Permission denied.',
        );
      }
      
      return result;
    } catch (e) {
      print('Failed to set active semester: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to set active semester: $e',
      );
      return false;
    }
  }
  
  // Refresh all semester data
  Future<void> refreshAllSemesterData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // Get all available semesters
      final availableSemesters = await _scheduleService.getAllSemesters(forceRefresh: true);
      
      // Refresh the current semester
      final currentSemesterId = state.semester?.id ?? '';
      Semester semester;
      
      if (currentSemesterId.isNotEmpty) {
        semester = await _scheduleService.getSemesterById(currentSemesterId, forceRefresh: true);
      } else {
        semester = await _scheduleService.getCurrentSemester(forceRefresh: true);
      }
      
      state = state.copyWith(
        isLoading: false,
        semester: semester,
        availableSemesters: availableSemesters,
      );
      
      // Update refresh status
      await _updateRefreshStatus();
    } catch (e) {
      print('Failed to refresh all semester data: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh semester data: $e',
      );
    }
  }
  
  /// Refresh the schedule data from Firestore
  Future<void> refreshSchedule() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // First check if we need to refresh the class identifier
      final classIdentifier = await _scheduleService.getStudentClassIdentifier();
      if (classIdentifier != null) {
        // Update the class identifier if it's different
        if (state.classIdentifier == null ||
            classIdentifier.year != state.classIdentifier!.year ||
            classIdentifier.department != state.classIdentifier!.department ||
            classIdentifier.section != state.classIdentifier!.section) {
          print('Class identifier changed, updating to: ${classIdentifier.year}${classIdentifier.department.name}${classIdentifier.section}');
          state = state.copyWith(classIdentifier: classIdentifier);
        }
      }
      
      // Force a fresh fetch from Firestore, not from cache
      final semester = await _scheduleService.getCurrentSemester(forceRefresh: true);
      
      // Get filtered session count for logging
      final filteredSessionCount = semester.sessions.where((session) =>
        session.classIdentifier.year == state.classIdentifier!.year &&
        session.classIdentifier.department == state.classIdentifier!.department &&
        session.classIdentifier.section == state.classIdentifier!.section
      ).length;
      
      print('Refreshed ${semester.sessions.length} total sessions, ${filteredSessionCount} for current class');
      
      state = state.copyWith(
        isLoading: false,
        semester: semester,
      );
      
      // Update refresh status after refresh
      await _updateRefreshStatus();
    } catch (e) {
      print('Failed to refresh schedule: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh schedule: $e',
      );
    }
  }
  
  /// Get and update the refresh status in the state
  Future<void> _updateRefreshStatus() async {
    try {
      final refreshStatus = await _scheduleService.getRefreshStatus();
      
      state = state.copyWith(
        isRefreshCooldown: refreshStatus['inCooldown'],
        cooldownRemainingMin: refreshStatus['cooldownRemainingMin'],
      );
    } catch (e) {
      print('Error updating refresh status: $e');
    }
  }
  
  /// Check if refresh is available or in cooldown
  /// Returns a message with cooldown information if applicable
  String? getRefreshMessage() {
    if (state.isRefreshCooldown) {
      return 'Refresh limit reached. Try again in ${state.cooldownRemainingMin} minutes.';
    }
    return null;
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