import 'package:flutter/material.dart';
import 'package:graduation_project/components/title_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TitleBar(
              title: 'Map',
              rightSpace: 5,
              leftSpace: 3,
            ),
          ],
        ),
      ),
    );
  }
}
