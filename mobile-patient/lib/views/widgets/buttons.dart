// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MyButtonWidgets {
  final String? buttonTextPrimary;
  final String? buttonTextSecondary;
  final VoidCallback? onPressedPrimary;
  final VoidCallback? onPressedSecondary;

  MyButtonWidgets({
    this.buttonTextPrimary,
    this.onPressedPrimary,
    this.buttonTextSecondary,
    this.onPressedSecondary,
  });

  Widget buildButton({
    required String text,
    required VoidCallback onPressed,
    required ButtonStyle style,
    required Color textColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildButtons({
    bool primaryFirst = false,
    bool showPrimary = true,
    bool showSecondary = true,
  }) {
    final primaryButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF6F7ED7), // Background color for primary button
      minimumSize: Size(320, 45),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), 
      ),
    );

    final secondaryButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white, // Background color for secondary button
      minimumSize: Size(320, 45),
      elevation: 0,
      side: BorderSide(
        color: Color(0xFF6F7ED7),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), 
      ),
    );

    final primaryButton = buttonTextPrimary != null && onPressedPrimary != null
        ? buildButton(
            text: buttonTextPrimary!,
            onPressed: onPressedPrimary!,
            style: primaryButtonStyle,
            textColor: Colors.white, // Text color for primary button
          )
        : null;

    final secondaryButton = buttonTextSecondary != null && onPressedSecondary != null
        ? buildButton(
            text: buttonTextSecondary!,
            onPressed: onPressedSecondary!,
            style: secondaryButtonStyle,
            textColor: Color(0xFF6F7ED7), // Text color for secondary button
          )
        : null;

    List<Widget> buttons = [];
    if (showPrimary && primaryButton != null) {
      buttons.add(primaryButton);
    }
    if (showSecondary && secondaryButton != null) {
      if (buttons.isNotEmpty) {
        buttons.add(SizedBox(height: 7));
      }
      buttons.add(secondaryButton);
    }

    if (primaryFirst) {
      buttons = buttons.reversed.toList(); // Swap order if primaryFirst is true
    }

    return Align(
      alignment: Alignment.center,
      child: Column(
        children: buttons,
      ),
    );
  }
}
