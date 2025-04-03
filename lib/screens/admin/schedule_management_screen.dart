import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/admin_schedule_controller.dart';
import '../../models/schedule_model.dart';
import '../../widgets/loading_indicator.dart';

class ScheduleManagementScreen extends ConsumerWidget {
  const ScheduleManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminScheduleControllerProvider);
    final controller = ref.read(adminScheduleControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadScheduleData(),
          ),
        ],
      ),
      body: _buildBody(context, state, controller),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddSessionDialog(context, state, controller),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AdminScheduleState state,
    AdminScheduleController controller,
  ) {
    if (state.isLoading) {
      return const LoadingIndicator(message: 'Loading schedule data...');
    }
    
    return Column(
      children: [
        _buildStatusMessages(state),
        _buildSelectors(context, state, controller),
        Expanded(
          child: _buildScheduleList(context, state, controller),
        ),
      ],
    );
  }
  
  Widget _buildStatusMessages(AdminScheduleState state) {
    return Column(
      children: [
        if (state.errorMessage != null)
          Container(
            width: double.infinity,
            color: Colors.red.shade100,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              state.errorMessage!,
              style: TextStyle(color: Colors.red.shade900),
            ),
          ),
        if (state.successMessage != null)
          Container(
            width: double.infinity,
            color: Colors.green.shade100,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              state.successMessage!,
              style: TextStyle(color: Colors.green.shade900),
            ),
          ),
        if (state.isSaving)
          const LinearProgressIndicator(),
      ],
    );
  }

  Widget _buildSelectors(
    BuildContext context,
    AdminScheduleState state,
    AdminScheduleController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Semester selector
          const Text('Select Semester', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildSemesterSelector(state, controller),
          const SizedBox(height: 16),
          
          // Class selector
          const Text('Select Class', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<ClassIdentifier>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            value: state.selectedClassIdentifier,
            items: state.classIdentifiers.map((classId) {
              return DropdownMenuItem(
                value: classId,
                child: Text('${classId.year}${classId.department.name}${classId.section}'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.selectClassIdentifier(value);
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Week type selector
          Row(
            children: [
              const Text('Week Type:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('ODD'),
                selected: state.selectedWeekType == WeekType.ODD,
                onSelected: (_) {
                  if (state.selectedWeekType != WeekType.ODD) {
                    controller.toggleWeekType();
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('EVEN'),
                selected: state.selectedWeekType == WeekType.EVEN,
                onSelected: (_) {
                  if (state.selectedWeekType != WeekType.EVEN) {
                    controller.toggleWeekType();
                  }
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Bulk Add'),
                onPressed: () => _showBulkAddDialog(context, state, controller),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Build the semester selector dropdown with management buttons
  Widget _buildSemesterSelector(
    AdminScheduleState state,
    AdminScheduleController controller,
  ) {
    // If no semesters are available, show a placeholder and create button
    if (state.availableSemesters.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              children: [
                Text('No semesters available'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (ctx) => ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create New Semester'),
              onPressed: () => _showCreateSemesterDialog(ctx, controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }
    
    // Sort semesters: active first, then by descending semester number
    final sortedSemesters = List<Semester>.from(state.availableSemesters)
      ..sort((a, b) {
        // Active semester first
        if (a.isActive && !b.isActive) return -1;
        if (!a.isActive && b.isActive) return 1;
        
        // Then by academic year (descending)
        final yearA = a.academicYear ?? "";
        final yearB = b.academicYear ?? "";
        final yearCompare = yearB.compareTo(yearA);
        if (yearCompare != 0) return yearCompare;
        
        // Then by semester number (descending)
        final semA = a.semesterNumber ?? 0;
        final semB = b.semesterNumber ?? 0;
        return semB.compareTo(semA);
      });
    
    // Make sure there's a valid selection
    final selectedId = state.selectedSemesterId ?? '';
    final isValidSelection = sortedSemesters.any((sem) => sem.id == selectedId);
    
    if (!isValidSelection && sortedSemesters.isNotEmpty) {
      // Schedule the selection for after the build
      Future.microtask(() {
        controller.selectSemester(sortedSemesters.first.id ?? '');
      });
    }
    
    // Get the currently selected semester object
    final selectedSemester = state.selectedSemester;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown and Set Active button
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<String>(
                      value: isValidSelection ? selectedId : (sortedSemesters.isNotEmpty ? sortedSemesters.first.id : null),
                      isExpanded: true,
                      isDense: true,
                      items: sortedSemesters.map((semester) {
                        return DropdownMenuItem<String>(
                          value: semester.id,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  semester.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (semester.isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Active',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? semesterId) {
                        if (semesterId != null) {
                          controller.selectSemester(semesterId);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Set active button
            ElevatedButton(
              onPressed: state.selectedSemesterId == null || 
                        state.selectedSemester?.isActive == true ? 
                        null : () {
                          controller.setActiveSemester(state.selectedSemesterId!);
                        },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              child: const Text('Set Active'),
            ),
          ],
        ),
        
        // Show semester details if one is selected
        if (selectedSemester != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedSemester.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (selectedSemester.academicYear != null)
                            Text(
                              'Academic Year: ${selectedSemester.academicYear}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          if (selectedSemester.semesterNumber != null)
                            Text(
                              'Semester Number: ${selectedSemester.semesterNumber}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Session count badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${selectedSemester.sessions.length} Sessions',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Semester actions row
                Builder(
                  builder: (ctx) => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        onPressed: () => _showEditSemesterDialog(
                          ctx, 
                          controller,
                          selectedSemester,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.content_copy, size: 16),
                        label: const Text('Clone'),
                        onPressed: () => _showCloneSemesterDialog(
                          ctx, 
                          controller,
                          selectedSemester,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Delete'),
                        onPressed: selectedSemester.isActive ? null : () => _showDeleteSemesterDialog(
                          ctx, 
                          controller,
                          selectedSemester,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          disabledForegroundColor: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Create new semester button
        const SizedBox(height: 8),
        Builder(
          builder: (ctx) => ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create New Semester'),
            onPressed: () => _showCreateSemesterDialog(ctx, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
  
  // Show dialog to create a new semester
  void _showCreateSemesterDialog(
    BuildContext context,
    AdminScheduleController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => SemesterDialog(
        title: 'Create New Semester',
        isCreating: true,
        onSave: (name, semesterNumber, academicYear, isActive) async {
          final success = await controller.createNewSemester(
            name: name,
            semesterNumber: semesterNumber,
            academicYear: academicYear,
            isActive: isActive,
          );
          
          if (success && context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
  
  // Show dialog to edit a semester
  void _showEditSemesterDialog(
    BuildContext context,
    AdminScheduleController controller,
    Semester semester,
  ) {
    showDialog(
      context: context,
      builder: (context) => SemesterDialog(
        title: 'Edit Semester',
        isEditing: true,
        initialName: semester.name,
        initialSemesterNumber: semester.semesterNumber,
        initialAcademicYear: semester.academicYear,
        isActive: semester.isActive,
        onSave: (name, semesterNumber, academicYear, _) async {
          final success = await controller.updateSemesterDetails(
            semester.id!,
            name: name, 
            semesterNumber: semesterNumber,
            academicYear: academicYear,
          );
          
          if (success && context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
  
  // Show dialog to clone a semester
  void _showCloneSemesterDialog(
    BuildContext context,
    AdminScheduleController controller,
    Semester sourceSemester,
  ) {
    final now = DateTime.now();
    final defaultAcademicYear = '${now.year}-${now.year + 1}';
    
    showDialog(
      context: context,
      builder: (context) => SemesterDialog(
        title: 'Clone Semester',
        isCloning: true,
        initialName: 'Copy of ${sourceSemester.name}',
        initialSemesterNumber: sourceSemester.semesterNumber,
        initialAcademicYear: defaultAcademicYear,
        onSave: (name, semesterNumber, academicYear, makeActive) async {
          final success = await controller.cloneSemester(
            sourceSemester.id!,
            newName: name,
            newSemesterNumber: semesterNumber,
            newAcademicYear: academicYear,
            makeActive: makeActive,
          );
          
          if (success && context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
  
  // Show dialog to confirm semester deletion
  void _showDeleteSemesterDialog(
    BuildContext context,
    AdminScheduleController controller,
    Semester semester,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Semester?'),
        content: Text(
          'Are you sure you want to delete "${semester.name}"?\n\n'
          'This will permanently delete all ${semester.sessions.length} sessions associated with this semester.\n\n'
          'This action cannot be undone.'
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () async {
              final success = await controller.deleteSemester(semester.id!);
              if (success && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(
    BuildContext context,
    AdminScheduleState state,
    AdminScheduleController controller,
  ) {
    // Get sessions grouped by day
    final sessionsByDay = state.sessionsByDay;
    
    if (sessionsByDay.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No schedule data found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddSessionDialog(context, state, controller),
              child: const Text('Add First Session'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: DayOfWeek.values.length,
      itemBuilder: (context, index) {
        final day = DayOfWeek.values[index];
        final daySessions = sessionsByDay[day] ?? [];
        
        return _buildDayCard(context, day, daySessions, state, controller);
      },
    );
  }
  
  Widget _buildDayCard(
    BuildContext context,
    DayOfWeek day,
    List<ClassSession> sessions,
    AdminScheduleState state,
    AdminScheduleController controller,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        initiallyExpanded: state.isDayExpanded(day),
        onExpansionChanged: (expanded) {
          controller.toggleDayExpanded(day);
        },
        title: Row(
          children: [
            Text(day.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Chip(
              label: Text('${sessions.length} sessions'),
              backgroundColor: sessions.isEmpty ? Colors.grey.shade200 : Colors.blue.shade100,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: () => _showAddSessionDialog(
                context,
                state,
                controller,
                initialDay: day,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.event_busy, color: Colors.orange),
              onPressed: () => _confirmAddDayOff(
                context,
                day,
                controller,
              ),
            ),
          ],
        ),
        children: [
          if (sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No sessions for this day'),
            )
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: sessions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final session = sessions[index];
                return _buildSessionTile(context, session, controller);
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildSessionTile(
    BuildContext context,
    ClassSession session,
    AdminScheduleController controller,
  ) {
    // Format for special session types
    final bool isDayOff = session.courseName.toUpperCase() == 'DAY OFF';
    
    return ListTile(
      title: Text(
        session.courseName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDayOff ? Colors.orange : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (session.courseCode.isNotEmpty)
            Text(session.courseCode),
          Text(
            'Period ${session.periodNumber} • ${session.instructor.isNotEmpty ? session.instructor : 'No instructor'} • ${session.location.isNotEmpty ? session.location : 'No location'}',
          ),
          Row(
            children: [
              if (session.isLab)
                Chip(
                  label: const Text('Lab'),
                  backgroundColor: Colors.purple.shade100,
                  labelStyle: TextStyle(color: Colors.purple.shade900),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              if (session.isLab && session.isTutorial)
                const SizedBox(width: 4),
              if (session.isTutorial)
                Chip(
                  label: const Text('Tutorial'),
                  backgroundColor: Colors.teal.shade100,
                  labelStyle: TextStyle(color: Colors.teal.shade900),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showEditSessionDialog(
              context,
              session,
              controller,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDeleteSession(
              context,
              session,
              controller,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSessionDialog(
    BuildContext context,
    AdminScheduleState state,
    AdminScheduleController controller, {
    DayOfWeek? initialDay,
  }) {
    if (state.selectedClassIdentifier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class first')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => SessionDialog(
        title: 'Add New Session',
        session: ClassSession(
          id: 'new',
          courseName: '',
          courseCode: '',
          instructor: '',
          location: '',
          day: initialDay ?? DayOfWeek.MONDAY,
          periodNumber: 1,
          weekType: state.selectedWeekType,
          classIdentifier: state.selectedClassIdentifier!,
          isLab: false,
          isTutorial: false,
        ),
        onSave: (session) async {
          final result = await controller.addOrUpdateSession(session);
          if (result) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _showEditSessionDialog(
    BuildContext context,
    ClassSession session,
    AdminScheduleController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => SessionDialog(
        title: 'Edit Session',
        session: session,
        onSave: (updatedSession) async {
          final result = await controller.addOrUpdateSession(updatedSession);
          if (result) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _confirmDeleteSession(
    BuildContext context,
    ClassSession session,
    AdminScheduleController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session?'),
        content: Text(
          'Are you sure you want to delete "${session.courseName}" on ${session.day.name}, period ${session.periodNumber}?'
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.deleteSession(session.id);
            },
          ),
        ],
      ),
    );
  }

  void _confirmAddDayOff(
    BuildContext context,
    DayOfWeek day,
    AdminScheduleController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Day Off'),
        content: Text(
          'Add DAY OFF for ${day.name}?'
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Add Day Off'),
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.addDayOff(day);
            },
          ),
        ],
      ),
    );
  }
  
  void _showBulkAddDialog(
    BuildContext context,
    AdminScheduleState state,
    AdminScheduleController controller,
  ) {
    if (state.selectedClassIdentifier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class first')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => BulkAddSessionDialog(
        classIdentifier: state.selectedClassIdentifier!,
        weekType: state.selectedWeekType,
        onAdd: (sessions) async {
          final result = await controller.addMultipleSessions(sessions);
          if (result) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}

// Dialog for adding/editing sessions
class SessionDialog extends StatefulWidget {
  final String title;
  final ClassSession session;
  final Function(ClassSession) onSave;

  const SessionDialog({
    Key? key,
    required this.title,
    required this.session,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SessionDialog> createState() => _SessionDialogState();
}

class _SessionDialogState extends State<SessionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _courseNameController;
  late TextEditingController _courseCodeController;
  late TextEditingController _instructorController;
  late TextEditingController _locationController;
  late DayOfWeek _selectedDay;
  late int _selectedPeriod;
  late bool _isLab;
  late bool _isTutorial;

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController(text: widget.session.courseName);
    _courseCodeController = TextEditingController(text: widget.session.courseCode);
    _instructorController = TextEditingController(text: widget.session.instructor);
    _locationController = TextEditingController(text: widget.session.location);
    _selectedDay = widget.session.day;
    _selectedPeriod = widget.session.periodNumber;
    _isLab = widget.session.isLab;
    _isTutorial = widget.session.isTutorial;
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _instructorController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Course name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courseCodeController,
                decoration: const InputDecoration(
                  labelText: 'Course Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructorController,
                decoration: const InputDecoration(
                  labelText: 'Instructor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DayOfWeek>(
                decoration: const InputDecoration(
                  labelText: 'Day *',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDay,
                items: DayOfWeek.values.map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text(day.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDay = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Period *',
                  border: OutlineInputBorder(),
                ),
                value: _selectedPeriod,
                items: List.generate(5, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text('Period ${index + 1}'),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPeriod = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Lab Class'),
                subtitle: const Text('Laboratory sessions typically held in lab rooms'),
                value: _isLab,
                onChanged: (value) {
                  setState(() {
                    _isLab = value;
                    if (value) {
                      _isTutorial = false;
                    }
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Is Tutorial'),
                subtitle: const Text('Tutorial sessions for practical exercises'),
                value: _isTutorial,
                onChanged: (value) {
                  setState(() {
                    _isTutorial = value;
                    if (value) {
                      _isLab = false;
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final updatedSession = ClassSession(
                id: widget.session.id,
                courseName: _courseNameController.text,
                courseCode: _courseCodeController.text,
                instructor: _instructorController.text,
                location: _locationController.text,
                day: _selectedDay,
                periodNumber: _selectedPeriod,
                weekType: widget.session.weekType,
                classIdentifier: widget.session.classIdentifier,
                isLab: _isLab,
                isTutorial: _isTutorial,
              );

              widget.onSave(updatedSession);
            }
          },
        ),
      ],
    );
  }
}

// Dialog for bulk adding sessions
class BulkAddSessionDialog extends StatefulWidget {
  final ClassIdentifier classIdentifier;
  final WeekType weekType;
  final Function(List<ClassSession>) onAdd;

  const BulkAddSessionDialog({
    Key? key,
    required this.classIdentifier,
    required this.weekType,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<BulkAddSessionDialog> createState() => _BulkAddSessionDialogState();
}

class _BulkAddSessionDialogState extends State<BulkAddSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _instructorController = TextEditingController();
  final _locationController = TextEditingController();
  
  final List<DayOfWeek> _selectedDays = [];
  final List<int> _selectedPeriods = [];
  bool _isLab = false;
  bool _isTutorial = false;

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _instructorController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bulk Add Sessions'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Course name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _courseCodeController,
                decoration: const InputDecoration(
                  labelText: 'Course Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructorController,
                decoration: const InputDecoration(
                  labelText: 'Instructor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              const Text('Select Days:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: DayOfWeek.values.map((day) {
                  return FilterChip(
                    label: Text(day.name),
                    selected: _selectedDays.contains(day),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 12),
              const Text('Select Periods:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: List.generate(5, (index) {
                  final period = index + 1;
                  return FilterChip(
                    label: Text('Period $period'),
                    selected: _selectedPeriods.contains(period),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPeriods.add(period);
                        } else {
                          _selectedPeriods.remove(period);
                        }
                      });
                    },
                  );
                }),
              ),
              
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Is Lab Class'),
                subtitle: const Text('Laboratory sessions'),
                value: _isLab,
                onChanged: (value) {
                  setState(() {
                    _isLab = value;
                    if (value) {
                      _isTutorial = false;
                    }
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Is Tutorial'),
                subtitle: const Text('Tutorial sessions'),
                value: _isTutorial,
                onChanged: (value) {
                  setState(() {
                    _isTutorial = value;
                    if (value) {
                      _isLab = false;
                    }
                  });
                },
              ),
              
              const SizedBox(height: 12),
              Text(
                'This will create ${_selectedDays.length * _selectedPeriods.length} sessions',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Add All'),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              if (_selectedDays.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select at least one day')),
                );
                return;
              }
              
              if (_selectedPeriods.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select at least one period')),
                );
                return;
              }
              
              final List<ClassSession> sessions = [];
              
              for (final day in _selectedDays) {
                for (final period in _selectedPeriods) {
                  sessions.add(ClassSession(
                    id: 'new',
                    courseName: _courseNameController.text,
                    courseCode: _courseCodeController.text,
                    instructor: _instructorController.text,
                    location: _locationController.text,
                    day: day,
                    periodNumber: period,
                    weekType: widget.weekType,
                    classIdentifier: widget.classIdentifier,
                    isLab: _isLab,
                    isTutorial: _isTutorial,
                  ));
                }
              }
              
              widget.onAdd(sessions);
            }
          },
        ),
      ],
    );
  }
}

// Dialog for creating, editing or cloning semesters
class SemesterDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final int? initialSemesterNumber;
  final String? initialAcademicYear;
  final bool isActive;
  final bool isCreating;
  final bool isEditing;
  final bool isCloning;
  final Function(String name, int semesterNumber, String academicYear, bool isActive) onSave;

  const SemesterDialog({
    Key? key,
    required this.title,
    this.initialName,
    this.initialSemesterNumber,
    this.initialAcademicYear,
    this.isActive = false,
    this.isCreating = false,
    this.isEditing = false,
    this.isCloning = false,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SemesterDialog> createState() => _SemesterDialogState();
}

class _SemesterDialogState extends State<SemesterDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _academicYearController;
  late int _semesterNumber;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _academicYearController = TextEditingController(text: widget.initialAcademicYear ?? _getCurrentAcademicYear());
    _semesterNumber = widget.initialSemesterNumber ?? 1;
    _isActive = widget.isActive;
  }

  String _getCurrentAcademicYear() {
    final now = DateTime.now();
    final year = now.month >= 9 ? now.year : now.year - 1;
    return '$year-${year + 1}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Semester Name *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 1st Semester (2024-2025)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Semester name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _academicYearController,
                decoration: const InputDecoration(
                  labelText: 'Academic Year *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 2024-2025',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Academic year is required';
                  }
                  
                  // Validate format (optional)
                  final yearPattern = RegExp(r'^\d{4}-\d{4}$');
                  if (!yearPattern.hasMatch(value)) {
                    return 'Format should be YYYY-YYYY';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Semester Number *',
                  border: OutlineInputBorder(),
                ),
                value: _semesterNumber,
                items: List.generate(4, (index) {
                  final number = index + 1;
                  final suffix = number == 1 ? 'st' : number == 2 ? 'nd' : number == 3 ? 'rd' : 'th';
                  return DropdownMenuItem(
                    value: number,
                    child: Text('$number$suffix Semester'),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _semesterNumber = value;
                    });
                  }
                },
              ),
              if (widget.isCreating || widget.isCloning) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Set as Active Semester'),
                  subtitle: const Text('This will deactivate any currently active semester'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.onSave(
                _nameController.text,
                _semesterNumber,
                _academicYearController.text,
                _isActive,
              );
            }
          },
          child: Text(widget.isEditing ? 'Update' : (widget.isCloning ? 'Clone' : 'Create')),
        ),
      ],
    );
  }
} 