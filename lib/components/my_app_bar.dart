import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({
    super.key,
    required this.title,
  });

  final String title;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () {},
        icon: const Image(
          image: AssetImage('assets/images/Back Button.png'),
          fit: BoxFit.contain, // Ensure the image fits without distortion
        ),
      ),
      title: Text(
        title,
      ),
    );
  }
}
