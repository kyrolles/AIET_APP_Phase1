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
  final List<Semester> availableSemesters; // All available semesters
  final String? selectedSemesterId; // Currently selected semester ID

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
    this.availableSemesters = const [],
    this.selectedSemesterId,
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
    List<Semester>? availableSemesters,
    String? selectedSemesterId,
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
      availableSemesters: availableSemesters ?? this.availableSemesters,
      selectedSemesterId: selectedSemesterId ?? this.selectedSemesterId,
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
  
  // Find currently selected semester object
  Semester? get selectedSemester {
    if (selectedSemesterId == null || availableSemesters.isEmpty) return semester;
    
    try {
      return availableSemesters.firstWhere((s) => s.id == selectedSemesterId);
    } catch (_) {
      return semester;
    }
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
      // Get all available semesters
      final availableSemesters = await _scheduleService.getAllSemesters();
      
      // Determine which semester to load
      String semesterId = state.selectedSemesterId ?? '';
      
      // If no semester is selected or the selected one doesn't exist in the list
      if (semesterId.isEmpty || !availableSemesters.any((s) => s.id == semesterId)) {
        // Find the active semester if any
        final activeSemester = availableSemesters.firstWhere(
          (s) => s.isActive, 
          orElse: () => availableSemesters.isNotEmpty ? availableSemesters.first : Semester(name: '', sessions: [])
        );
        semesterId = activeSemester.id ?? '';
      }
      
      // Load the full semester with sessions
      Semester semester;
      if (semesterId.isNotEmpty) {
        semester = await _scheduleService.getSemesterById(semesterId);
      } else {
        semester = await _scheduleService.getCurrentSemester();
      }
      
      // Get class identifiers for the dropdown
      final classIdentifiers = await _scheduleService.getAllClassIdentifiers();
      
      final selectedClassIdentifier = classIdentifiers.isNotEmpty 
          ? classIdentifiers.first 
          : null;
      
      state = state.copyWith(
        isLoading: false,
        semester: semester,
        classIdentifiers: classIdentifiers,
        selectedClassIdentifier: selectedClassIdentifier,
        availableSemesters: availableSemesters,
        selectedSemesterId: semesterId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load schedule data: $e',
      );
    }
  }
  
  /// Select a different semester
  Future<void> selectSemester(String semesterId) async {
    if (semesterId == state.selectedSemesterId) return;
    
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    
    try {
      // Load the selected semester with all its sessions
      final semester = await _scheduleService.getSemesterById(semesterId);
      
      state = state.copyWith(
        isLoading: false,
        semester: semester,
        selectedSemesterId: semesterId,
        successMessage: 'Switched to semester: ${semester.name}',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load semester: $e',
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
    if (state.selectedSemesterId == null || state.selectedSemesterId!.isEmpty) {
      state = state.copyWith(
        errorMessage: 'No semester selected. Please select a semester first.'
      );
      return false;
    }
    
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);
    
    try {
      final result = await _scheduleService.addOrUpdateClassSession(
        session, 
        targetSemesterId: state.selectedSemesterId
      );
      
      if (result) {
        // Reload only the current semester data, not everything
        final updatedSemester = await _scheduleService.getSemesterById(state.selectedSemesterId!);
        
        state = state.copyWith(
          isSaving: false,
          semester: updatedSemester,
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
    
    if (state.selectedSemesterId == null || state.selectedSemesterId!.isEmpty) {
      state = state.copyWith(
        errorMessage: 'No semester selected. Please select a semester first.'
      );
      return false;
    }
    
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);
    
    try {
      final result = await _scheduleService.addMultipleSessions(
        sessions,
        targetSemesterId: state.selectedSemesterId
      );
      
      if (result) {
        // Reload only the current semester data, not everything
        final updatedSemester = await _scheduleService.getSemesterById(state.selectedSemesterId!);
        
        state = state.copyWith(
          isSaving: false,
          semester: updatedSemester,
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
    if (state.selectedSemesterId == null || state.selectedSemesterId!.isEmpty) {
      state = state.copyWith(
        errorMessage: 'No semester selected. Please select a semester first.'
      );
      return false;
    }
    
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);
    
    try {
      final result = await _scheduleService.deleteClassSession(
        sessionId,
        targetSemesterId: state.selectedSemesterId
      );
      
      if (result) {
        // Reload only the current semester data, not everything
        final updatedSemester = await _scheduleService.getSemesterById(state.selectedSemesterId!);
        
        state = state.copyWith(
          isSaving: false,
          semester: updatedSemester,
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
    
    if (state.selectedSemesterId == null || state.selectedSemesterId!.isEmpty) {
      state = state.copyWith(
        errorMessage: 'No semester selected. Please select a semester first.'
      );
      return false;
    }
    
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);
    
    try {
      final result = await _scheduleService.addDayOff(
        day, 
        state.selectedWeekType, 
        state.selectedClassIdentifier!,
        targetSemesterId: state.selectedSemesterId
      );
      
      if (result) {
        // Reload only the current semester data, not everything
        final updatedSemester = await _scheduleService.getSemesterById(state.selectedSemesterId!);
        
        state = state.copyWith(
          isSaving: false,
          semester: updatedSemester,
          successMessage: 'Added Day Off for ${day.name}',
        );
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to add Day Off. Permission denied.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Error adding Day Off: $e',
      );
      return false;
    }
  }
  
  /// Set a semester as the active one
  Future<bool> setActiveSemester(String semesterId) async {
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);
    
    try {
      final result = await _scheduleService.setSemesterActive(semesterId);
      
      if (result) {
        // Refresh all semesters to reflect the updated active status
        final updatedSemesters = await _scheduleService.getAllSemesters(forceRefresh: true);
        
        state = state.copyWith(
          isSaving: false,
          availableSemesters: updatedSemesters,
          successMessage: 'Semester set as active',
        );
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to set active semester. Permission denied.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Error setting active semester: $e',
      );
      return false;
    }
  }
}

// Provider
final adminScheduleControllerProvider = StateNotifierProvider<AdminScheduleController, AdminScheduleState>((ref) {
  // Create a singleton instance of ScheduleService to ensure consistent data across providers
  final scheduleService = ScheduleService();
  return AdminScheduleController(scheduleService);
}); 