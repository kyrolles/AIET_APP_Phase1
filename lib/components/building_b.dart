import 'package:flutter/material.dart';

class BuildingB extends StatelessWidget {
  const BuildingB({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.red,
      child: const Text('Building B'),
    );
  }
}
