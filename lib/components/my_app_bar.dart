import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget {
  MyAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  final String title;
  List<Widget>? actions;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.white,
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
      actions: actions,
    );
  }
}
