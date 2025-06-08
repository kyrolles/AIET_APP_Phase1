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
        BuildingA(selectedDate: _selectedDate),
        BuildingB(selectedDate: _selectedDate)
      ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: MapAppBar(
          onTabChange: (index) => navigateBottomBar(index),
        ),
        //////////////////////////////////////////////////////////////////////////
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
      ),
    );
  }
}
