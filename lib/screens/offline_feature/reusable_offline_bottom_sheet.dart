import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

import 'offline_botttom_sheet.dart';

class OfflineAwareBottomSheet extends StatelessWidget {
  final Widget onlineContent;

  const OfflineAwareBottomSheet({
    super.key,
    required this.onlineContent,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget onlineContent,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    bool? isScrollControlled,
  }) {
    return showModalBottomSheet<T>(
      isScrollControlled: isScrollControlled ?? false,
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      builder: (context) => OfflineAwareBottomSheet(
        onlineContent: onlineContent,
      ),
    );
  }

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
          return onlineContent;
        } else {
          return const OfflineBottomSheet();
        }
      },
      child: onlineContent, // placeholder
    );
  }
}
