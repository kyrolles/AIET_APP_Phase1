import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BuildingSelection extends StatelessWidget {
  final void Function(int)? onTabChange;
  final TabController? tabController; // Add this

  const BuildingSelection({
    super.key,
    required this.onTabChange,
    this.tabController, // Add this
  });
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      width: 180,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: TabBar(
        controller:
            tabController, // Use the passed controller instead of DefaultTabController
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
          fontSize: 15,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 15,
        ),
        dividerHeight: 0,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.apartment, size: 18),
                SizedBox(width: 6),
                Text('A'),
              ],
            ),
          ),
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
