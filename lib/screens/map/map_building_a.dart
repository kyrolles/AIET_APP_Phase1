import 'package:flutter/material.dart';
import 'components/map_floor_container.dart';
import '../../constants.dart';
import 'services/map_schedule_service.dart';
import 'services/room_mapping_service.dart';

class BuildingA extends StatefulWidget {
  final DateTime selectedDate;
  final String? highlightedRoom; // Add this

  const BuildingA({
    super.key,
    required this.selectedDate,
    this.highlightedRoom, // Add this
  });

  @override
  State<BuildingA> createState() => _BuildingAState();
}

class _BuildingAState extends State<BuildingA> {
  Map<String, bool> roomOccupancyStatus = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoomStatuses();
  }

  @override
  void didUpdateWidget(BuildingA oldWidget) {
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

      // Define all rooms for Building A
      final List<String> allRooms = [
        // Floor 0
        'M1', 'M2', 'M3', 'CR1', 'CR2', 'CR3', 'CR4', 'DH',
        'B17', 'B19', 'B20', 'B23', 'B24', 'B31', 'B21',
        // Floor M
        'LR1', 'CR5', 'CR6', 'CR7', 'CR8', 'B12', 'B14', 'B13',
        // Floor 3
        'M4', 'M5', 'M6', 'CR9', 'CR10', 'CR11', 'CR12', 'CR13',
        'B4', 'B12', 'B13', 'B14', 'B16', 'B17', 'B18',
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
            print('Error loading status for room $roomName: $e');
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
      print('Error loading room statuses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update the _getRoomColor method:
  Color _getRoomColor(String roomName) {
    if (isLoading) return kGreyLight;

    // Highlight in yellow if this room is selected
    if (widget.highlightedRoom == roomName) {
      return Colors.yellow;
    }

    // Normal room colors
    return roomOccupancyStatus[roomName] == true ? kOrange : kGreyLight;
  }

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

    return Column(
      children: [
        // Floor 0
        FloorContainer(
          floor: '0',
          selectedDate: widget.selectedDate,
          lectures: [
            {'name': 'M1', 'isEmpty': _getRoomColor('M1')},
            {'name': 'M2', 'isEmpty': _getRoomColor('M2')},
            {'name': 'M3', 'isEmpty': _getRoomColor('M3')},
          ],
          sections: [
            {'name': 'CR1', 'isEmpty': _getRoomColor('CR1')},
            {'name': 'CR2', 'isEmpty': _getRoomColor('CR2')},
            {'name': 'CR3', 'isEmpty': _getRoomColor('CR3')},
            {'name': 'CR4', 'isEmpty': _getRoomColor('CR4')},
            {'name': 'DH', 'isEmpty': _getRoomColor('DH')},
          ],
          labs: [
            {'name': 'B17', 'isEmpty': _getRoomColor('B17')},
            {'name': 'B19', 'isEmpty': _getRoomColor('B19')},
            {'name': 'B20', 'isEmpty': _getRoomColor('B20')},
            {'name': 'B23', 'isEmpty': _getRoomColor('B23')},
            {'name': 'B24', 'isEmpty': _getRoomColor('B24')},
            {'name': 'B31', 'isEmpty': _getRoomColor('B31')},
            {'name': 'B21', 'isEmpty': _getRoomColor('B21')},
          ],
        ),
        // Floor M
        FloorContainer(
          floor: 'M',
          selectedDate: widget.selectedDate,
          lectures: [
            {'name': 'LR1', 'isEmpty': _getRoomColor('LR1')},
          ],
          sections: [
            {'name': 'CR5', 'isEmpty': _getRoomColor('CR5')},
            {'name': 'CR6', 'isEmpty': _getRoomColor('CR6')},
            {'name': 'CR7', 'isEmpty': _getRoomColor('CR7')},
            {'name': 'CR8', 'isEmpty': _getRoomColor('CR8')},
          ],
          labs: [
            {'name': 'B12', 'isEmpty': _getRoomColor('B12')},
            {'name': 'B14', 'isEmpty': _getRoomColor('B14')},
            {'name': 'B13', 'isEmpty': _getRoomColor('B13')},
          ],
        ),
        // Floor 3
        FloorContainer(
          floor: '3',
          selectedDate: widget.selectedDate,
          lectures: [
            {'name': 'M4', 'isEmpty': _getRoomColor('M4')},
            {'name': 'M5', 'isEmpty': _getRoomColor('M5')},
            {'name': 'M6', 'isEmpty': _getRoomColor('M6')},
          ],
          sections: [
            {'name': 'CR9', 'isEmpty': _getRoomColor('CR9')},
            {'name': 'CR10', 'isEmpty': _getRoomColor('CR10')},
            {'name': 'CR11', 'isEmpty': _getRoomColor('CR11')},
            {'name': 'CR12', 'isEmpty': _getRoomColor('CR12')},
            {'name': 'CR13', 'isEmpty': _getRoomColor('CR13')},
          ],
          labs: [
            {'name': 'B4', 'isEmpty': _getRoomColor('B4')},
            {'name': 'B12', 'isEmpty': _getRoomColor('B12')},
            {'name': 'B13', 'isEmpty': _getRoomColor('B13')},
            {'name': 'B14', 'isEmpty': _getRoomColor('B14')},
            {'name': 'B16', 'isEmpty': _getRoomColor('B16')},
            {'name': 'B17', 'isEmpty': _getRoomColor('B17')},
            {'name': 'B18', 'isEmpty': _getRoomColor('B18')},
          ],
        ),
      ],
    );
  }
}
