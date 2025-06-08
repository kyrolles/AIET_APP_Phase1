import 'package:flutter/material.dart';
import 'map_floor_container.dart';
import '../../constants.dart';

class BuildingA extends StatelessWidget {
  const BuildingA({
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
            {'name': 'M1', 'isEmpty': kOrange},
            {'name': 'M2', 'isEmpty': kGreyLight},
            {'name': 'M3', 'isEmpty': kGreyLight},
          ],
          sections: [
            {'name': 'CR1', 'isEmpty': kGreyLight},
            {'name': 'CR2', 'isEmpty': kOrange},
            {'name': 'CR3', 'isEmpty': kOrange},
            {'name': 'CR4', 'isEmpty': kGreyLight},
            {'name': 'DH', 'isEmpty': kGreyLight},
          ],
          labs: [
            {'name': 'B17', 'isEmpty': kGreyLight},
            {'name': 'B19', 'isEmpty': kOrange},
            {'name': 'B20', 'isEmpty': kGreyLight},
            {'name': 'B23', 'isEmpty': kOrange},
            {'name': 'B24', 'isEmpty': kOrange},
            {'name': 'B31', 'isEmpty': kGreyLight},
            {'name': 'B21', 'isEmpty': kGreyLight},
          ],
        ),
        // Floor M
        FloorContainer(
          floor: 'M',
          lectures: [
            {'name': 'LR1', 'isEmpty': kOrange},
          ],
          sections: [
            {'name': 'CR5', 'isEmpty': kGreyLight},
            {'name': 'CR6', 'isEmpty': kOrange},
            {'name': 'CR7', 'isEmpty': kOrange},
            {'name': 'CR8', 'isEmpty': kOrange},
          ],
          labs: [
            {'name': 'B12', 'isEmpty': kGreyLight},
            {'name': 'B14', 'isEmpty': kGreyLight},
            {'name': 'B13', 'isEmpty': kGreyLight},
          ],
        ),
        // Floor 4
        FloorContainer(
          floor: '3',
          lectures: [
            {'name': 'M4', 'isEmpty': kOrange},
            {'name': 'M5', 'isEmpty': kGreyLight},
            {'name': 'M6', 'isEmpty': kGreyLight},
          ],
          sections: [
            {'name': 'CR9', 'isEmpty': kGreyLight},
            {'name': 'CR10', 'isEmpty': kOrange},
            {'name': 'CR11', 'isEmpty': kOrange},
            {'name': 'CR12', 'isEmpty': kOrange},
            {'name': 'CR13', 'isEmpty': kOrange},
          ],
          labs: [
            {'name': 'B4', 'isEmpty': kOrange},
            {'name': 'B12', 'isEmpty': kOrange},
            {'name': 'B13', 'isEmpty': kGreyLight},
            {'name': 'B14', 'isEmpty': kGreyLight},
            {'name': 'B16', 'isEmpty': kGreyLight},
            {'name': 'B17', 'isEmpty': kGreyLight},
            {'name': 'B18', 'isEmpty': kGreyLight},
          ],
        ),
      ],
    );
  }
}
