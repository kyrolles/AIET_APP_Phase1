import 'package:flutter/material.dart';
import '../../constants.dart';

class BuildingSelection extends StatelessWidget {
  final void Function(int)? onTabChange;
  const BuildingSelection({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // Slightly smaller width for better centering
      height: 45, // Slightly smaller height for app bar
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: TabBar(
        padding: const EdgeInsets.all(3),
        onTap: (value) => onTabChange!(value),
        indicator: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15, // Slightly smaller font
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 15,
        ),
        dividerHeight: 0,
        tabs: const [
          //* the button of the building A
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.apartment, size: 18), // Slightly smaller icon
                SizedBox(width: 6),
                Text('A'),
              ],
            ),
          ),
          //* the button of the building B
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.apartment, size: 18),
                SizedBox(width: 6),
                Text('B'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
