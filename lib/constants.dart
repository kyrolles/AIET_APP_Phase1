import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0XFF3DB2FF);
const Color kGrey = Color(0XFF888C94);
const Color kGreyLight = Color(0XFFE5E5E5);
const Color kOrange = Color(0XFFFF7648);
const Color kLightGrey = Color(0xFFE1E8ED);
const Color kBlue = Color.fromRGBO(6, 147, 241, 1);
const Color kDarkBlue = Color.fromRGBO(41, 128, 185, 1);
const Color kgreen = Color.fromRGBO(52, 199, 89, 1);
const Color kbabyblue = Color.fromRGBO(228, 244, 255, 1);

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

const kTextStyleSize24 = TextStyle(
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
