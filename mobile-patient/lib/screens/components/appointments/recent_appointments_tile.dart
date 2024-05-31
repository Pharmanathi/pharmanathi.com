// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';

import '../../../helpers/api_helpers.dart';

class AppiontmentTile extends StatelessWidget {
  final String title;
  final String date;
  final String visit_type;
  final String time;

  AppiontmentTile({
    Key? key,
    required this.title,
    required this.date,
    required this.visit_type,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = ApiHelper.toTitleCase(title);
    return Container(
      height: 100,
      width: 180,
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dr.$name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow:
                    TextOverflow.ellipsis, // Add ellipsis if text overflows
              ),
              SizedBox(height: 8),
              Text(
                date,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                visit_type,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
