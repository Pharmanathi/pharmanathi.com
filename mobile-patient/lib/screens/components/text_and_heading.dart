// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

class TextAndHeadingComponents {
  static Widget buildHeading(String heading) {
    return Text(
      heading, // Use the provided heading parameter
      style: TextStyle(
        color:  Color(0xFF6F7ED7),
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static Widget buildText(String text) {
    return Text(
      text, // Use the provided text parameter
      style: TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
    );
  }
}

