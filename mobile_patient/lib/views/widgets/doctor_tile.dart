// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:math';

import 'package:patient/config/color_const.dart';
import 'package:patient/main.dart';
import 'package:patient/model/doctor_data.dart';
import 'package:patient/screens/components/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../helpers/api_helpers.dart';
import '../screens/doctor_details.dart';

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

    String alteredname = ApiHelper.toTitleCase(doctor.doctorFullName);

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
      padding: const EdgeInsets.only(top: 5, left: 10, right: 8, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Pallet.BACKGROUND_COLOR,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10),
          // padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
<<<<<<< HEAD
                              radius: 50,
                              backgroundColor: Pallet.PURE_WHITE,
=======
                              radius:
                                  35, 
                              backgroundColor:Pallet.PURE_WHITE,
>>>>>>> 45de284a (feat: add screenutils and google fonts)
                              child: CircleAvatar(
                                backgroundColor: doctor.imageURL.isNotEmpty
                                    ? null // No background color if imageURL is available
                                    : getRandomColor(), // Random background color if imageURL is not available
                                radius: 28, // Inner circle radius
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
                                        doctor.doctorLastName.isNotEmpty
                                            ? doctor.doctorLastName[0]
                                            : '',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                        SizedBox(width: 25.sp),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alteredname,
                              style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18.sp,
                                  fontStyle: FontStyle.normal),
                            ),
                            Text(
                              doctor.getAllSpecialityNames(),
                              style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.sp,
                                  fontStyle: FontStyle.normal),
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
              // SizedBox(
              //   height: 20,
              // ),
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
