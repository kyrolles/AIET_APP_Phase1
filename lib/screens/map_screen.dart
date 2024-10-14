import 'package:flutter/material.dart';
import 'package:graduation_project/components/map_building_b.dart';
import 'package:graduation_project/components/map_building_a.dart';
import 'package:graduation_project/components/map_building_selection.dart';
import 'package:graduation_project/components/my_app_bar.dart';
import 'package:graduation_project/components/search_bar.dart';
import 'package:graduation_project/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedindex = 0;

//this method will update our selected index
//when the user taps on the bottom bar
  void navigateBottomBar(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

//Building pages to display
  final List<Widget> _widgetOptions = const [BuildingA(), BuildingB()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(kToolbarHeight), // Standard AppBar height
        child: DecoratedBox(
          decoration: const BoxDecoration(boxShadow: kShadow),
          child: MyAppBar(
            title: 'Map',
            actions: [
              BuildingSelection(
                onTabChange: (index) => navigateBottomBar(index),
              ),
            ],
          ),
        ),
      ),
      //////////////////////////////////////////////////////////////////////////
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(
              height: 35,
            ),
            const MySearchBar(),
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
