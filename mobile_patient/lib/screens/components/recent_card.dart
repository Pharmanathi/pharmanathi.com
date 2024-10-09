// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class TopBorderCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color backgroundColor;

  const TopBorderCard({
    Key? key,
    required this.child,
    required this.borderColor,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: borderColor,
            width: 4.0,
          ),
        ),
        color: backgroundColor,
      ),
      child: child,
    );
  }
}

class CardData {
  final String title;
  final String count;
  final Color borderColor;
  final Color backgroundColor;

  CardData({
    required this.title,
    required this.count,
    required this.borderColor,
    required this.backgroundColor,
  });

  factory CardData.fromJson(Map<String, dynamic> json) {
    return CardData(
      title: json['title'],
      count: json['count'],
      borderColor: parseColor(json['borderColor']),
      backgroundColor: parseColor(json['backgroundColor']),
    );
  }

  static Color parseColor(String colorString) {
    String hexColor = colorString.replaceAll("#", "");
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}
