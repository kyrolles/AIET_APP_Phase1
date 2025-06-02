import 'package:flutter/material.dart';
import 'map_floor_container.dart';
import '../../constants.dart';

class BuildingB extends StatelessWidget {
  const BuildingB({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Floor 0
        FloorContainer(
          floor: '0',
          lectures: [
            {'name': 'shbana', 'isEmpty': kGreyLight},
          ],
        ),
        // Floor 0
        FloorContainer(
          floor: '1',
          lectures: [
            {'name': 'M7', 'isEmpty': kOrange},
            {'name': 'M8', 'isEmpty': kGreyLight},
          ],
          labs: [
            {'name': 'B05', 'isEmpty': kGreyLight},
            {'name': 'B06', 'isEmpty': kOrange},
          ],
        ),
        // Floor 2
        FloorContainer(
          floor: '2',
          lectures: [
            {'name': 'M9', 'isEmpty': kOrange},
            {'name': 'M10', 'isEmpty': kGreyLight},
          ],
          labs: [
            {'name': 'B04', 'isEmpty': kGreyLight},
            {'name': 'B05', 'isEmpty': kOrange},
          ],
        ),
        // Floor 3
        FloorContainer(
          floor: '3',
          lectures: [
            {'name': 'M11', 'isEmpty': kOrange},
          ],
          labs: [
            {'name': 'B05', 'isEmpty': kGreyLight},
            {'name': 'B06', 'isEmpty': kOrange},
            {'name': 'B07', 'isEmpty': kOrange},
          ],
        ),
        // Floor 4
        FloorContainer(
          floor: '4',
          lectures: [
            {'name': 'LR2', 'isEmpty': kOrange},
          ],
          labs: [
            {'name': 'B06', 'isEmpty': kGreyLight},
            {'name': 'B07', 'isEmpty': kOrange},
            {'name': 'B08', 'isEmpty': kOrange},
          ],
        ),
      ],
    );
  }
}
