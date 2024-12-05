// ignore_for_file: prefer_const_constructors

import 'package:patient/screens/components/specialists/data.dart';
import 'package:flutter/material.dart';

class SpecialistCard extends StatefulWidget {
  final SpecialistDetails specialistDetails;

  const SpecialistCard({Key? key, required this.specialistDetails})
      : super(key: key);

  @override
  State<SpecialistCard> createState() => _SpecialistCardState();
}

class _SpecialistCardState extends State<SpecialistCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.specialistDetails.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    '${widget.specialistDetails.count} specialists',
                    style: TextStyle(fontSize: 8.0),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 10.0,
              ),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Divider(),
        ),
      ],
    );
  }
}
