import 'package:flutter/material.dart';

Color kPrimary = const Color(0XFF3DB2FF);
Color kGrey = const Color(0XFF888C94);
Color kGreyLight = const Color(0XFFE5E5E5);
Color kOrange = const Color(0XFFFF7648);
const Color kLightGrey = Color(0xFFE1E8ED);

const kTextStyleBold = TextStyle(
  fontFamily: 'Lexend',
  fontWeight: FontWeight.w600,
  fontSize: 18,
);

const kTextStyleNormal = TextStyle(
  fontFamily: 'Lexend',
  // fontWeight: FontWeight.w600,
  fontSize: 18,
);

const kTextStyleNumber = TextStyle(
  fontFamily: 'Lexend',
  fontWeight: FontWeight.w600,
  fontSize: 24,
);

const kShadow = [
  //this boxShadow handle the shadow around the button on the left
  BoxShadow(
    color: Color(0X19000000), //the color of the shadow
    blurRadius: 20,
    offset: Offset(0, 8), //this numbers specify the location of the shadow
  )
];

var kTextFeildInputDecoration = InputDecoration(
  enabledBorder: OutlineInputBorder(
    //border color
    borderSide: const BorderSide(color: Color(0XFF888C94), width: 2),
    borderRadius: BorderRadius.circular(10),
  ),
  focusedBorder: OutlineInputBorder(
    //border color when search is pressed
    borderSide: const BorderSide(
      color: Color(0XFF888C94),
      width: 2,
    ),
    borderRadius: BorderRadius.circular(10),
  ),
  fillColor: Colors.white, //background color
  filled: true,
  suffixIcon: const Icon(Icons.search),
  suffixIconColor: const Color(0XFF888C94), //icon color
  hintText: 'Search',
  hintStyle: const TextStyle(
    color: Color(0XFF888C94), // text color in the textfield
  ),
  border: const OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10.0),
    ),
    borderSide: BorderSide.none,
  ),
);
