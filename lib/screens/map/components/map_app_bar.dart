import 'package:flutter/material.dart';
import 'map_building_selection.dart';
import '../search_map_screen.dart'; // Changed to use your existing file

class MapAppBar extends StatefulWidget implements PreferredSizeWidget {
  final void Function(int) onTabChange;
  final DateTime selectedDate;
  final void Function(String)? onRoomFound;
  final TabController? tabController; // Add this

  const MapAppBar({
    super.key,
    required this.onTabChange,
    required this.selectedDate,
    this.onRoomFound,
    this.tabController, // Add this
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<MapAppBar> createState() => _MapAppBarState();
}

class _MapAppBarState extends State<MapAppBar> {
  void _startSearch() async {
    final roomName = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchMapScreen(
          selectedDate: widget.selectedDate,
        ),
      ),
    );

    if (roomName != null) {
      // Call a callback to highlight the room
      widget.onRoomFound?.call(roomName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: BuildingSelection(
        onTabChange: widget.onTabChange,
        tabController: widget.tabController, // Pass the controller
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black, size: 24),
          onPressed: _startSearch,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
