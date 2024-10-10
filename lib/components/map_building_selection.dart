import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:graduation_project/constants.dart';

class BuildingSelection extends StatelessWidget {
  final void Function(int)? onTabChange;
  const BuildingSelection({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return GNav(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      iconSize: 18,
      color: Colors.grey[400], // unselected icon color
      activeColor: kOrange, // selected icon and text color
      tabActiveBorder: Border.all(color: Colors.white),
      tabBackgroundColor: Colors.grey.shade100,
      mainAxisAlignment: MainAxisAlignment.center,
      tabBorderRadius: 20,
      onTabChange: (value) => onTabChange!(value),
      tabs: [
        GButton(
          icon: Icons.apartment,
          text: 'A',
          textStyle: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: kOrange),
        ),
        GButton(
          icon: Icons.apartment,
          text: 'B',
          textStyle: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: kOrange),
        )
      ],
    );
  }
}
