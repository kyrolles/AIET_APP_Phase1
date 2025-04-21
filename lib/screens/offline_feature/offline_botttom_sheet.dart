import 'package:flutter/material.dart';

import '../../components/kbutton.dart';
import '../../constants.dart';

class OfflineBottomSheet extends StatelessWidget {
  const OfflineBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.signal_wifi_off, size: 64, color: Colors.grey),
          const Center(
            child: Text(
              "You're offline",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text(
            "There are no bottons to push\nJust turn off your internet.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          KButton(
            text: 'Close',
            backgroundColor: kPrimaryColor,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
