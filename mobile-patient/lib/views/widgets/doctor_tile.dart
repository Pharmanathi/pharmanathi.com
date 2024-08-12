// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:math';

import 'package:client_pharmanathi/model/doctor_data.dart';
import 'package:client_pharmanathi/screens/components/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/api_helpers.dart';
import 'doctor_details.dart';

class CustomDoctorCard extends StatelessWidget {
  final Doctor doctor;

  const CustomDoctorCard({Key? key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Extract doctorId from doctorDetail
    final doctorId = doctor.id;

    // Update the provider with the doctorId
    userProvider.selectedDoctorId = doctorId;
    String truncateText(String text, int maxLength) {
      if (text.length > maxLength) {
        return text.substring(0, maxLength) + '...';
      } else {
        return text;
      }
    }

    String alteredname = ApiHelper.toTitleCase(doctor.doctorName);

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
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  // Navigate to DoctorDetails page with corresponding data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorDetails(
                        doctor: doctor,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: doctor.imageURL.isNotEmpty
                                  ? null // No background color if imageURL is available
                                  : getRandomColor(), //* Display the first letter of the name if imageURL is not available
                              radius:
                                  30, // Random background color if imageURL is not available
                              child: doctor.imageURL.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        doctor.imageURL,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    )
                                  : Text(
                                      doctor.doctorName.isNotEmpty
                                          ? doctor.doctorName[0]
                                          : '',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                            // Positioned(
                            //   right: 0,
                            //   bottom: 0,
                            //   child: Container(
                            //     width: 12,
                            //     height: 20,
                            //     decoration: BoxDecoration(
                            //       shape: BoxShape.circle,
                            //       color: doctor.status == 'online'
                            //           ? Colors.green
                            //           : Colors.grey,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alteredname,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            // Text(
                            //   doctorDetails.title,
                            //   style: TextStyle(
                            //     color: Colors.grey,
                            //     fontSize: 14,
                            //   ),
                            // ),
                            // Text(
                            //   "${doctorDetails.distance} km away",
                            //   style: TextStyle(
                            //     color: Colors.grey,
                            //     fontSize: 14,
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                    // GestureDetector(
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //       // Icon(
                    //       //   Icons.star,
                    //       //   size: 15,
                    //       //   color: Color(0xFF6F7ED7),
                    //       // ),
                    //       // Text(
                    //       //   doctorDetails.rating,
                    //       //   style: TextStyle(
                    //       //     color: Color(0xFF6F7ED7),
                    //       //     fontSize: 10,
                    //       //   ),
                    //       // ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Row(
              //         // children: [
              //         //   Icon(
              //         //     doctorDetails.status == 'offline'
              //         //         ? Icons.videocam_off
              //         //         : Icons.videocam,
              //         //     size: 20,
              //         //     color: doctorDetails.status == 'offline'
              //         //         ? Colors.grey
              //         //         : Color(0xFF6F7ED7),
              //         //   ),
              //         //   SizedBox(
              //         //     width: 15,
              //         //   ),
              //         //   Text(
              //         //     'Video Visit',
              //         //     style: TextStyle(
              //         //       color: doctorDetails.status == 'offline'
              //         //           ? Colors.grey
              //         //           : Color(0xFF6F7ED7),
              //         //       fontSize: 15,
              //         //     ),
              //         //   ),
              //         // ],
              //         ),
              //     Padding(
              //       padding: const EdgeInsets.only(left: 100, top: 0),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         children: [
              //           // Icon(
              //           //   Icons.calendar_month,
              //           //   size: 17,
              //           //   color: Colors.grey,
              //           // ),
              //           SizedBox(
              //             width: 15,
              //           ),
              //           // Icon(
              //           //   Icons.forum,
              //           //   size: 17,
              //           //   color: Colors.grey,
              //           // ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
