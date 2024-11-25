import 'package:flutter/material.dart';

//* Global function to show an errors in a SnackBar
void showErrorSnackBar(BuildContext context, dynamic error) {
  final combinedMessage = error is List<String> ? error.join('\n') : error.toString();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(combinedMessage),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 5),
      behavior: SnackBarBehavior.floating
    ),
  );
}
