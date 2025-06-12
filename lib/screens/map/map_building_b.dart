import 'package:flutter/material.dart';
import 'components/map_floor_container.dart';
import '../../constants.dart';
import 'services/map_schedule_service.dart';
import 'services/room_mapping_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BuildingB extends StatefulWidget {
  final DateTime selectedDate;
  final String? highlightedRoom; // Add this

  const BuildingB({
    super.key,
    required this.selectedDate,
    this.highlightedRoom, // Add this
  });

  @override
  State<BuildingB> createState() => _BuildingBState();
}

class _BuildingBState extends State<BuildingB> {
  Map<String, bool> roomOccupancyStatus = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoomStatuses();
  }

  @override
  void didUpdateWidget(BuildingB oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadRoomStatuses();
    }
  }

  Future<void> _loadRoomStatuses() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Check if selected date is today, if so use current time instead of midnight
      final now = DateTime.now();
      final isToday = widget.selectedDate.year == now.year &&
          widget.selectedDate.month == now.month &&
          widget.selectedDate.day == now.day;
      final effectiveDateTime = isToday ? now : widget.selectedDate;

      final currentPeriod =
          MapScheduleService.getCurrentPeriod(effectiveDateTime);
      final Map<String, bool> newStatuses = {};

      // Define all rooms for Building B
      final List<String> allRooms = [
        // Floor 0
        'shbana',
        // Floor 1
        'M7', 'M8', 'B05', 'B06',
        // Floor 2
        'M9', 'M10', 'B04', 'B05',
        // Floor 3
        'M11', 'B05', 'B06', 'B07',
        // Floor 4
        'LR2', 'B06', 'B07', 'B08',
      ];

      // Load occupancy status for each room
      for (final roomName in allRooms) {
        final scheduleId = RoomMappingService.getScheduleId(roomName);
        if (RoomMappingService.hasScheduleData(roomName)) {
          try {
            final isOccupied = await MapScheduleService.isRoomOccupied(
              roomId: scheduleId,
              selectedDate: widget.selectedDate,
              currentPeriod: currentPeriod,
            );
            newStatuses[roomName] = isOccupied;
          } catch (e) {
            newStatuses[roomName] = false; // Default to available
          }
        } else {
          newStatuses[roomName] = false; // No schedule data = available
        }
      }

      setState(() {
        roomOccupancyStatus = newStatuses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Get the actual occupancy status without highlighting
  bool _getRoomOccupancyStatus(String roomName) {
    if (isLoading) return false;
    return roomOccupancyStatus[roomName] == true;
  }

  // Get the visual color for the room (includes highlighting)
  Color _getRoomColor(String roomName) {
    if (isLoading) return kGreyLight;

    // Highlight in yellow if this room is selected
    if (widget.highlightedRoom == roomName) {
      return Colors.yellow;
    }

    // Normal room colors based on occupancy
    return roomOccupancyStatus[roomName] == true ? kOrange : kGreyLight;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(localizations?.loading ?? 'Loading...'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Floor 0
        FloorContainer(
          floor: '0',
          selectedDate: widget.selectedDate,
          lectures: [
            {
              'name': 'shbana',
              'isEmpty': _getRoomColor('shbana'),
              'isOccupied': _getRoomOccupancyStatus('shbana')
            },
          ],
        ),
        // Floor 1
        FloorContainer(
          floor: '1',
          selectedDate: widget.selectedDate,
          lectures: [
            {
              'name': 'M7',
              'isEmpty': _getRoomColor('M7'),
              'isOccupied': _getRoomOccupancyStatus('M7')
            },
            {
              'name': 'M8',
              'isEmpty': _getRoomColor('M8'),
              'isOccupied': _getRoomOccupancyStatus('M8')
            },
          ],
          labs: [
            {
              'name': 'B05',
              'isEmpty': _getRoomColor('B05'),
              'isOccupied': _getRoomOccupancyStatus('B05')
            },
            {
              'name': 'B06',
              'isEmpty': _getRoomColor('B06'),
              'isOccupied': _getRoomOccupancyStatus('B06')
            },
          ],
        ),
        // Floor 2
        FloorContainer(
          floor: '2',
          selectedDate: widget.selectedDate,
          lectures: [
            {
              'name': 'M9',
              'isEmpty': _getRoomColor('M9'),
              'isOccupied': _getRoomOccupancyStatus('M9')
            },
            {
              'name': 'M10',
              'isEmpty': _getRoomColor('M10'),
              'isOccupied': _getRoomOccupancyStatus('M10')
            },
          ],
          labs: [
            {
              'name': 'B04',
              'isEmpty': _getRoomColor('B04'),
              'isOccupied': _getRoomOccupancyStatus('B04')
            },
            {
              'name': 'B05',
              'isEmpty': _getRoomColor('B05'),
              'isOccupied': _getRoomOccupancyStatus('B05')
            },
          ],
        ),
        // Floor 3
        FloorContainer(
          floor: '3',
          selectedDate: widget.selectedDate,
          lectures: [
            {
              'name': 'M11',
              'isEmpty': _getRoomColor('M11'),
              'isOccupied': _getRoomOccupancyStatus('M11')
            },
          ],
          labs: [
            {
              'name': 'B05',
              'isEmpty': _getRoomColor('B05'),
              'isOccupied': _getRoomOccupancyStatus('B05')
            },
            {
              'name': 'B06',
              'isEmpty': _getRoomColor('B06'),
              'isOccupied': _getRoomOccupancyStatus('B06')
            },
            {
              'name': 'B07',
              'isEmpty': _getRoomColor('B07'),
              'isOccupied': _getRoomOccupancyStatus('B07')
            },
          ],
        ),
        // Floor 4
        FloorContainer(
          floor: '4',
          selectedDate: widget.selectedDate,
          lectures: [
            {
              'name': 'LR2',
              'isEmpty': _getRoomColor('LR2'),
              'isOccupied': _getRoomOccupancyStatus('LR2')
            },
          ],
          labs: [
            {
              'name': 'B06',
              'isEmpty': _getRoomColor('B06'),
              'isOccupied': _getRoomOccupancyStatus('B06')
            },
            {
              'name': 'B07',
              'isEmpty': _getRoomColor('B07'),
              'isOccupied': _getRoomOccupancyStatus('B07')
            },
            {
              'name': 'B08',
              'isEmpty': _getRoomColor('B08'),
              'isOccupied': _getRoomOccupancyStatus('B08')
            },
          ],
        ),
      ],
    );
  }
}
