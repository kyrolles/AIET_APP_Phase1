import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget {
  MyAppBar(
      {super.key, required this.title, this.actions, required this.onpressed});

  final String title;
  List<Widget>? actions;
  VoidCallback onpressed;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor:
          Colors.white, //* make the color of the appBar white while scrolling
      leading: IconButton(
        onPressed: onpressed,
        icon: const Image(
          image: AssetImage('assets/images/Back Button.png'),
          fit: BoxFit.contain, //* Ensure the image fits without distortion
        ),
      ),
      title: Text(
        title,
      ),
      actions: actions,
    );
  }
}
