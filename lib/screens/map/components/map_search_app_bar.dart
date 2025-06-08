import 'package:flutter/material.dart';

class MapSearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onClose;

  const MapSearchAppBar({
    super.key,
    required this.onClose,
  });

  @override
  State<MapSearchAppBar> createState() => _MapSearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MapSearchAppBarState extends State<MapSearchAppBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black,
        ),
        onPressed: widget.onClose,
      ),
      centerTitle: false,
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(color: Colors.black, fontSize: 16),
        onChanged: (value) {
          setState(() {}); // Trigger rebuild to show/hide clear button
          // TODO: Implement search filtering
        },
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.black),
            onPressed: () {
              _searchController.clear();
              setState(() {});
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}
