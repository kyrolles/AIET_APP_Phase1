import 'package:flutter/material.dart';

import '../constants.dart';

class ActivitiesContainer extends StatelessWidget {
  const ActivitiesContainer({
    super.key,
    required this.image,
    required this.title,
    this.onpressed,
  });

  final String image;
  final String title;
  final VoidCallback? onpressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onpressed,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Image.asset(
              image,
              height: 85,
            ),
            Text(
              title,
              style: kTextStyleBold,
            )
          ],
        ),
      ),
    );
  }
}
