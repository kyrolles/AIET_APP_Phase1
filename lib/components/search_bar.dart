import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';

class MySearchBar extends StatelessWidget {
  const MySearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 10.0),
      child: TextField(
        style: const TextStyle(
          color: Colors.black,
        ),
        decoration: kTextFeildInputDecoration,
        onChanged: (value) {},
      ),
    );
  }
}
