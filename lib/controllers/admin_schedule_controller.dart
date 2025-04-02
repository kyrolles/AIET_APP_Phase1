import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

/// State class for the admin schedule management
class AdminScheduleState {
  final bool isLoading;
  final bool isSaving;
  final Semester? semester;
  final List<ClassIdentifier> classIdentifiers;
  final ClassIdentifier? selectedClassIdentifier;
  final WeekType selectedWeekType;
  final String? errorMessage;
  final String? successMessage;
  final Map<String, bool> _expandedDays;  // Performance: Track expanded days

  AdminScheduleState({
    this.isLoading = false,
    this.isSaving = false,
    this.semester,
    this.classIdentifiers = const [],
    this.selectedClassIdentifier,
    this.selectedWeekType = WeekType.ODD,
    this.errorMessage,
    this.successMessage,
    Map<String, bool>? expandedDays,
  }) : _expandedDays = expandedDays ?? {};
  
  // Get the expanded state of a day
  bool isDayExpanded(DayOfWeek day) => _expandedDays[day.name] ?? false;
  
  // Create a new state with a day's expanded state toggled
  AdminScheduleState toggleDayExpanded(DayOfWeek day) {
    final newExpandedDays = Map<String, bool>.from(_expandedDays);
    newExpandedDays[day.name] = !(newExpandedDays[day.name] ?? false);
    return copyWith(expandedDays: newExpandedDays);
  }
  
  AdminScheduleState copyWith({
    bool? isLoading,
    bool? isSaving,
    Semester? semester,
    List<ClassIdentifier>? classIdentifiers,
    ClassIdentifier? selectedClassIdentifier,
    WeekType? selectedWeekType,
    String? errorMessage,
    String? successMessage,
    Map<String, bool>? expandedDays,
  }) {
    return AdminScheduleState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      semester: semester ?? this.semester,
      classIdentifiers: classIdentifiers ?? this.classIdentifiers,
      selectedClassIdentifier: selectedClassIdentifier ?? this.selectedClassIdentifier,
      selectedWeekType: selectedWeekType ?? this.selectedWeekType,
      errorMessage: errorMessage,
      successMessage: successMessage,
      expandedDays: expandedDays ?? _expandedDays,
    );
  }
  
  // Performance: Memoized filtered sessions by day for efficient access
  Map<DayOfWeek, List<ClassSession>> get sessionsByDay {
    if (semester == null || selectedClassIdentifier == null) {
      return {};
    }
    
    final Map<DayOfWeek, List<ClassSession>> result = {};
    
    // Filter sessions for the current class and week type
    final filteredSessions = semester!.sessions.where((session) => 
      session.weekType == selectedWeekType &&
      session.classIdentifier.year == selectedClassIdentifier!.year &&
      session.classIdentifier.department == selectedClassIdentifier!.department &&
      session.classIdentifier.section == selectedClassIdentifier!.section
    );
    
    // Group by day
    for (final day in DayOfWeek.values) {
      final daySessions = filteredSessions
          .where((s) => s.day == day)
          .toList()
        ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
      
      result[day] = daySessions;
    }
    
    return result;
  }
}

/// Controller class for admin schedule management
class AdminScheduleController extends StateNotifier<AdminScheduleState> {
  final ScheduleService _scheduleService;
  
  AdminScheduleController(this._scheduleService) : super(AdminScheduleState()) {
    loadScheduleData();
  }
  
  /// Load all schedule data needed for management
  Future<void> loadScheduleData() async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    
    try {
      final semester = await _scheduleService.getCurrentSemester();
      final classIdentifiers = await _scheduleService.getAllClassIdentifiers();
      
      final selectedClassIdentifier = classIdentifiers.isNotEmpty 
          ? classIdentifiers.first 
          : null;
      
      state = state.copyWith(
        isLoading: false,
        semester: semester,
        classIdentifiers: classIdentifiers,
        selectedClassIdentifier: selectedClassIdentifier,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load schedule data: $e',
      );
    }
  }
  
  /// Select a different class identifier
  void selectClassIdentifier(ClassIdentifier classIdentifier) {
    state = state.copyWith(selectedClassIdentifier: classIdentifier);
  }
  
  /// Toggle between ODD and EVEN week types
  void toggleWeekType() {
    final newWeekType = state.selectedWeekType == WeekType.ODD
        ? WeekType.EVEN
        : WeekType.ODD;
    
    state = state.copyWith(selectedWeekType: newWeekType);
  }
  
  /// Toggle a day's expanded state in the UI
  void toggleDayExpanded(DayOfWeek day) {
    state = state.toggleDayExpanded(day);
  }
  
  /// Add or update a class session
  Future<bool> addOrUpdateSession(ClassSession session) async {
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);
    
    try {
      final result = await _scheduleService.addOrUpdateClassSession(session);
      
      if (result) {
        await loadScheduleData(); // Refresh data after successful update
        state = state.copyWith(
          isSaving: false,
          successMessage: 'Session updated successfully',
        );
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to update session. Permission denied.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Error updating session: $e',
      );
      return false;
    }
  }
  
  /// Add multiple sessions at once (bulk operation)
  Future<bool> addMultipleSessions(List<ClassSession> sessions) async {
    if (sessions.isEmpty) return true;
    
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);
    
    try {
      final result = await _scheduleService.addMultipleSessions(sessions);
      
      if (result) {
        await loadScheduleData();
        state = state.copyWith(
          isSaving: false,
          successMessage: 'Added ${sessions.length} sessions successfully',
        );
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to add sessions. Permission denied.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Error adding sessions: $e',
      );
      return false;
    }
  }
  
  /// Delete a session
  Future<bool> deleteSession(String sessionId) async {
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);
    
    try {
      final result = await _scheduleService.deleteClassSession(sessionId);
      
      if (result) {
        await loadScheduleData(); // Refresh data after successful deletion
        state = state.copyWith(
          isSaving: false,
          successMessage: 'Session deleted successfully',
        );
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to delete session. Permission denied.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Error deleting session: $e',
      );
      return false;
    }
  }
  
  /// Add a day off session
  Future<bool> addDayOff(DayOfWeek day) async {
    if (state.selectedClassIdentifier == null) {
      state = state.copyWith(errorMessage: 'No class selected');
      return false;
    }
    
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);
    
    try {
      final result = await _scheduleService.addDayOff(
        day, 
        state.selectedWeekType, 
        state.selectedClassIdentifier!
      );
      
      if (result) {
        await loadScheduleData();
        state = state.copyWith(
          isSaving: false,
          successMessage: 'Day off added successfully',
        );
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to add day off. Permission denied.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Error adding day off: $e',
      );
      return false;
    }
  }
}

// Provider
final adminScheduleControllerProvider = StateNotifierProvider<AdminScheduleController, AdminScheduleState>((ref) {
  final scheduleService = ref.watch(Provider<ScheduleService>((ref) => ScheduleService()));
  return AdminScheduleController(scheduleService);
}); 