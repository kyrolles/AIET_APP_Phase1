import 'package:flutter/material.dart';

import '../../../constants.dart';

class TextAndDataWidget extends StatelessWidget {
  const TextAndDataWidget({
    super.key,
    required this.text,
    required this.data,
  });

  final String text;
  final String data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        children: [
          Text(
            text,
            style: kTextStyleNormal,
          ),
          Text(
            data,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            style: kTextStyleNormal,
          ),
        ],
      ),
    );
  }
}
