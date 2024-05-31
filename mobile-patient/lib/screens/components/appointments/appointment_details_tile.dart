// ignore_for_file: avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'dart:math';

import 'package:flutter/material.dart';

import '../../../helpers/api_helpers.dart';

class OnlineConsultation extends StatelessWidget {
  final time;
  final name;
  final date;
  final appointmentTime;
  final imageURL;
  final status;
  final title;
  final consult_details;
  final clinic_name;
  final clinic_address;

  const OnlineConsultation(
      {Key? key,
      required this.appointmentTime,
      required this.imageURL,
      required this.consult_details,
      required this.clinic_name,
      required this.clinic_address,
      required this.name,
      required this.date,
      required this.status,
      required this.title,
      required this.time});

  // Function to generate a random color
  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    String alteredname = ApiHelper.toTitleCase(name);
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
                        const EdgeInsets.only(top: 25, right: 30, left: 10),
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
                          padding: const EdgeInsets.only(left: 30, bottom: 10),
                          child: Text(
                            'Appointment Details',
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
                //profile information
                Container(
                  width: 400,
                  color: Color(0xFFFFFFFF),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: imageURL.isNotEmpty
                                  ? null // No background color if imageURL is available
                                  : getRandomColor(), // Random background color if imageURL is not available
                              child: imageURL.isNotEmpty
                                  ? Image.network(imageURL)
                                  : Text(
                                      name.isNotEmpty ? name[0] : '',
                                      style: TextStyle(
                                          fontSize: 20,
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
                              'Dr.$alteredname',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              title,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Booking Info',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Row(
                          children: [
                            Container(
                              // height: 30,
                              // width: 100,
                              decoration: BoxDecoration(
                                color: status == 'Upcoming'
                                    ? Colors.grey
                                    : Color.fromARGB(255, 181, 241, 212),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: status == 'Upcoming'
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                clinic_name,
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
                            clinic_address,
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
                          date,
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
                          time,
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
                            consult_details,
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
                SizedBox(height: 60),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (status == 'Upcoming')
                        ElevatedButton(
                          onPressed: () {
                            // Add your cancel button action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6F7ED7),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: Size(270, 40),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (status == 'Completed')
                        ElevatedButton(
                          onPressed: () {
                            // Add your done button action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6F7ED7),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: Size(270, 40),
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
