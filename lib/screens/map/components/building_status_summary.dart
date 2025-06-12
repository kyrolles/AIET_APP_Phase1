import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../constants.dart';
import '../services/map_schedule_service.dart';
import '../services/room_mapping_service.dart';

class BuildingStatusSummary extends StatefulWidget {
  final String buildingName;
  final List<String> allRooms;
  final DateTime selectedDate;

  const BuildingStatusSummary({
    super.key,
    required this.buildingName,
    required this.allRooms,
    required this.selectedDate,
  });

  @override
  State<BuildingStatusSummary> createState() => _BuildingStatusSummaryState();
}

class _BuildingStatusSummaryState extends State<BuildingStatusSummary> {
  bool _isLoading = true;
  int _totalRooms = 0;
  int _occupiedRooms = 0;
  int _availableRooms = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBuildingStatus();
  }

  @override
  void didUpdateWidget(BuildingStatusSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadBuildingStatus();
    }
  }

  Future<void> _loadBuildingStatus() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      _totalRooms = widget.allRooms.length;
      _occupiedRooms = 0;

      final currentPeriod = MapScheduleService.getCurrentPeriod(DateTime.now());

      for (final roomName in widget.allRooms) {
        final scheduleId = RoomMappingService.getScheduleId(roomName);
        if (RoomMappingService.hasScheduleData(roomName)) {
          try {
            final isOccupied = await MapScheduleService.isRoomOccupied(
              roomId: scheduleId,
              selectedDate: widget.selectedDate,
              currentPeriod: currentPeriod,
            );
            if (isOccupied) _occupiedRooms++;
          } catch (e) {
            print('Error checking room $roomName: $e');
          }
        }
      }

      _availableRooms = _totalRooms - _occupiedRooms;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: kPrimaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  localizations?.buildingStatus(widget.buildingName) ??
                      'Building ${widget.buildingName} Status',
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(localizations?.loading ?? 'Loading...'),
                    ],
                  ),
                ),
              )
            else if (_error != null)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      localizations?.errorLoadingStatus ??
                          'Error loading status',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ],
                ),
              )
            else
              _buildStatusContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusContent() {
    final localizations = AppLocalizations.of(context);
    final occupancyRate =
        _totalRooms > 0 ? (_occupiedRooms / _totalRooms) : 0.0;

    return Column(
      children: [
        // Occupancy rate indicator
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations?.occupancyRate ?? 'Occupancy Rate',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: occupancyRate,
                      backgroundColor: kGreyLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        occupancyRate > 0.7
                            ? Colors.red
                            : occupancyRate > 0.4
                                ? kOrange
                                : Colors.green,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(occupancyRate * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Room statistics
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                localizations?.totalRooms ?? 'Total Rooms',
                _totalRooms.toString(),
                kPrimaryColor,
                Icons.meeting_room,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                localizations?.occupiedRooms ?? 'Occupied',
                _occupiedRooms.toString(),
                Colors.red,
                Icons.person,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                localizations?.availableRooms ?? 'Available',
                _availableRooms.toString(),
                Colors.green,
                Icons.check_circle,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12), // Current period info
        Text(
          '${localizations?.currentPeriod ?? "Current Period"}: ${_getCurrentPeriodString()}',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getCurrentPeriodString() {
    final currentPeriod = MapScheduleService.getCurrentPeriod(DateTime.now());
    return 'Period $currentPeriod';
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
