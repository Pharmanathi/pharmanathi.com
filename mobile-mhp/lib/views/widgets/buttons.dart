// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MyButtonWidgets {
  final String buttonTextPrimary;
  final String buttonTextSecondary;
  final VoidCallback onPressedPrimary;
  final VoidCallback onPressedSecondary;

  MyButtonWidgets(
      {required this.buttonTextPrimary,
      required this.onPressedPrimary,
      required this.buttonTextSecondary,
      required this.onPressedSecondary});

  Widget buildButton() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: onPressedPrimary,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6F7ED7),
              minimumSize: Size(320, 50),
            ),
            child: Text(
              buttonTextPrimary,
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 17,
          ),
          ElevatedButton(
            onPressed: onPressedSecondary,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFFFFF),
              minimumSize: Size(320, 50),
              shadowColor: Colors.transparent,
              side: BorderSide(
                color: Color(0xFF6F7ED7),
                width: 1,
              ),
            ),
            child: Text(
              buttonTextSecondary,
              style: TextStyle(
                color: Color(0xFF6F7ED7),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
