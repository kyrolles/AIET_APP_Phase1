import 'package:flutter/material.dart';

import '../../constants.dart';

class OfflineRefreshIconUi extends StatelessWidget {
  const OfflineRefreshIconUi({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      color: kPrimaryColor,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }
}
