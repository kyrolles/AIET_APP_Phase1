import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:graduation_project/screens/offline_feature/offline_refresh_icon_ui.dart';

class OfflineRefreshIcon extends StatelessWidget {
  const OfflineRefreshIcon({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
      connectivityBuilder: (
        BuildContext context,
        List<ConnectivityResult> connectivity,
        Widget child,
      ) {
        final bool connected = !connectivity.contains(ConnectivityResult.none);
        if (connected) {
          return child;
        } else {
          return const OfflineRefreshIconUi();
        }
      },
      child: child,
    );
  }
}
