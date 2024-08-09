// ignore_for_file: avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names, use_super_parameters

import 'package:client_pharmanathi/model/appointment_data.dart';
import 'package:flutter/material.dart';

class AppiontmentDetails extends StatelessWidget {
  final Appointment appointment;

  const AppiontmentDetails({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Expanded(
            child: Column(
              children: [
                //back button and the heading
                Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(25)),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 25, right: 30, left: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Color(0xFF6F7ED7),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 110, bottom: 2),
                          child: Text(
                            'Booking',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6F7ED7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //heading(personal infor)
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Row(
                    children: [
                      Text(
                        'Personal Info',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                //profile information
                Container(
                  width: double.infinity,
                  color: Color(0xFFFFFFFF),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage('your_image_url_here'),
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
                                  color: Colors.green,
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
                              appointment.doctor.doctorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              appointment.doctor.specialities[0],
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(left: 40, top: 50),
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
                //heading(booking infor)
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Row(
                    children: [
                      Text(
                        'Booking Info',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                //location ////////////////////////////////
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, top: 15, right: 15, bottom: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_sharp,
                              size: 19,
                              color: Colors.grey,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                appointment.doctor
                                    .doctorName, //TODO :this should be the practice location
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //SizedBox(height: 8), // Add space between the main text and subtext
                      Padding(
                        padding: const EdgeInsets.only(left: 45, top: 0),
                        child: Container(
                          width: 150,
                          child: Text(
                            appointment.doctor
                                .doctorName, //TODO :this should be the practice name
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors.grey), // Customize the subtext style
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //date///////////////////////////
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, top: 15, right: 15, bottom: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: 19,
                              color: Colors.grey,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                'Appointment Date',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //SizedBox(height: 8), // Add space between the main text and subtext
                      Padding(
                        padding: const EdgeInsets.only(left: 45, top: 0),
                        child: Text(
                          appointment.appointmentTypeRepr,
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey), // Customize the subtext style
                        ),
                      ),
                    ],
                  ),
                ),
                //time ///////////////////////////
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, top: 15, right: 15, bottom: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 19,
                              color: Colors.grey,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                'Time',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //SizedBox(height: 8), // Add space between the main text and subtext
                      Padding(
                        padding: const EdgeInsets.only(left: 45, top: 0),
                        child: Text(
                          appointment.appointmentTime,
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey), // Customize the subtext style
                        ),
                      ),
                    ],
                  ),
                ),
                //consultation details ///////////////////////////////
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, top: 15, right: 15, bottom: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_sharp,
                              size: 19,
                              color: Colors.grey,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                'Reason for Consultation',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //SizedBox(height: 8), // Add space between the main text and subtext
                      Padding(
                        padding: const EdgeInsets.only(left: 45, top: 0),
                        child: Container(
                          width: 200,
                          child: Text(
                            appointment.reason,
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors.grey), // Customize the subtext style
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //buttons////////////////
                SizedBox(height: 40),
                // Center(
                //   child: MyButtonWidgets(
                //     buttonText1: 'RESCHEDULE',
                //     onPressed1: () {
                //       // Handle the custom button action
                //       // print('Custom button pressed');
                //     },
                //     buttonText2: 'REJECT',
                //     onPressed2: () {
                //       // Handle the custom button action
                //       // print('Custom button pressed');
                //     },
                //   ).buildButton(),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
