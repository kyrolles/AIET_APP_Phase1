import 'package:flutter/material.dart';
import 'dart:async';
import 'services/map_schedule_service.dart';
import 'utils/time_utils.dart';
import 'widgets/room_header_widget.dart';
import 'widgets/schedule_header_widget.dart';
import 'widgets/schedule_content_widget.dart';

class RoomDetailsBottomSheet extends StatefulWidget {
  final String roomName;
  final bool isEmpty;
  final String roomType; // "Lecture", "Section", or "Lab"
  final DateTime selectedDate;

  const RoomDetailsBottomSheet({
    super.key,
    required this.roomName,
    required this.roomType,
    required this.isEmpty,
    required this.selectedDate,
  });

  @override
  State<RoomDetailsBottomSheet> createState() => _RoomDetailsBottomSheetState();
}

class _RoomDetailsBottomSheetState extends State<RoomDetailsBottomSheet> {
  final MapScheduleService _scheduleService = MapScheduleService();
  List<Map<String, dynamic>> _daySchedule = [];
  bool _isLoading = true;
  String? _error;
  int _currentPeriod = 0;
  Timer? _periodTimer;
  DateTime _lastUpdateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadRoomSchedule();
    _startPeriodTimer();
  }

  @override
  void dispose() {
    _periodTimer?.cancel();
    super.dispose();
  }

  void _startPeriodTimer() {
    // Update current period every minute to handle real-time changes
    _periodTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      final newCurrentPeriod = MapScheduleService.getCurrentPeriod(now);

      // Only update if period changed or if it's been more than 5 minutes since last update
      if (newCurrentPeriod != _currentPeriod ||
          now.difference(_lastUpdateTime).inMinutes >= 5) {
        setState(() {
          _currentPeriod = newCurrentPeriod;
          _lastUpdateTime = now;
        });
      }
    });
  }

  Future<void> _loadRoomSchedule() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current period for highlighting
      _currentPeriod = MapScheduleService.getCurrentPeriod(DateTime.now());

      print(
          'Loading schedule for room: ${widget.roomName} on date: ${widget.selectedDate}');

      final schedule = await _scheduleService.getRoomScheduleForDate(
        widget.roomName,
        widget.selectedDate,
      );

      print(
          'Loaded ${schedule.length} schedule entries for ${widget.roomName}');
      if (schedule.isNotEmpty) {
        print('First entry: ${schedule.first}');
      }

      setState(() {
        _daySchedule = schedule;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading room schedule: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Calculate available height (70% of screen height, adjusted for keyboard)
    final maxHeight = (screenHeight * 0.8) - keyboardHeight;
    final minHeight = screenHeight * 0.3;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        minHeight: minHeight,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed header section (handle + room info)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Room header
                RoomHeaderWidget(
                  roomName: widget.roomName,
                  roomType: widget.roomType,
                  isEmpty: widget.isEmpty,
                ),
                const SizedBox(height: 20),

                // Schedule header
                ScheduleHeaderWidget(
                  statusText: TimeUtils.getCurrentPeriodStatus(
                      widget.selectedDate, _currentPeriod),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Scrollable content section
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Schedule content
                    ScheduleContentWidget(
                      isLoading: _isLoading,
                      error: _error,
                      daySchedule: _daySchedule,
                      currentPeriod: _currentPeriod,
                      selectedDate: widget.selectedDate,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
