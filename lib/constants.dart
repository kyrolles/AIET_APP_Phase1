import 'package:flutter/material.dart';

Color kPrimary = const Color(0XFF3DB2FF);

const kTextFeildInputDecoration = InputDecoration(
  fillColor: Color(0XFFE4F4FF),
  filled: true,
  suffixIcon: Icon(Icons.search),
  suffixIconColor: Color(0XFF888C94),
  hintText: 'Search',
  hintStyle: TextStyle(
    color: Color(0XFF888C94),
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10.0),
    ),
    borderSide: BorderSide.none,
  ),
);
