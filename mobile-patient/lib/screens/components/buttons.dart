// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MyButtonWidgets {
  final String buttonText1;
  final String buttonText2;
  final VoidCallback onPressed1;
  final VoidCallback onPressed2;

  MyButtonWidgets(
      {required this.buttonText1,
      required this.onPressed1,
      required this.buttonText2,
      required this.onPressed2});

  Widget buildButton() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: onPressed1,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6F7ED7),
              minimumSize: Size(320, 50),
            ),
            child: Text(
              buttonText1,
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
            onPressed: onPressed2,
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
              buttonText2,
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
