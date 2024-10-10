import 'package:flutter/material.dart';
import 'package:graduation_project/components/map_floor_container.dart';

class BuildingA extends StatelessWidget {
  const BuildingA({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        FloorContainer(floor: '0'),
        FloorContainer(floor: 'M'),
        FloorContainer(floor: '4')
      ],
    );
  }
}
