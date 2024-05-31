// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors, sort_child_properties_last

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pharma_nathi/screens/components/patients/patient_data.dart';

class CustomCard extends StatelessWidget {
  final PatientData patient;

     //* Function to generate a random color
  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  const CustomCard({required this.patient});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, left: 10, right: 8, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Color(0xFFF7F9FC),
        ),
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                              backgroundColor: patient.imageUrl.isNotEmpty
                                  ? null // No background color if imageURL is available
                                  : getRandomColor(), // Random background color if imageURL is not available
                              child: patient.imageUrl.isNotEmpty
                                  ? Image.network(patient.imageUrl)
                                  : Text(
                                      patient.name.isNotEmpty ? patient.name[0] : '',
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ), //* Display the first letter of the name if imageURL is not available
                              radius: 30,
                            ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: patient.status == 'online'
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    patient.details,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 20, top: 50),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     crossAxisAlignment: CrossAxisAlignment.end,
              //     children: [
              //       Icon(
              //         Icons.video_call_sharp,
              //         color: Colors.grey,
              //       ),
              //       Icon(
              //         Icons.phone,
              //         color: Colors.grey,
              //       ),
              //       Icon(
              //         Icons.messenger,
              //         size: 19,
              //         color: Colors.grey,
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
