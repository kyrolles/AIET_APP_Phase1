import 'package:flutter/material.dart';

Color kPrimary = const Color(0XFF3DB2FF);

const kShadow = [
  //this boxShadow handle the shadow around the button on the left
  BoxShadow(
    color: Color(0X19000000), //the color of the shadow
    blurRadius: 20,
    offset: Offset(0, 8), //this numbers specify the location of the shadow
  )
];

const kTextFeildInputDecoration = InputDecoration(
  fillColor: Color(0XFFE4F4FF), //background color
  filled: true,
  suffixIcon: Icon(Icons.search),
  suffixIconColor: Color(0XFF888C94), //icon color
  hintText: 'Search',
  hintStyle: TextStyle(
    color: Color(0XFF888C94), // text color in the textfield
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10.0),
    ),
    borderSide: BorderSide.none,
  ),
);
