import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../constants.dart';

class BuildingSelection extends StatelessWidget {
  final void Function(int)? onTabChange;
  const BuildingSelection({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return GNav(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      iconSize: 24,
      color: Colors.grey[400], // unselected icon color
      activeColor: kOrange, // selected icon and text color
      tabActiveBorder: Border.all(color: Colors.white),
      tabBackgroundColor: Colors.grey.shade100,
      mainAxisAlignment: MainAxisAlignment.center,
      tabBorderRadius: 20,
      onTabChange: (value) => onTabChange!(value),
      tabs: [
        //* the button of the building A
        GButton(
          icon: Icons.apartment,
          text: 'A',
          textStyle: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: kOrange),
        ),
        //* the button of the building B
        GButton(
          icon: Icons.apartment,
          text: 'B',
          textStyle: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: kOrange),
        )
      ],
    );
  }
}
