import 'package:flutter/material.dart';
import 'map_building_selection.dart';
import 'map_search_app_bar.dart';

class MapAppBar extends StatefulWidget implements PreferredSizeWidget {
  final void Function(int) onTabChange;

  const MapAppBar({
    super.key,
    required this.onTabChange,
  });

  @override
  State<MapAppBar> createState() => _MapAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MapAppBarState extends State<MapAppBar> {
  bool _isSearching = false;

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearching) {
      return MapSearchAppBar(
        onClose: _stopSearch,
      );
    }

    return AppBar(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: BuildingSelection(
        onTabChange: widget.onTabChange,
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.search,
            color: Colors.black,
            size: 24,
          ),
          onPressed: _startSearch,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
