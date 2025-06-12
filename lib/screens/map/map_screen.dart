import 'package:flutter/material.dart';
import 'map_building_b.dart';
import 'map_building_a.dart';
import 'components/map_app_bar.dart';
import 'components/map_date_timeline.dart';
import '../../constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  int _selectedindex = 0;
  DateTime _selectedDate = DateTime.now();
  late TabController _tabController;
  String? _highlightedRoom; // Add this

  // Simple room-to-building mapping
  String _getBuildingForRoom(String roomName) {
    final buildingARooms = [
      'M1',
      'M2',
      'M3',
      'M4',
      'M5',
      'M6',
      'CR1',
      'CR2',
      'CR3',
      'CR4',
      'CR5',
      'CR6',
      'CR7',
      'CR8',
      'CR9',
      'CR10',
      'CR11',
      'CR12',
      'CR13',
      'LR1',
      'DH',
      'B4',
      'B12',
      'B13',
      'B14',
      'B16',
      'B17',
      'B18',
      'B19',
      'B20',
      'B21',
      'B23',
      'B24',
      'B31'
    ];

    return buildingARooms.contains(roomName) ? 'A' : 'B';
  }

  void _highlightRoom(String roomName) {
    setState(() {
      _highlightedRoom = roomName;
    });

    // Super simple building navigation - just update the index!
    final targetBuilding = _getBuildingForRoom(roomName);
    final targetIndex = targetBuilding == 'A' ? 0 : 1;

    if (_selectedindex != targetIndex) {
      // Just update the tab index - that's it!
      _tabController.animateTo(targetIndex);
    }

    // Show room found message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Found room: $roomName'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // Clear highlight after 15 seconds
    Future.delayed(Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _highlightedRoom = null;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        navigateBottomBar(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //this method will update our selected index
  //when the user taps on the bottom bar
  void navigateBottomBar(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  //Building pages to display
  List<Widget> get _widgetOptions => [
        BuildingA(
          selectedDate: _selectedDate,
          highlightedRoom: _highlightedRoom, // Add this
        ),
        BuildingB(
          selectedDate: _selectedDate,
          highlightedRoom: _highlightedRoom, // Add this
        )
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MapAppBar(
        onTabChange: (index) => navigateBottomBar(index),
        selectedDate: _selectedDate,
        onRoomFound: _highlightRoom,
        tabController: _tabController, // Pass the controller
      ),
      body: SafeArea(
        child: ListView(
          children: [
            MapDateTimeline(
              selectedDate: _selectedDate,
              onDateChange: (selectedDate) {
                setState(() {
                  _selectedDate = selectedDate;
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.all(14.0),
              child: Text(
                'Floor',
                style: kTextStyleNormal,
              ),
            ),
            Center(
              child: _widgetOptions.elementAt(_selectedindex),
            )
          ],
        ),
      ),
    );
  }
}
