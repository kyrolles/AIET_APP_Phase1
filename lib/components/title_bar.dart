import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  const TitleBar(
      {super.key,
      required this.leftSpace,
      required this.rightSpace,
      required this.title});
  final String title;
  final int rightSpace;
  final int leftSpace;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      height: 75.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          //this boxShadow handle the shadow around the hole bar
          BoxShadow(
            color: const Color(0XFF263238)
                .withOpacity(0.2), //the color of the shadow
            blurRadius: 10,
            offset: const Offset(
                4, 8), //this numbers specify the location of the shadow
          )
        ],
        color: Colors.white,
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              boxShadow: [
                //this boxShadow handle the shadow around the button on the left
                BoxShadow(
                  color: const Color(0XFF263238)
                      .withOpacity(0.2), //the color of the shadow
                  blurRadius: 10,
                  offset: const Offset(
                      0, 0), //this numbers specify the location of the shadow
                )
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(13.0),
            ),
            child: IconButton(
              onPressed: () {
                //what will happend when you press the back button
              },
              icon: const Icon(
                color: Color(0XFF263238),
                Icons.arrow_back_ios_rounded,
              ),
              iconSize: 24.0,
            ),
          ),
          Spacer(
            //the space on the left of the text
            flex: leftSpace,
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          Spacer(
            //the space on the right of the text
            flex: rightSpace,
          ),
        ],
      ),
    );
  }
}
