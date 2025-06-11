import 'package:flutter/material.dart';
import '../components/map_building_b.dart';
import '../components/map_building_a.dart';
import '../components/map_building_selection.dart';
import '../components/my_app_bar.dart';
import '../components/search_bar.dart';
import '../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: MyAppBar(
        title: localizations?.map ?? 'Map',
        onpressed: () => Navigator.pop(context),
        actions: [
          BuildingSelection(
            onTabChange: (index) => navigateBottomBar(index),
          ),
        ],
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
