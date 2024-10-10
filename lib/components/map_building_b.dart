import 'package:flutter/material.dart';
import 'package:graduation_project/components/map_floor_container.dart';

class BuildingB extends StatelessWidget {
  const BuildingB({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        FloorContainer(floor: '0'),
        FloorContainer(floor: 'M'),
        FloorContainer(floor: '1'),
        FloorContainer(floor: '2'),
        FloorContainer(floor: '3'),
        // FloorContainer(floor: '4'),
      ],
    );
  }
}
